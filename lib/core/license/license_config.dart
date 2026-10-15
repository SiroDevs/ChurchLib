import 'package:flutter/foundation.dart';

import '../../common/constants/api_constants.dart';

/// Build-time settings. Pass them when building:
///
///   flutter build windows \
///     --dart-define=LICENSE_API_URL=https://your-portal.example.com \
///     --dart-define=LICENSE_PUBLIC_KEY=<public key from Dashboard > Settings>
///
/// Release builds without these show a "not configured" screen instead of
/// silently running for free. Debug builds without them are unlocked so
/// development isn't blocked.
class LicenseConfig {
  LicenseConfig._();
  /// Address of the admin portal, without a trailing slash.
  static final String apiBaseUrl = ApiConstants.licenceApi;

  /// 32-byte Ed25519 public key, base64 (Dashboard > Settings).
  static const String publicKeyBase64 = String.fromEnvironment(
    'LICENSE_PUBLIC_KEY',
  );

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
