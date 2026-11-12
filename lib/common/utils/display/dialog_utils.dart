// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/theme/theme_colors.dart';
import '../../../l10n/gen/app_localizations.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: ThemeColors.error)
                : null,
            child: Text(confirmLabel ?? l10n.continueAction),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
