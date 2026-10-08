// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../common/utils/constants/pref_constants.dart';
import '../../../../../core/di/injectable.dart';
import '../../../../../data/models/bible/bible_book.dart';
import '../../../../../data/models/bible/bible_chapter.dart';
import '../../../../../data/models/bible/scripture_item.dart';
import '../../../../../domain/entities/bible/bible_reader.dart';
import '../../../../../domain/entities/bible/verse_display.dart';
import '../../../../../domain/repos/bible/bible_repo.dart';
import '../../../../../domain/repos/bible/scripture_repo.dart';
import '../../../../../domain/repos/pref_repo.dart';
import '../../scripture_queue/cubit/scripture_queue_cubit.dart';

part 'scripture_opener_state.dart';
part 'scripture_search_row_state.dart';

const _unset = Object();

class ScriptureOpenerCubit extends Cubit<ScriptureOpenerState> {
  ScriptureOpenerCubit() : super(const ScriptureOpenerState());

  final _bibleRepo = getIt<BibleRepo>();
  final _scriptureRepo = getIt<ScriptureRepo>();
  final _queue = getIt<ScriptureQueueCubit>();
  final _prefs = getIt<PrefRepo>();

  Future<void> initialize(String bibleAbbr, String bibleName) async {
    if (state.bibleAbbr == bibleAbbr && state.rows.isNotEmpty) return;
    emit(state.copyWith(
      isLoading: true,
      error: null,
      bibleAbbr: bibleAbbr,
      bibleName: bibleName,
    ));
    final books = await _bibleRepo.getLocalBooks(bibleAbbr);
    if (books.isEmpty) {
      emit(state.copyWith(isLoading: false, error: 'No books found for this Bible.'));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      rows: [ScriptureSearchRowState(books: books)],
    ));
  }

  void _updateRow(
    String rowKey,
    ScriptureSearchRowState Function(ScriptureSearchRowState) transform,
  ) {
    emit(state.copyWith(
      rows: [for (final r in state.rows) r.key == rowKey ? transform(r) : r],
    ));
  }

  void toggleField(String rowKey, ExpandedField field) {
    _updateRow(rowKey, (row) {
      if (row.locked) return row;
      final allowed = switch (field) {
        ExpandedField.book => true,
        ExpandedField.chapter => row.canExpandChapter,
        ExpandedField.verse => row.canExpandVerse,
        ExpandedField.none => true,
      };
      if (!allowed) return row;
      return row.copyWith(
        expanded: row.expanded == field ? ExpandedField.none : field,
      );
    });
  }

  void closeResults(String rowKey) =>
      _updateRow(rowKey, (row) => row.copyWith(expanded: ExpandedField.none));

  Future<void> selectBook(String rowKey, BibleBook book) async {
    _updateRow(rowKey, (row) => row.copyWith(
          selectedBook: book,
          selectedChapter: null,
          chapters: const [],
          selectedVerseNumber: null,
          verses: const [],
          isLoadingChapters: true,
          expanded: ExpandedField.chapter,
        ));
    final chapters = await _bibleRepo.getLocalChapters(state.bibleAbbr, book.id);
    _updateRow(rowKey, (row) => row.copyWith(
          chapters: chapters,
          isLoadingChapters: false,
        ));
  }

  Future<void> selectChapter(String rowKey, BibleChapter chapter) async {
    _updateRow(rowKey, (row) => row.copyWith(
          selectedChapter: chapter,
          selectedVerseNumber: null,
          verses: const [],
          isLoadingVerses: true,
          expanded: ExpandedField.verse,
        ));
    final verses = await _bibleRepo.getLocalVerses(state.bibleAbbr, chapter.id) ?? [];
    _updateRow(rowKey, (row) => row.copyWith(verses: verses, isLoadingVerses: false));
  }

  void selectVerse(String rowKey, int number) {
    _updateRow(rowKey, (row) => row.copyWith(
          selectedVerseNumber: number,
          expanded: ExpandedField.none,
        ));
  }

  ReaderTarget? openScripture(String rowKey) {
    final row = state.rows.where((r) => r.key == rowKey).firstOrNull;
    if (row == null || !row.isComplete) return null;
    final target = row.toTarget(state.bibleAbbr);
    if (target == null) return null;
    _prefs.setPrefString(PrefConstants.bibleLastVerseIdKey, target.verseId);
    return target;
  }

  void addToQueue(String rowKey) {
    final row = state.rows.where((r) => r.key == rowKey).firstOrNull;
    if (row == null || !row.isComplete) return;
    emit(state.copyWith(
      rows: [
        for (final r in state.rows)
          r.key == rowKey
              ? r.copyWith(locked: true, expanded: ExpandedField.none)
              : r,
        ScriptureSearchRowState(books: row.books),
      ],
    ));
  }

  Future<bool> addToQueueAndClose(String rowKey) async {
    final row = state.rows.where((r) => r.key == rowKey).firstOrNull;
    if (row == null || !row.isComplete) return false;
    final items = await _persistQueue(includingRowKey: rowKey);
    return items.isNotEmpty;
  }

  Future<ReaderTarget?> addToQueueAndFinish(String rowKey) async {
    final row = state.rows.where((r) => r.key == rowKey).firstOrNull;
    if (row == null || !row.isComplete) return null;
    final items = await _persistQueue(includingRowKey: rowKey);
    if (items.isEmpty) return null;
    final first = items.first;
    _prefs.setPrefString(PrefConstants.bibleLastVerseIdKey, first.verseId);
    return ReaderTarget(
      bibleAbbr: first.bibleAbbr,
      bookId: first.bookId,
      chapterId: first.chapterId,
      verseId: first.verseId,
    );
  }

  Future<List<ScriptureItem>> _persistQueue({required String includingRowKey}) async {
    final completedRows =
        state.rows.where((r) => r.locked || r.key == includingRowKey).toList();
    final items = <ScriptureItem>[
      for (var i = 0; i < completedRows.length; i++)
        if (completedRows[i].toItem(state.bibleAbbr, state.bibleName, i)
            case final item?)
          item,
    ];
    if (items.isEmpty) return const [];

    final listId = await _scriptureRepo.saveList(items);
    final saved = await _scriptureRepo.getItems(listId);
    final list = await _scriptureRepo.getList(listId);
    _queue.open(
      listId,
      list?.name ?? saved.first.reference,
      saved,
    );
    return saved;
  }
}
