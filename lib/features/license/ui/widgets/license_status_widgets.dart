// Flutter imports:
import 'package:flutter/material.dart';

/// Heading and description shown in a license status screen.
class LicenseHeading extends StatelessWidget {
  const LicenseHeading({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(body, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

/// Status message and actions shown on the license screen.
class LicenseMessage extends StatelessWidget {
  const LicenseMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 40, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        for (final action in actions) ...[action, const SizedBox(height: 8)],
      ],
    );
  }
}

/// Busy indicator and label shown while checking a license.
class LicenseBusy extends StatelessWidget {
  const LicenseBusy({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
