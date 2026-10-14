import 'package:package_info_plus/package_info_plus.dart';

import 'license_api.dart';
import 'license_config.dart';
import 'license_evaluator.dart';
import 'license_models.dart';
import 'license_storage.dart';
import 'license_verifier.dart';
import 'machine_id.dart';

/// A point-in-time answer to "may this computer use ChurchLib?".
class LicenseSnapshot {
  const LicenseSnapshot({
    required this.evaluation,
    required this.meta,
    required this.computerId,
  });

  final LicenseEvaluation evaluation;
  final LicenseMeta meta;
  final String computerId;
}

/// Orchestrates the license rules: machine id, stored token, server calls.
///
/// Trust rules:
///  * only a token whose signature verifies and whose machine id matches this
///    computer is ever believed
///  * licensed tokens work offline forever
///  * the server's JSON `status` is ignored: decisions come from the token
class LicenseService {
  LicenseService({
    required LicenseApi api,
    required LicenseStorage storage,
    required MachineIdProvider machineId,
    required LicenseTokenVerifier verifier,
    // The rest exists so tests can control time and settings.
    DateTime Function()? clock,
    Future<String> Function()? appVersion,
    bool? configured,
    bool? developerBypass,
  })  : _api = api,
        _storage = storage,
        _machineId = machineId,
        _verifier = verifier,
        _clock = clock ?? DateTime.now,
        _appVersion = appVersion ?? _packageVersion,
        _configured = configured ?? LicenseConfig.isConfigured,
        _developerBypass = developerBypass ?? LicenseConfig.isDeveloperBypass;

  final LicenseApi _api;
  final LicenseStorage _storage;
  final MachineIdProvider _machineId;
  final LicenseTokenVerifier _verifier;
  final DateTime Function() _clock;
  final Future<String> Function() _appVersion;
  final bool _configured;
  final bool _developerBypass;

  static Future<String> _packageVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  /// Works offline. Reads and verifies the stored token.
  Future<LicenseSnapshot> evaluateLocal() async {
    final machine = await _machineId.hashedId();
    final computerId = MachineIdProvider.shortId(machine);
    final meta = _storage.meta;

    if (_developerBypass) {
      return LicenseSnapshot(
        evaluation: const LicenseEvaluation(LicenseStatus.developer),
        meta: meta,
        computerId: computerId,
      );
    }
    if (!_configured) {
      return LicenseSnapshot(
        evaluation: const LicenseEvaluation(LicenseStatus.notConfigured),
        meta: meta,
        computerId: computerId,
      );
    }

    final raw = _storage.token;
    final token = raw == null ? null : await _verifier.verify(raw);
    final now = _clock().toUtc();
    final evaluation = evaluateLicense(
      token: token,
      machineId: machine,
      now: now,
      lastSeen: _storage.lastSeen,
    );
    // Never let a wrong clock move our "last seen" memory backwards or forwards.
    if (evaluation.status != LicenseStatus.clockError) {
      await _storage.touchLastSeen(now);
    }
    return LicenseSnapshot(
      evaluation: evaluation,
      meta: meta,
      computerId: computerId,
    );
  }

  /// First call starts the trial; later calls refresh status. Throws
  /// [LicenseApiException] when the server can't be reached or says no.
  Future<LicenseSnapshot> checkIn() async {
    if (!_configured) return evaluateLocal();
    final machine = await _machineId.hashedId();
    return _apply(await _api.checkIn(machineId: machine, appVersion: await _appVersion()));
  }

  Future<LicenseSnapshot> submitPayment({
    required String method,
    required String reference,
    required String payerName,
    required String payerPhone,
  }) async {
    _requireConfigured();
    final machine = await _machineId.hashedId();
    return _apply(await _api.submitPayment(
      machineId: machine,
      method: method,
      reference: reference,
      payerName: payerName,
      payerPhone: payerPhone,
    ));
  }

  Future<LicenseSnapshot> redeem(String licenseKey) async {
    _requireConfigured();
    final machine = await _machineId.hashedId();
    return _apply(await _api.redeem(machineId: machine, licenseKey: licenseKey));
  }

  Future<LicenseSnapshot> release() async {
    _requireConfigured();
    final machine = await _machineId.hashedId();
    return _apply(await _api.release(machineId: machine));
  }

  void _requireConfigured() {
    if (!_configured) {
      throw const LicenseApiException(
        'The license server is not configured in this build.',
      );
    }
  }

  /// Accepts a server answer only if its token verifies for this computer.
  Future<LicenseSnapshot> _apply(LicenseResponse response) async {
    final machine = await _machineId.hashedId();
    final token = await _verifier.verify(response.token);
    if (token == null || token.machineId != machine) {
      throw const LicenseApiException(
        'The license server sent an answer that could not be verified.',
      );
    }
    final now = _clock().toUtc();
    await _storage.saveToken(response.token);
    // The server's clock is the trusted one: remember it if it is ahead of ours.
    await _storage.touchLastSeen(token.issuedAt.isAfter(now) ? token.issuedAt : now);
    await _storage.saveMeta(LicenseMeta(
      pricing: response.pricing,
      paymentPending: response.paymentPending,
      lastCheckedAt: now,
      licensedAt: response.licensedAt,
    ));
    return evaluateLocal();
  }

  void dispose() => _api.close();
}
