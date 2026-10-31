// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/windows/open_windows.dart';
import '../../../../core/license/license_cubit.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/entities/license/exports.dart';
import '../../../../l10n/gen/app_localizations.dart';
import 'license_widgets.dart';

class LicenseBanner extends StatelessWidget {
  const LicenseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LicenseCubit, LicenseState>(
      builder: (context, state) {
        final isTrial = state.status == LicenseStatus.trial;
        final isOver = state.status == LicenseStatus.expired ||
            state.status == LicenseStatus.revoked;
        if (!isTrial && !isOver) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context)!;
        final scheme = Theme.of(context).colorScheme;
        final urgent = isOver || state.daysLeft <= 2;
        final accent = isOver ? ThemeColors.error : ThemeColors.trafficAmber;

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (urgent ? accent : scheme.primary).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (urgent ? accent : scheme.primary).withValues(alpha: .5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTrial) ...[
                Text(
                  l10n.licenseTrialActive,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(daysLeftLabel(l10n, state.daysLeft)),
              ] else
                Text(l10n.licenseTrialEndedBanner),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => openPurchase(context),
                  child: Text(l10n.licenseBuy),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
