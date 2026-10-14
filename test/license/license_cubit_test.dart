import 'package:churchlib/common/constants/pref_constants.dart';
import 'package:churchlib/core/license/license_api.dart';
import 'package:churchlib/core/license/license_cubit.dart';
import 'package:churchlib/core/license/license_models.dart';
import 'package:churchlib/core/license/license_service.dart';
import 'package:churchlib/core/license/license_storage.dart';
import 'package:churchlib/core/license/license_verifier.dart';
import 'package:churchlib/core/license/machine_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

/// Answers license requests from a script instead of the network.
class FakeApi extends LicenseApi {
  FakeApi() : super(baseUrl: 'http://localhost');

  LicenseResponse? response;
  LicenseApiException? error;

  LicenseResponse _answer() {
    final e = error;
    if (e != null) throw e;
    return response!;
  }

  @override
  Future<LicenseResponse> checkIn({
    required String machineId,
    required String appVersion,
  }) async =>
      _answer();

  @override
  Future<LicenseResponse> submitPayment({
    required String machineId,
    required String method,
    required String reference,
    required String payerName,
    required String payerPhone,
  }) async =>
      _answer();

  @override
  Future<LicenseResponse> redeem({
    required String machineId,
    required String licenseKey,
  }) async =>
      _answer();

  @override
  Future<LicenseResponse> release({required String machineId}) async => _answer();
}

class FixedMachine extends MachineIdProvider {
  FixedMachine(SharedPreferences prefs) : super(prefs);

  @override
  Future<String> hashedId() async => testMachine;
}

LicenseResponse respond(String token, {bool pending = false}) => LicenseResponse(
      token: token,
      paymentPending: pending,
      pricing: LicensePricing.fallback,
      licensedAt: null,
    );

const offline = LicenseApiException('offline', offline: true);

class Harness {
  Harness._(this.cubit, this.api, this.setNow);

  final LicenseCubit cubit;
  final FakeApi api;
  final void Function(DateTime) setNow;

  /// [storedToken] is what the previous run left on disk.
  static Future<Harness> create({
    required DateTime now,
    String? storedToken,
  }) async {
    SharedPreferences.setMockInitialValues({
      if (storedToken != null) PrefConstants.licenseTokenKey: storedToken,
    });
    final prefs = await SharedPreferences.getInstance();
    final api = FakeApi();
    var current = now;
    final service = LicenseService(
      api: api,
      storage: LicenseStorage(prefs),
      machineId: FixedMachine(prefs),
      verifier: LicenseTokenVerifier(testPublicKey),
      clock: () => current,
      appVersion: () async => '1.0.0',
      configured: true,
      developerBypass: false,
    );
    final cubit = LicenseCubit(service, connectivity: const Stream<bool>.empty());
    return Harness._(cubit, api, (value) => current = value);
  }
}

void main() {
  test('first run without internet stays locked, then opens when the trial starts',
      () async {
    final h = await Harness.create(now: t0);
    h.api.error = offline;

    await h.cubit.initialize();
    await h.cubit.refresh();
    expect(h.cubit.state.status, LicenseStatus.unactivated);
    expect(h.cubit.isGateOpen, isFalse);
    expect(h.cubit.state.lastError, 'offline');

    h.api
      ..error = null
      ..response = respond(trialToken);
    final outcome = await h.cubit.refresh();

    expect(outcome.ok, isTrue);
    expect(h.cubit.state.status, LicenseStatus.trial);
    expect(h.cubit.state.daysLeft, 7);
    expect(h.cubit.isGateOpen, isTrue);
  });

  test('a valid stored trial works with no internet at all', () async {
    final h = await Harness.create(now: t0.add(days(2)), storedToken: trialToken);
    h.api.error = offline;

    await h.cubit.initialize();

    expect(h.cubit.state.status, LicenseStatus.trial);
    expect(h.cubit.state.daysLeft, 5);
    expect(h.cubit.isGateOpen, isTrue);
  });

  test('a running session is never interrupted when the trial ends', () async {
    final h = await Harness.create(now: t0.add(days(1)), storedToken: trialToken);
    h.api.error = offline;
    await h.cubit.initialize();
    expect(h.cubit.isGateOpen, isTrue);

    // Two days later the server reports the trial as over.
    h.setNow(t0.add(days(9)));
    h.api
      ..error = null
      ..response = respond(expiredToken);
    await h.cubit.refresh();

    expect(h.cubit.state.status, LicenseStatus.expired); // the banner updates...
    expect(h.cubit.isGateOpen, isTrue); // ...but the app keeps working
  });

  test('an expired app starts locked and opens once the payment is approved',
      () async {
    final h = await Harness.create(now: t0.add(days(9)), storedToken: expiredToken);
    h.api.error = offline;
    await h.cubit.initialize();
    expect(h.cubit.state.status, LicenseStatus.expired);
    expect(h.cubit.isGateOpen, isFalse);

    h.api
      ..error = null
      ..response = respond(licensedToken);
    await h.cubit.refresh();

    expect(h.cubit.state.status, LicenseStatus.licensed);
    expect(h.cubit.state.licenseKey, 'CL-TEST-AAAA-BBBB');
    expect(h.cubit.isGateOpen, isTrue);
  });

  test('submitting a payment shows it as waiting for approval', () async {
    final h = await Harness.create(now: t0.add(days(9)), storedToken: expiredToken);
    h.api.error = offline;
    await h.cubit.initialize();

    h.api
      ..error = null
      ..response = respond(expiredToken, pending: true);
    final outcome = await h.cubit.submitPayment(
      method: 'mpesa',
      reference: 'SH12ABC3XY',
      payerName: 'Jane',
      payerPhone: '0712345678',
    );

    expect(outcome.ok, isTrue);
    expect(h.cubit.state.paymentPending, isTrue);
    expect(h.cubit.isGateOpen, isFalse);
  });

  test('releasing the license locks the computer straight away', () async {
    final h = await Harness.create(now: t0.add(days(20)), storedToken: licensedToken);
    h.api.error = offline;
    await h.cubit.initialize();
    expect(h.cubit.state.status, LicenseStatus.licensed);
    expect(h.cubit.isGateOpen, isTrue);

    h.api
      ..error = null
      ..response = respond(expiredToken);
    final outcome = await h.cubit.releaseThisComputer();

    expect(outcome.ok, isTrue);
    expect(h.cubit.state.status, LicenseStatus.expired);
    expect(h.cubit.isGateOpen, isFalse);
  });

  test('a server error is reported, and the stored license is kept', () async {
    final h = await Harness.create(now: t0.add(days(20)), storedToken: licensedToken);
    h.api.error = const LicenseApiException('No transfers left');
    await h.cubit.initialize();

    final outcome = await h.cubit.releaseThisComputer();

    expect(outcome.ok, isFalse);
    expect(outcome.message, 'No transfers left');
    expect(h.cubit.state.status, LicenseStatus.licensed);
    expect(h.cubit.isGateOpen, isTrue);
  });

  test("a token copied from another computer doesn't count", () async {
    final h = await Harness.create(now: t0, storedToken: trialTokenOtherMachine);
    h.api.error = offline;

    await h.cubit.initialize();

    expect(h.cubit.state.status, LicenseStatus.unactivated);
    expect(h.cubit.isGateOpen, isFalse);
  });
}
