// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../l10n/gen/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.copyTextToClipboard),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BibleReaderCubit>();
    final l10n = AppLocalizations.of(context)!;
    final count = state.selectedVerseIds.length;
    return Material(
      color: ThemeColors.primary.withValues(alpha: 0.14),
      elevation: 1,
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.cancelVerseSelection,
            onPressed: cubit.clearSelection,
            icon: const Icon(Icons.close),
          ),
          Text(
            l10n.selectedCount(count),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            tooltip: l10n.bookmarkHighlight,
            onPressed: () => _bookmark(context),
            icon: const Icon(Icons.bookmark_rounded),
          ),
          IconButton(
            tooltip: count == 1
                ? l10n.addNoteAction
                : l10n.selectSingleVerseNote,
            onPressed: count == 1 ? () => _notes(context) : null,
            icon: const Icon(Icons.edit_note),
          ),
          IconButton(
            tooltip: l10n.copyAction,
            onPressed: () => _copy(context),
            icon: const Icon(Icons.content_copy),
          ),
        ],
      ).padding(horizontal: 12, vertical: 6),
    );
  }
}
