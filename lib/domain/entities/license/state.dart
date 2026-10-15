// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'enums.dart';
import 'pricing.dart';

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

  LicenseState copyWith({
    bool? busy,
    String? lastError,
    bool clearError = false,
  }) {
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
