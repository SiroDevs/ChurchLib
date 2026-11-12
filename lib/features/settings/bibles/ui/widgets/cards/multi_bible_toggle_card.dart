// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../l10n/gen/app_localizations.dart';

class MultiBibleToggleCard extends StatelessWidget {
  const MultiBibleToggleCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final soft = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.multiBibleReader, style: const TextStyle(fontSize: 16)),
            Text(
              l10n.multiBibleDescription,
              style: TextStyle(fontSize: 11, color: soft),
            ),
          ],
        ).expanded(),
        Switch(value: enabled, onChanged: onChanged),
      ],
    ).padding(horizontal: 16, vertical: 12).card(margin: EdgeInsets.zero);
  }
}
