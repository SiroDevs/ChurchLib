import 'package:churchlib/core/license/license_evaluator.dart';
import 'package:churchlib/core/license/license_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

LicenseToken token(
  TokenStatus status, {
  String machine = 'm1',
  DateTime? issuedAt,
  DateTime? trialEndsAt,
  DateTime? expiresAt,
  String? key,
}) {
  return LicenseToken(
    machineId: machine,
    status: status,
    trialEndsAt: trialEndsAt ?? t0.add(days(7)),
    licenseKey: key,
    issuedAt: issuedAt ?? t0,
    expiresAt: expiresAt,
  );
}

LicenseEvaluation evaluate(
  LicenseToken? t, {
  required DateTime now,
  DateTime? lastSeen,
  String machine = 'm1',
}) {
  return evaluateLicense(
    token: t,
    machineId: machine,
    now: now,
    lastSeen: lastSeen,
  );
}

void main() {
  group('who the token belongs to', () {
    test('no token means not activated yet', () {
      expect(evaluate(null, now: t0).status, LicenseStatus.unactivated);
    });

    test('a token for another computer is worthless', () {
      final t = token(TokenStatus.licensed, machine: 'someone-else');
      expect(evaluate(t, now: t0).status, LicenseStatus.unactivated);
    });
  });

  group('free trial', () {
    test('seven days left right after it starts', () {
      final e = evaluate(token(TokenStatus.trial), now: t0);
      expect(e.status, LicenseStatus.trial);
      expect(e.daysLeft, 7);
    });

    test('a partial day counts as a day', () {
      final now = t0.add(const Duration(days: 6, hours: 12));
      expect(evaluate(token(TokenStatus.trial), now: now).daysLeft, 1);
    });

    test('ends exactly at the trial end time', () {
      final e = evaluate(token(TokenStatus.trial), now: t0.add(days(7)));
      expect(e.status, LicenseStatus.expired);
    });

    test('stays expired afterwards', () {
      final e = evaluate(token(TokenStatus.trial), now: t0.add(days(40)));
      expect(e.status, LicenseStatus.expired);
    });
  });

  group('licensed', () {
    test('never expires, whatever the date', () {
      final t = token(TokenStatus.licensed, key: 'CL-AAAA-BBBB-CCCC');
      final e = evaluate(t, now: DateTime.utc(2040), lastSeen: DateTime.utc(2050));
      expect(e.status, LicenseStatus.licensed);
      expect(e.licenseKey, 'CL-AAAA-BBBB-CCCC');
    });

    test('is not affected by a wrong clock', () {
      final t = token(TokenStatus.licensed);
      final e = evaluate(t, now: t0.subtract(days(100)));
      expect(e.status, LicenseStatus.licensed);
    });
  });

  group('server verdicts', () {
    test('revoked stays revoked', () {
      expect(evaluate(token(TokenStatus.revoked), now: t0).status, LicenseStatus.revoked);
    });

    test('expired stays expired until the server says otherwise', () {
      expect(evaluate(token(TokenStatus.expired), now: t0).status, LicenseStatus.expired);
    });
  });

  group('clock tricks', () {
    test('clock turned back before the token was issued', () {
      final t = token(TokenStatus.trial, issuedAt: t0.add(days(2)));
      expect(evaluate(t, now: t0).status, LicenseStatus.clockError);
    });

    test('a few minutes of drift is fine', () {
      final now = t0.subtract(const Duration(minutes: 5));
      expect(evaluate(token(TokenStatus.trial), now: now).status, LicenseStatus.trial);
    });

    test('clock behind the last moment we saw', () {
      final e = evaluate(
        token(TokenStatus.trial),
        now: t0.add(days(1)),
        lastSeen: t0.add(days(3)),
      );
      expect(e.status, LicenseStatus.clockError);
    });

    test('a trial token older than its expiry must be refreshed online', () {
      final t = token(
        TokenStatus.trial,
        trialEndsAt: t0.add(days(60)),
        expiresAt: t0.add(days(30)),
      );
      expect(evaluate(t, now: t0.add(days(31))).status, LicenseStatus.unactivated);
    });
  });
}
