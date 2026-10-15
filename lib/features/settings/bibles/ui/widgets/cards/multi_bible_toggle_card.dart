// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

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
    final soft = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multi-Bible Reader', style: TextStyle(fontSize: 16)),
            Text(
              'Read parallel translations alongside your primary text',
              style: TextStyle(fontSize: 11, color: soft),
            ),
          ],
        )
            .expanded(),
        Switch(value: enabled, onChanged: onChanged),
      ],
    )
        .padding(horizontal: 16, vertical: 12)
        .card(margin: EdgeInsets.zero);
  }
}
