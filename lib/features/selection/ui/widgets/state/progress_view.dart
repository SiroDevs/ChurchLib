
import 'package:flutter/material.dart';

import '../../../../../common/utils/constants/app_assets.dart';
import '../../../../../core/theme/theme_colors.dart';
import 'progress_rings.dart';
import '../../../../../common/utils/constants/app_constants.dart';

class ProgressView extends StatelessWidget {
  final String title;
  final String message;
  final int? percent;
  final String ringLabel;
  final bool isError;
  final List<Widget> actions;

  const ProgressView({
    super.key,
    required this.title,
    this.message = '',
    this.percent,
    this.ringLabel = '',
    this.isError = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final determinate = !isError && percent != null;
    return Material(
      color: determinate
          ? Colors.black
          : Theme.of(context).scaffoldBackgroundColor,
      child: isError
          ? _error()
          : determinate
              ? _determinate(context, percent!.clamp(0, 100))
              : _indeterminate(),
    );
  }

  Widget _determinate(BuildContext context, int progress) {
    final size = MediaQuery.of(context).size;
    final radius = isDesktop ? size.height / 2.5 : size.width / 2.5;
    return Stack(
      children: [
        BackgroundProgress(size: size, progress: progress),
        ForegroundProgress(
          progress: progress,
          radius: radius,
          feedback: ringLabel,
        ),
        Positioned(
          left: 24,
          right: 24,
          top: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (message.isNotEmpty)
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _indeterminate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.iconApp, height: 96, width: 96),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: ThemeColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: ThemeColors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _error() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: ThemeColors.error),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}
