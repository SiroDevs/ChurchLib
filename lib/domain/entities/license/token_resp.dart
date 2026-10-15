import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'pricing.dart';

/// The signed payload the server issues: see the web portal's README.
class LicenseToken extends Equatable {
  const LicenseToken({
    required this.machineId,
    required this.status,
    required this.trialEndsAt,
    required this.licenseKey,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory LicenseToken.fromJson(Map<String, dynamic> json) {
    if (json['v'] != 1) {
      throw const FormatException('Unsupported token version');
    }
    final status = TokenStatus.values.asNameMap()[json['st'] as String];
    if (status == null) throw const FormatException('Unknown token status');
    final exp = json['exp'];
    return LicenseToken(
      machineId: json['mid'] as String,
      status: status,
      trialEndsAt: DateTime.parse(json['tre'] as String).toUtc(),
      licenseKey: json['lk'] as String?,
      issuedAt: DateTime.parse(json['iat'] as String).toUtc(),
      expiresAt: exp == null ? null : DateTime.parse(exp as String).toUtc(),
    );
  }

  /// SHA-256 id of the computer this token is bound to.
  final String machineId;
  final TokenStatus status;
  final DateTime trialEndsAt;
  final String? licenseKey;

  /// Server time when the token was issued. Doubles as a "trusted clock".
  final DateTime issuedAt;

  /// Null for lifetime licenses.
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
    machineId,
    status,
    trialEndsAt,
    licenseKey,
    issuedAt,
    expiresAt,
  ];
}

/// What the server answers to every license request.
class LicenseResponse {
  const LicenseResponse({
    required this.token,
    required this.paymentPending,
    required this.pricing,
    required this.licensedAt,
  });

  factory LicenseResponse.fromJson(Map<String, dynamic> json) {
    final license = json['license'];
    return LicenseResponse(
      token: json['token'] as String,
      paymentPending: json['paymentPending'] == true,
      pricing: json['pricing'] is Map<String, dynamic>
          ? LicensePricing.fromJson(json['pricing'] as Map<String, dynamic>)
          : LicensePricing.fallback,
      licensedAt:
          license is Map<String, dynamic> && license['issuedAt'] is String
          ? DateTime.tryParse(license['issuedAt'] as String)
          : null,
    );
  }

  /// The only part the app trusts. The rest is for display.
  final String token;
  final bool paymentPending;
  final LicensePricing pricing;
  final DateTime? licensedAt;
}

/// The result of an action the user started (check, pay, redeem, release).
class LicenseOutcome {
  const LicenseOutcome.success() : ok = true, message = null, offline = false;

  const LicenseOutcome.failure(String this.message, {this.offline = false})
    : ok = false;

  final bool ok;
  final String? message;
  final bool offline;
}
