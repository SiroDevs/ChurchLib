// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';

enum BookmarkChoice { bookmarkOnly, withNotes }

Future<BookmarkChoice?> showBookmarkOptionsDialog(BuildContext context) {
  return showDialog<BookmarkChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Bookmark verses'),
      content: const Text(
        'Would you like to just bookmark these verses, or also add a note?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, BookmarkChoice.bookmarkOnly),
          child: const Text('Bookmark only'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, BookmarkChoice.withNotes),
          style: FilledButton.styleFrom(backgroundColor: ThemeColors.primary),
          child: const Text('Bookmark with notes'),
        ),
      ],
    ),
  );
}
