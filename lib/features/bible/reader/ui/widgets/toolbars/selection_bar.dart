// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';
import '../../../cubit/bible_reader_cubit.dart';
import '../dialogs/export.dart';

class SelectionBar extends StatelessWidget {
  final BibleReaderState state;
  const SelectionBar({super.key, required this.state});

  Future<void> _bookmark(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final color = await showHighlightColorPicker(context);
    if (color == null || !context.mounted) return;
    cubit.chooseHighlightColor(color);

    final choice = await showBookmarkOptionsDialog(context);
    if (!context.mounted) return;
    switch (choice) {
      case BookmarkChoice.bookmarkOnly:
        await cubit.confirmBookmarkOnly();
      case BookmarkChoice.withNotes:
        final request = await cubit.confirmBookmarkWithNotes();
        if (request != null && context.mounted) {
          await showNoteEditor(context, request);
          await cubit.refreshNotedVerses();
        }
      case null:
        cubit.cancelPendingHighlight();
    }
  }

  Future<void> _notes(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final request = cubit.openNotesForSelection();
    if (request == null) return;
    await showNoteEditor(context, request);
    await cubit.refreshNotedVerses();
  }

  Future<void> _copy(BuildContext context) async {
    final text = context.read<BibleReaderCubit>().buildSelectionShareText();
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BibleReaderCubit>();
    final count = state.selectedVerseIds.length;
    return Material(
      color: ThemeColors.primary.withValues(alpha: 0.14),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Cancel selection (Esc)',
              onPressed: cubit.clearSelection,
              icon: const Icon(Icons.close),
            ),
            Text(
              '$count selected',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Bookmark / highlight',
              onPressed: () => _bookmark(context),
              icon: const Icon(Icons.bookmark_rounded),
            ),
            IconButton(
              tooltip: count == 1 ? 'Add note' : 'Select a single verse to add a note',
              onPressed: count == 1 ? () => _notes(context) : null,
              icon: const Icon(Icons.edit_note),
            ),
            IconButton(
              tooltip: 'Copy',
              onPressed: () => _copy(context),
              icon: const Icon(Icons.content_copy),
            ),
          ],
        ),
      ),
    );
  }
}
