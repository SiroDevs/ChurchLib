import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/utils/formatting/app_util.dart';
import '../../common/utils/network/network_utils.dart';
import 'license_api.dart';
import 'license_config.dart';
import 'license_models.dart';
import 'license_service.dart';

/// Holds the license state for the whole app.
///
/// The "gate" is what the router checks. It is decided when the app starts and
/// afterwards only ever opens: if a trial runs out (or a license is withdrawn)
/// while ChurchLib is open, the running session is never interrupted. Nobody
/// loses their lyrics mid-service. The change takes effect the next time the
/// app starts.
class LicenseCubit extends Cubit<LicenseState> {
  LicenseCubit(this._service, {Stream<bool>? connectivity})
      : _connectivityStream = connectivity ?? NetworkUtil.onConnectivityChanged,
        super(const LicenseState());

  final LicenseService _service;
  final Stream<bool> _connectivityStream;

  bool _gateOpen = false;
  Timer? _timer;
  StreamSubscription<bool>? _connectivity;
  Future<LicenseOutcome>? _refreshing;

  /// May the router let the person into the app?
  bool get isGateOpen => _gateOpen;

  /// Reads the stored license (no network) and starts background checks.
  /// Call once at startup, before the app is shown.
  Future<void> initialize() async {
    try {
      _apply(await _service.evaluateLocal(), initial: true);
    } catch (e) {
      logger('License: could not read the stored license: $e');
      _emit(const LicenseState(status: LicenseStatus.unactivated));
    }

    _timer = Timer.periodic(
      LicenseConfig.refreshInterval,
      (_) => unawaited(refresh()),
    );
    _connectivity = _connectivityStream.listen((online) {
      if (online) unawaited(_refreshIfStale());
    });
    // In the background: startup never waits for the network.
    unawaited(refresh());
  }

  /// Asks the server. Safe to call often: one request at a time.
  Future<LicenseOutcome> refresh() {
    return _refreshing ??= _run(_service.checkIn).whenComplete(() {
      _refreshing = null;
    });
  }

  Future<LicenseOutcome> submitPayment({
    required String method,
    required String reference,
    required String payerName,
    required String payerPhone,
  }) {
    return _run(() => _service.submitPayment(
          method: method,
          reference: reference,
          payerName: payerName,
          payerPhone: payerPhone,
        ));
  }

  Future<LicenseOutcome> redeem(String licenseKey) {
    return _run(() => _service.redeem(licenseKey));
  }

  /// Frees this computer's license so it can be used on another one.
  Future<LicenseOutcome> releaseThisComputer() {
    return _run(_service.release, resetGate: true);
  }

  Future<void> _refreshIfStale() async {
    final last = state.lastCheckedAt;
    final stale = last == null ||
        DateTime.now().difference(last) > LicenseConfig.minRefreshGap;
    if (stale || !state.allowsUse) await refresh();
  }

  Future<LicenseOutcome> _run(
    Future<LicenseSnapshot> Function() action, {
    bool resetGate = false,
  }) async {
    _emit(state.copyWith(busy: true, clearError: true));
    try {
      _apply(await action(), resetGate: resetGate);
      return const LicenseOutcome.success();
    } on LicenseApiException catch (e) {
      _emit(state.copyWith(busy: false, lastError: e.message));
      return LicenseOutcome.failure(e.message, offline: e.offline);
    } catch (e) {
      logger('License action failed: $e');
      const message = 'Something went wrong. Please try again.';
      _emit(state.copyWith(busy: false, lastError: message));
      return const LicenseOutcome.failure(message);
    }
  }

  void _apply(
    LicenseSnapshot snapshot, {
    bool initial = false,
    bool resetGate = false,
  }) {
    final e = snapshot.evaluation;
    final next = LicenseState(
      status: e.status,
      daysLeft: e.daysLeft,
      trialEndsAt: e.trialEndsAt,
      licenseKey: e.licenseKey,
      licensedAt: snapshot.meta.licensedAt,
      paymentPending: snapshot.meta.paymentPending,
      pricing: snapshot.meta.pricing,
      lastCheckedAt: snapshot.meta.lastCheckedAt,
      computerId: snapshot.computerId,
    );
    if (initial || resetGate) {
      _gateOpen = next.allowsUse;
    } else if (next.allowsUse) {
      _gateOpen = true; // opens, never closes during a session
    }
    _emit(next);
  }

  void _emit(LicenseState next) {
    if (!isClosed) emit(next);
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _connectivity?.cancel();
    _service.dispose();
    return super.close();
  }
}
