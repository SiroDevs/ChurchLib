// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';

class StepActionBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onBack;

  const StepActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          if (onBack != null) ...[
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}
