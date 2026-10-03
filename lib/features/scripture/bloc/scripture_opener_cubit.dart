// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../common/utils/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../data/models/bible/bible_book.dart';
import '../../../data/models/bible/bible_chapter.dart';
import '../../../data/models/bible/scripture_item.dart';
import '../../../domain/repos/bible/bible_repo.dart';
import '../../../domain/repos/bible/scripture_repo.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../bible_reader/bloc/reader_cubit.dart' show ReaderTarget;
import 'scripture_queue_cubit.dart';
import 'scripture_search_row_state.dart';

const _unset = Object();

class ScriptureOpenerState {
  final bool isLoading;
  final String? error;
  final String bibleAbbr;
  final String bibleName;
  final List<ScriptureSearchRowState> rows;

  const ScriptureOpenerState({
    this.isLoading = true,
    this.error,
    this.bibleAbbr = '',
    this.bibleName = '',
    this.rows = const [],
  });

  /// The one unlocked row — where the user is currently building a
  /// reference. Ported from Android's `activeRow`.
  ScriptureSearchRowState? get activeRow =>
      rows.where((r) => !r.locked).lastOrNull;

  ScriptureOpenerState copyWith({
    bool? isLoading,
    Object? error = _unset,
    String? bibleAbbr,
    String? bibleName,
    List<ScriptureSearchRowState>? rows,
  }) {
    return ScriptureOpenerState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      bibleAbbr: bibleAbbr ?? this.bibleAbbr,
      bibleName: bibleName ?? this.bibleName,
      rows: rows ?? this.rows,
    );
  }
}

/// Ported from biblelib-android's `ScriptureOpenerViewModel`. Builds a
/// queue of book/chapter/verse references, one row per scripture, and
/// either opens the first one immediately or saves the whole queue as a
/// named [ScriptureList] for the reader's floating queue widget.
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

  /// Opens the searched scripture right away, without touching the saved
  /// queue.
  ReaderTarget? openScripture(String rowKey) {
    final row = state.rows.where((r) => r.key == rowKey).firstOrNull;
    if (row == null || !row.isComplete) return null;
    final target = _buildTarget(row);
    if (target == null) return null;
    _prefs.setPrefString(PrefConstants.bibleLastVerseIdKey, target.verseId);
    return target;
  }

  /// Locks the current row into the queue and reveals a fresh blank row
  /// beneath it.
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

  /// Locks + persists the queue. Returns true on success, so the screen
  /// can close and return to the reader exactly as it was.
  Future<bool> addToQueueAndClose(String rowKey) async {
    final row = state.rows.where((r) => r.key == rowKey).firstOrNull;
    if (row == null || !row.isComplete) return false;
    final items = await _persistQueue(includingRowKey: rowKey);
    return items.isNotEmpty;
  }

  /// Locks + persists the queue, then returns a target for the first
  /// scripture in it.
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

  /// Builds the full item list (all locked rows + the given row), saves
  /// it, and opens it in [ScriptureQueueCubit] so the reader's floating
  /// widget picks it up.
  Future<List<ScriptureItem>> _persistQueue({required String includingRowKey}) async {
    final completedRows =
        state.rows.where((r) => r.locked || r.key == includingRowKey).toList();
    final items = <ScriptureItem>[
      for (var i = 0; i < completedRows.length; i++)
        if (_buildItem(completedRows[i], i) case final item?) item,
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

  ScriptureItem? _buildItem(ScriptureSearchRowState row, int order) {
    final book = row.selectedBook;
    final chapter = row.selectedChapter;
    final verseNumber = row.selectedVerseNumber;
    final verseId = row.selectedVerseId;
    if (book == null || chapter == null || verseNumber == null || verseId == null) {
      return null;
    }
    return ScriptureItem(
      listId: 0,
      bibleAbbr: state.bibleAbbr,
      bibleName: state.bibleName,
      bookId: book.id,
      bookName: book.name,
      bookAbbr: book.abbreviation,
      chapterId: chapter.id,
      chapterNumber: chapter.number,
      verseId: verseId,
      verseNumber: verseNumber,
      reference: '${book.name} ${chapter.number}:$verseNumber',
      sortOrder: order,
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  ReaderTarget? _buildTarget(ScriptureSearchRowState row) {
    final book = row.selectedBook;
    final chapter = row.selectedChapter;
    final verseId = row.selectedVerseId;
    if (book == null || chapter == null || verseId == null) return null;
    return ReaderTarget(
      bibleAbbr: state.bibleAbbr,
      bookId: book.id,
      chapterId: chapter.id,
      verseId: verseId,
    );
  }
}
