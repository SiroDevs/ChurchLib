import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../../core/theme/theme_colors.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_rounded, size: 56, color: ThemeColors.error),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(backgroundColor: ThemeColors.primary),
          child: const Text('Retry'),
        ),
      ],
    )
        .padding(all: 32);
  }
}
