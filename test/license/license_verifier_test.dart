import 'dart:convert';

import 'package:churchlib/core/license/license_models.dart';
import 'package:churchlib/core/license/license_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  final verifier = LicenseTokenVerifier(testPublicKey);

  group('tokens signed by the web portal', () {
    test('a trial token verifies and is read correctly', () async {
      final t = await verifier.verify(trialToken);
      expect(t, isNotNull);
      expect(t!.status, TokenStatus.trial);
      expect(t.machineId, testMachine);
      expect(t.trialEndsAt, t0.add(days(7)));
      expect(t.issuedAt, t0);
      expect(t.expiresAt, t0.add(days(30)));
      expect(t.licenseKey, isNull);
    });

    test('a licensed token carries the key and never expires', () async {
      final t = await verifier.verify(licensedToken);
      expect(t!.status, TokenStatus.licensed);
      expect(t.licenseKey, 'CL-TEST-AAAA-BBBB');
      expect(t.expiresAt, isNull);
    });

    test('expired and revoked tokens verify too', () async {
      expect((await verifier.verify(expiredToken))!.status, TokenStatus.expired);
      expect((await verifier.verify(revokedToken))!.status, TokenStatus.revoked);
    });
  });

  group('anything else is rejected', () {
    test('a changed payload', () async {
      final parts = licensedToken.split('.');
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
      final forged = payload.replaceAll('"licensed"', '"trial"  ');
      final body = base64Url.encode(utf8.encode(forged)).replaceAll('=', '');
      expect(await verifier.verify('$body.${parts[1]}'), isNull);
    });

    test('a changed signature', () async {
      final parts = trialToken.split('.');
      final sig = parts[1];
      final flipped = (sig.startsWith('A') ? 'B' : 'A') + sig.substring(1);
      expect(await verifier.verify('${parts[0]}.$flipped'), isNull);
    });

    test('a different public key', () async {
      final other = base64.encode(List<int>.filled(32, 7));
      expect(await LicenseTokenVerifier(other).verify(trialToken), isNull);
    });

    test('a public key of the wrong length', () async {
      final short = base64.encode(List<int>.filled(16, 7));
      expect(await LicenseTokenVerifier(short).verify(trialToken), isNull);
    });

    test('garbage', () async {
      for (final junk in ['', 'abc', 'a.b.c', '.', 'a.', '.b', 'not base64!.not base64!']) {
        expect(await verifier.verify(junk), isNull, reason: junk);
      }
    });
  });
}
