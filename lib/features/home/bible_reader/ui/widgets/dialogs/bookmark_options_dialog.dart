// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../l10n/gen/app_localizations.dart';

enum BookmarkChoice { bookmarkOnly, withNotes }

Future<BookmarkChoice?> showBookmarkOptionsDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<BookmarkChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.bookmarkVerses),
      content: Text(l10n.bookmarkOptionsPrompt),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, BookmarkChoice.bookmarkOnly),
          child: Text(l10n.bookmarkOnly),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, BookmarkChoice.withNotes),
          style: FilledButton.styleFrom(backgroundColor: ThemeColors.primary),
          child: Text(l10n.bookmarkWithNotes),
        ),
      ],
    ),
  );
}
