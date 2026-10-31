// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../l10n/gen/app_localizations.dart';

class PendingCard extends StatelessWidget {
  const PendingCard({super.key, required this.busy, required this.onCheck});

  final bool busy;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.licensePaymentPendingTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.licensePaymentPendingBody),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy ? null : onCheck,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.licenseCheckAgain),
          ),
        ],
      ),
    );
  }
}
