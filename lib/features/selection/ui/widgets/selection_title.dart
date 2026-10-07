// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';

class SelectionTitle extends StatelessWidget {
  final String title;
  final String noun;
  final int count;
  final int max;

  const SelectionTitle({
    super.key,
    required this.title,
    required this.noun,
    required this.count,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Text.rich(
      TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ThemeColors.primary,
        ),
        children: [
          TextSpan(
            text: ' · ',
            style: TextStyle(fontSize: 24, color: onSurface),
          ),
          TextSpan(
            text: '$count out of $max $noun selected',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
        ],
      ),
    );
  }
}