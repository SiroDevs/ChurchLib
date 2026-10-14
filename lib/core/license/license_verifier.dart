import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'license_models.dart';

class LicenseTokenVerifier {
  LicenseTokenVerifier(this.publicKeyBase64);

  final String publicKeyBase64;
  final Ed25519 _algorithm = Ed25519();

  Future<LicenseToken?> verify(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 2) return null;

      final publicKey = base64.decode(publicKeyBase64);
      if (publicKey.length != 32) return null;

      final signature = _decodeBase64Url(parts[1]);
      final valid = await _algorithm.verify(
        utf8.encode(parts[0]),
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
        ),
      );
      if (!valid) return null;

      final json = jsonDecode(utf8.decode(_decodeBase64Url(parts[0])));
      if (json is! Map<String, dynamic>) return null;
      return LicenseToken.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static List<int> _decodeBase64Url(String input) =>
      base64Url.decode(base64Url.normalize(input));
}
