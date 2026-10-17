// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../common/constants/api_constants.dart';

class LicenseConfig {
  LicenseConfig._();
  /// Address of the admin portal, without a trailing slash.
  static final String apiBaseUrl = ApiConstants.licenceApi;

  /// 32-byte Ed25519 public key, base64 (Dashboard > Settings).
  // static const String publicKeyBase64 = String.fromEnvironment(
  //   'LICENSE_PUBLIC_KEY',
  // );
  static const String publicKeyBase64 = "vCv4TEH8xQQhUL2JOY8ViZbtM9LmVOYOPeT+hV2ksak=";

  static bool get isConfigured =>
      apiBaseUrl.isNotEmpty && publicKeyBase64.isNotEmpty;

  static bool get isDeveloperBypass => kDebugMode && !isConfigured;

  static const Duration requestTimeout = Duration(seconds: 15);

  /// How often a running app re-checks with the server.
  static const Duration refreshInterval = Duration(hours: 6);

  /// Don't ask again sooner than this after a successful check.
  static const Duration minRefreshGap = Duration(minutes: 15);

  /// Allowed difference between the computer clock and the last known time.
  static const Duration clockTolerance = Duration(minutes: 10);
}
