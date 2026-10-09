// Flutter imports:
import 'package:flutter/material.dart';

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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Multi-Bible Reader', style: TextStyle(fontSize: 16)),
                  Text(
                    'Read parallel translations alongside your primary text',
                    style: TextStyle(fontSize: 11, color: soft),
                  ),
                ],
              ),
            ),
            Switch(value: enabled, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
