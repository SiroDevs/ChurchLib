import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// What the app should do right now.
enum LicenseStatus {
  /// Reading the stored license (only seen for a moment at startup).
  checking,

  /// No valid license information yet: the first online check-in hasn't succeeded.
  unactivated,

  /// Free trial is running.
  trial,

  /// Free trial is over and no license has been bought.
  expired,

  /// Paid license for this computer. Never expires.
  licensed,

  /// The license was withdrawn by the administrator.
  revoked,

  /// The computer's clock is behind the last time we spoke to the server.
  clockError,

  /// A release build that was compiled without the license server settings.
  notConfigured,

  /// A debug build without server settings: everything is unlocked.
  developer;

  bool get allowsUse =>
      this == LicenseStatus.trial ||
      this == LicenseStatus.licensed ||
      this == LicenseStatus.developer;
}

/// The status written inside a signed token by the server.
enum TokenStatus { trial, expired, licensed, revoked }

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
    if (json['v'] != 1) throw const FormatException('Unsupported token version');
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
  List<Object?> get props =>
      [machineId, status, trialEndsAt, licenseKey, issuedAt, expiresAt];
}

/// Price and payment details shown on the paywall. Comes from the server so
/// you can change them without shipping a new version.
class LicensePricing extends Equatable {
  const LicensePricing({
    required this.amount,
    required this.currency,
    required this.amountUsd,
    required this.mpesaNumber,
    required this.paypalEmail,
    required this.supportEmail,
    required this.supportWhatsapp,
  });

  factory LicensePricing.fromJson(Map<String, dynamic> json) {
    const d = LicensePricing.fallback;
    return LicensePricing(
      amount: (json['amount'] as num?) ?? d.amount,
      currency: (json['currency'] as String?) ?? d.currency,
      amountUsd: (json['amountUsd'] as num?) ?? d.amountUsd,
      mpesaNumber: (json['mpesaNumber'] as String?) ?? d.mpesaNumber,
      paypalEmail: (json['paypalEmail'] as String?) ?? d.paypalEmail,
      supportEmail: (json['supportEmail'] as String?) ?? d.supportEmail,
      supportWhatsapp: (json['supportWhatsapp'] as String?) ?? d.supportWhatsapp,
    );
  }

  /// Used until the server has answered once, and when offline.
  static const LicensePricing fallback = LicensePricing(
    amount: 5000,
    currency: 'KES',
    amountUsd: 40,
    mpesaNumber: '0115586529',
    paypalEmail: 'sirodevske@gmail.com',
    supportEmail: '',
    supportWhatsapp: '',
  );

  final num amount;
  final String currency;
  final num amountUsd;
  final String mpesaNumber;
  final String paypalEmail;
  final String supportEmail;
  final String supportWhatsapp;

  static String _group(num n) => NumberFormat.decimalPattern('en').format(n);

  /// "KES 5,000"
  String get localPrice => '$currency ${_group(amount)}';

  /// "$40"
  String get usdPrice => '\$${_group(amountUsd)}';

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'amountUsd': amountUsd,
        'mpesaNumber': mpesaNumber,
        'paypalEmail': paypalEmail,
        'supportEmail': supportEmail,
        'supportWhatsapp': supportWhatsapp,
      };

  @override
  List<Object?> get props => [
        amount,
        currency,
        amountUsd,
        mpesaNumber,
        paypalEmail,
        supportEmail,
        supportWhatsapp,
      ];
}

/// Non-security details kept next to the token, for display only.
class LicenseMeta extends Equatable {
  const LicenseMeta({
    required this.pricing,
    this.paymentPending = false,
    this.lastCheckedAt,
    this.licensedAt,
  });

  factory LicenseMeta.fromJson(Map<String, dynamic> json) => LicenseMeta(
        pricing: json['pricing'] is Map<String, dynamic>
            ? LicensePricing.fromJson(json['pricing'] as Map<String, dynamic>)
            : LicensePricing.fallback,
        paymentPending: json['paymentPending'] == true,
        lastCheckedAt: json['lastCheckedAt'] is int
            ? DateTime.fromMillisecondsSinceEpoch(json['lastCheckedAt'] as int)
            : null,
        licensedAt: json['licensedAt'] is int
            ? DateTime.fromMillisecondsSinceEpoch(json['licensedAt'] as int)
            : null,
      );

  static const LicenseMeta empty = LicenseMeta(pricing: LicensePricing.fallback);

  final LicensePricing pricing;
  final bool paymentPending;
  final DateTime? lastCheckedAt;
  final DateTime? licensedAt;

  Map<String, dynamic> toJson() => {
        'pricing': pricing.toJson(),
        'paymentPending': paymentPending,
        'lastCheckedAt': lastCheckedAt?.millisecondsSinceEpoch,
        'licensedAt': licensedAt?.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [pricing, paymentPending, lastCheckedAt, licensedAt];
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
      licensedAt: license is Map<String, dynamic> && license['issuedAt'] is String
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

/// Everything the UI needs, as one immutable value.
class LicenseState extends Equatable {
  const LicenseState({
    this.status = LicenseStatus.checking,
    this.daysLeft = 0,
    this.trialEndsAt,
    this.licenseKey,
    this.licensedAt,
    this.paymentPending = false,
    this.pricing = LicensePricing.fallback,
    this.lastCheckedAt,
    this.computerId = '',
    this.busy = false,
    this.lastError,
  });

  final LicenseStatus status;
  final int daysLeft;
  final DateTime? trialEndsAt;
  final String? licenseKey;
  final DateTime? licensedAt;
  final bool paymentPending;
  final LicensePricing pricing;
  final DateTime? lastCheckedAt;

  /// Short form of the computer id, e.g. "A1B2-C3D4". Matches the dashboard.
  final String computerId;

  /// A network request is running.
  final bool busy;
  final String? lastError;

  bool get allowsUse => status.allowsUse;

  LicenseState copyWith({bool? busy, String? lastError, bool clearError = false}) {
    return LicenseState(
      status: status,
      daysLeft: daysLeft,
      trialEndsAt: trialEndsAt,
      licenseKey: licenseKey,
      licensedAt: licensedAt,
      paymentPending: paymentPending,
      pricing: pricing,
      lastCheckedAt: lastCheckedAt,
      computerId: computerId,
      busy: busy ?? this.busy,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        daysLeft,
        trialEndsAt,
        licenseKey,
        licensedAt,
        paymentPending,
        pricing,
        lastCheckedAt,
        computerId,
        busy,
        lastError,
      ];
}

/// The result of an action the user started (check, pay, redeem, release).
class LicenseOutcome {
  const LicenseOutcome.success()
      : ok = true,
        message = null,
        offline = false;

  const LicenseOutcome.failure(String this.message, {this.offline = false})
      : ok = false;

  final bool ok;
  final String? message;

  /// The server could not be reached (as opposed to rejecting the request).
  final bool offline;
}
