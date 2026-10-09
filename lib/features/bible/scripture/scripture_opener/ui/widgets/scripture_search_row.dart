// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../cubit/scripture_opener_cubit.dart';
import 'book_results_grid.dart';
import 'field_pointer_arrow.dart';
import 'locked_scripture_row.dart';
import 'number_results_grid.dart';
import 'scripture_action_buttons.dart';
import 'scripture_field.dart';

class ScriptureSearchRow extends StatelessWidget {
  const ScriptureSearchRow({
    super.key,
    required this.row,
    required this.isActive,
    required this.cubit,
    required this.onOpen,
    required this.onQueueAndClose,
    required this.onQueueAndFinish,
  });

  final ScriptureSearchRowState row;
  final bool isActive;
  final ScriptureOpenerCubit cubit;
  final VoidCallback onOpen;
  final VoidCallback onQueueAndClose;
  final VoidCallback onQueueAndFinish;

  Widget _loading() => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _field(
    int flex,
    String label,
    String value,
    bool enabled,
    ExpandedField field,
  ) =>
      Expanded(
        flex: flex,
        child: ScriptureField(
          label: label,
          value: value,
          enabled: enabled,
          isActive: row.expanded == field,
          onTap: () => cubit.toggleField(row.key, field),
        ),
      );

  Widget _panel(BuildContext context) {
    switch (row.expanded) {
      case ExpandedField.book:
        return BookResultsGrid(
          books: row.books,
          selectedBookId: row.selectedBook?.id,
          onSelect: (book) => cubit.selectBook(row.key, book),
        );
      case ExpandedField.chapter:
        if (row.isLoadingChapters) return _loading();
        return NumberResultsGrid(
          fieldIndex: fieldIndexChapter,
          labels: [for (final c in row.chapters) c.number],
          selectedIndex: row.chapters.indexWhere(
            (c) => c.id == row.selectedChapter?.id,
          ),
          onSelect: (i) => cubit.selectChapter(row.key, row.chapters[i]),
        );
      case ExpandedField.verse:
        if (row.isLoadingVerses) return _loading();
        return NumberResultsGrid(
          fieldIndex: fieldIndexVerse,
          labels: [for (var i = 1; i <= row.verses.length; i++) '$i'],
          selectedIndex: row.selectedVerseNumber == null
              ? null
              : row.selectedVerseNumber! - 1,
          onSelect: (i) => cubit.selectVerse(row.key, i + 1),
        );
      case ExpandedField.none:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (row.locked) return LockedScriptureRow(row: row);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              _field(fieldWeights[0], 'Book', row.bookLabel, true,
                  ExpandedField.book),
              const SizedBox(width: 8),
              _field(fieldWeights[1], 'Chapter', row.chapterLabel,
                  row.canExpandChapter, ExpandedField.chapter),
              const SizedBox(width: 8),
              _field(fieldWeights[2], 'Verse', row.verseLabel,
                  row.canExpandVerse, ExpandedField.verse),
            ],
          ),
          if (row.expanded != ExpandedField.none)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _panel(context),
            ),
          if (isActive && row.isComplete && row.expanded == ExpandedField.none)
            ScriptureActionButtons(
              reference: row.reference,
              onOpenScripture: onOpen,
              onAddToQueue: () => cubit.addToQueue(row.key),
              onAddToQueueAndClose: onQueueAndClose,
              onAddToQueueAndFinish: onQueueAndFinish,
            ),
        ],
      ),
    );
  }
}
