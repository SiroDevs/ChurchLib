import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

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
      supportWhatsapp:
          (json['supportWhatsapp'] as String?) ?? d.supportWhatsapp,
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

  static const LicenseMeta empty = LicenseMeta(
    pricing: LicensePricing.fallback,
  );

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
  List<Object?> get props => [
    pricing,
    paymentPending,
    lastCheckedAt,
    licensedAt,
  ];
}
