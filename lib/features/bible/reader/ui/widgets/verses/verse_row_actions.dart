// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';

/// Note and bookmark buttons of a verse. Saved ones always show; the others
/// fade in over the end of the row while hovering, so the verse text can use
/// the full width instead of leaving a gap for them.
class VerseActions extends StatelessWidget {
  const VerseActions({
    super.key,
    required this.hovering,
    required this.selectionMode,
    required this.hasNote,
    required this.isBookmarked,
    required this.bookmarkColor,
    required this.onOpenNote,
    required this.onToggleBookmark,
  });

  static const double _noteWidth = 34, _bookmarkWidth = 36;

  /// Width the text must leave free for the buttons that are always visible.
  static double reservedWidth({
    required bool hasNote,
    required bool isBookmarked,
  }) => (hasNote ? _noteWidth : 0) + (isBookmarked ? _bookmarkWidth : 0);

  final bool hovering;
  final bool selectionMode;
  final bool hasNote;
  final bool isBookmarked;
  final Color? bookmarkColor;
  final VoidCallback onOpenNote;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final showNote = hasNote || (hovering && !selectionMode);
    final showBookmark = isBookmarked || hovering;
    if (!showNote && !showBookmark) return const SizedBox.shrink();

    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showNote)
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: hasNote ? 'Edit note' : 'Add note',
            onPressed: onOpenNote,
            icon: Icon(
              hasNote ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
              color: hasNote ? ThemeColors.primary : ThemeColors.mediumGrey,
            ),
          ),
        if (showBookmark)
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 20,
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark verse',
            onPressed: onToggleBookmark,
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked
                  ? (bookmarkColor ?? ThemeColors.primary)
                  : ThemeColors.mediumGrey,
            ),
          ),
      ],
    );
    if (!hovering) return buttons;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: buttons,
    );
  }
}
