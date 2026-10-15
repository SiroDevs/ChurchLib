// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project imports:
import '../../../../common/utils/display/dialog_utils.dart';
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../common/windows/open_windows.dart';
import '../../../../core/license/license_cubit.dart';
import '../../../../domain/entities/license/exports.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/settings_card.dart';
import 'license_widgets.dart';

/// Settings > License.
class LicenseSection extends StatelessWidget {
  const LicenseSection({super.key});

  static final DateFormat _date = DateFormat('d MMM y', 'en');

  String _title(AppLocalizations l10n, LicenseState s) {
    switch (s.status) {
      case LicenseStatus.trial:
        return l10n.licenseTrialActive;
      case LicenseStatus.licensed:
        return l10n.licenseStatusLicensed;
      case LicenseStatus.developer:
        return l10n.licenseDeveloperBuild;
      case LicenseStatus.expired:
        return l10n.licenseTrialEndedTitle;
      case LicenseStatus.revoked:
        return l10n.licenseRevokedTitle;
      case LicenseStatus.clockError:
        return l10n.licenseClockTitle;
      case LicenseStatus.notConfigured:
        return l10n.licenseNotConfigured;
      case LicenseStatus.unactivated:
      case LicenseStatus.checking:
        return l10n.licenseChecking;
    }
  }

  String? _subtitle(AppLocalizations l10n, LicenseState s) {
    if (s.status == LicenseStatus.trial) {
      return daysLeftLabel(l10n, s.daysLeft);
    }
    if (s.status == LicenseStatus.licensed && s.licensedAt != null) {
      return l10n.licenseSince(_date.format(s.licensedAt!.toLocal()));
    }
    return null;
  }

  IconData _icon(LicenseStatus status) {
    switch (status) {
      case LicenseStatus.licensed:
        return Icons.verified_rounded;
      case LicenseStatus.trial:
        return Icons.hourglass_bottom_rounded;
      case LicenseStatus.developer:
        return Icons.code;
      default:
        return Icons.lock_outline_rounded;
    }
  }

  Future<void> _check(BuildContext context) async {
    final outcome = await context.read<LicenseCubit>().refresh();
    if (!context.mounted || outcome.ok) return;
    CustomSnackbar.show(context, outcome.message ?? '');
  }

  Future<void> _release(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<LicenseCubit>();
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.licenseMoveTitle,
      message: l10n.licenseMoveConfirm,
      confirmLabel: l10n.licenseRelease,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final outcome = await cubit.releaseThisComputer();
    if (!context.mounted) return;
    if (!outcome.ok) {
      CustomSnackbar.show(context, outcome.message ?? '');
      return;
    }
    // The app may now be locked: close this window so the lock screen shows.
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LicenseCubit, LicenseState>(
      builder: (context, s) {
        final subtitle = _subtitle(l10n, s);
        final canBuy = s.status != LicenseStatus.licensed &&
            s.status != LicenseStatus.developer;
        final lastChecked = s.lastCheckedAt == null
            ? l10n.licenseNeverChecked
            : l10n.licenseLastChecked(timeago.format(s.lastCheckedAt!));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingCard(
              title: l10n.licenseTitle,
              widgets: [
                ListTile(
                  leading: Icon(_icon(s.status)),
                  title: Text(_title(l10n, s)),
                  subtitle: subtitle == null ? null : Text(subtitle),
                  trailing: canBuy
                      ? FilledButton(
                          onPressed: () => openPurchase(context),
                          child: Text(l10n.licenseBuy),
                        )
                      : null,
                ),
                if (s.licenseKey != null)
                  ListTile(
                    leading: const Icon(Icons.key_rounded),
                    title: Text(l10n.licenseKeyLabel),
                    subtitle: CopyValue(value: s.licenseKey!),
                  ),
                ListTile(
                  leading: const Icon(Icons.computer_rounded),
                  title: Text(l10n.licenseComputerId),
                  subtitle: CopyValue(value: s.computerId),
                ),
                ListTile(
                  leading: s.busy
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  title: Text(l10n.licenseCheckNow),
                  subtitle: Text(lastChecked),
                  onTap: s.busy ? null : () => _check(context),
                ),
              ],
            ),
            if (s.status == LicenseStatus.licensed)
              SettingCard(
                title: l10n.licenseMoveTitle,
                widgets: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz_rounded),
                    title: Text(l10n.licenseMoveTitle),
                    subtitle: Text(l10n.licenseMoveDesc),
                    onTap: s.busy ? null : () => _release(context),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
