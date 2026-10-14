import 'license_config.dart';
import 'license_models.dart';

class LicenseEvaluation {
  const LicenseEvaluation(
    this.status, {
    this.daysLeft = 0,
    this.trialEndsAt,
    this.licenseKey,
  });

  final LicenseStatus status;
  final int daysLeft;
  final DateTime? trialEndsAt;
  final String? licenseKey;
}

/// Decides what a stored, already-verified token means right now.
///
/// Pure function: no clock, storage or network access, so it is easy to test.
/// Rules (the same ones the web portal documents):
///  * a token for another computer is worthless
///  * a licensed token never expires and ignores the clock
///  * a revoked or expired token stays that way until the server says otherwise
///  * a trial runs until `trialEndsAt`, measured on a clock that can't go back
///  * a trial token older than its `exp` must be refreshed online
LicenseEvaluation evaluateLicense({
  required LicenseToken? token,
  required String machineId,
  required DateTime now,
  required DateTime? lastSeen,
  Duration tolerance = LicenseConfig.clockTolerance,
}) {
  if (token == null || token.machineId != machineId) {
    return const LicenseEvaluation(LicenseStatus.unactivated);
  }
  final utcNow = now.toUtc();

  switch (token.status) {
    case TokenStatus.licensed:
      return LicenseEvaluation(
        LicenseStatus.licensed,
        licenseKey: token.licenseKey,
      );

    case TokenStatus.revoked:
      return const LicenseEvaluation(LicenseStatus.revoked);

    case TokenStatus.expired:
      return LicenseEvaluation(
        LicenseStatus.expired,
        trialEndsAt: token.trialEndsAt,
      );

    case TokenStatus.trial:
      // Clock turned back before the last time we heard from the server?
      final behindIssued = utcNow.isBefore(token.issuedAt.subtract(tolerance));
      final behindSeen =
          lastSeen != null && utcNow.isBefore(lastSeen.toUtc().subtract(tolerance));
      if (behindIssued || behindSeen) {
        return const LicenseEvaluation(LicenseStatus.clockError);
      }

      // The trial is over: that is true no matter how old the token is.
      if (!utcNow.isBefore(token.trialEndsAt)) {
        return LicenseEvaluation(
          LicenseStatus.expired,
          trialEndsAt: token.trialEndsAt,
        );
      }

      // Still inside the trial, but the token is too old to trust: the admin
      // may have changed things since, so ask the server again.
      final expiresAt = token.expiresAt;
      if (expiresAt != null && utcNow.isAfter(expiresAt)) {
        return const LicenseEvaluation(LicenseStatus.unactivated);
      }

      final seconds = token.trialEndsAt.difference(utcNow).inSeconds;
      return LicenseEvaluation(
        LicenseStatus.trial,
        daysLeft: (seconds / Duration.secondsPerDay).ceil(),
        trialEndsAt: token.trialEndsAt,
      );
  }
}
