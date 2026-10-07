// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/reader_utils.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/bible_book.dart';
import '../../../../data/models/bible/bible_chapter.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../../../domain/entities/bible/verse_display.dart';
import '../../../../domain/repos/bible/bible_annotation_repo.dart';
import '../../../../domain/repos/bible/bible_repo.dart';
import '../../../../domain/repos/bible/bible_tracking_repo.dart';
import '../../../../domain/repos/pref_repo.dart';

part 'bible_reader_state.dart';

const _unset = Object();

class BibleReaderCubit extends Cubit<BibleReaderState> {
  BibleReaderCubit() : super(const BibleReaderState());

  final _bibleRepo = getIt<BibleRepo>();
  final _tracking = getIt<BibleTrackingRepo>();
  final _annotations = getIt<BibleAnnotationRepo>();
  final _prefs = getIt<PrefRepo>();

  bool _isFirstLoad = false;

  Future<void> initialize({
    String initialBibleAbbr = '',
    String initialBookId = '',
    String initialChapterId = '',
    String initialVerseId = '',
    String initialSearchQry = '',
    bool resumePosition = true,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final bibles = await _bibleRepo.getBibles();
      if (bibles.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'No Bibles downloaded yet.'));
        return;
      }

      final (:abbr, :name) = resolveReaderBible(
        bibles: bibles,
        requestedAbbr: initialBibleAbbr,
        lastAbbr: readerLastBibleAbbr(_prefs),
      );

      _isFirstLoad = resumePosition;

      emit(state.copyWith(
        savedBibles: bibles,
        activeBible: name,
        activeBibleAbbr: abbr,
        fontSize: readerStoredFontSize(_prefs),
        multiBibleReaderEnabled: readerMultiBibleEnabled(_prefs),
      ));

      await _loadBooks(
        abbr,
        initialBookId,
        initialChapterId,
        forceScrollToFirstVerse: !resumePosition && initialVerseId.isEmpty,
        scrollTarget: initialReaderScrollTarget(
          verseId: initialVerseId,
          searchQuery: initialSearchQry,
        ),
      );
    } catch (e) {
      logger('Reader initialize error: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _loadBooks(
    String abbr,
    String bookId,
    String chapterId, {
    bool forceScrollToFirstVerse = false,
    ScrollTarget? scrollTarget,
  }) async {
    final books = await _bibleRepo.getLocalBooks(abbr);
    if (books.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        error:
            'Bible data not available. Please wait for the download to complete.',
      ));
      return;
    }

    final resolvedBookId = bookId.isEmpty ? readerLastBookId(_prefs) : bookId;
    final resolvedChapterId =
        chapterId.isEmpty ? readerLastChapterId(_prefs) : chapterId;

    final targetBook = firstWhereOrFirst(books, (b) => b.id == resolvedBookId);
    emit(state.copyWith(books: books, activeBook: targetBook));

    await _loadChapters(
      abbr,
      targetBook,
      resolvedChapterId,
      forceScrollToFirstVerse: forceScrollToFirstVerse,
      scrollTarget: scrollTarget,
    );
  }

  Future<void> _loadChapters(
    String abbr,
    BibleBook book,
    String chapterId, {
    bool forceScrollToFirstVerse = false,
    ScrollTarget? scrollTarget,
  }) async {
    final chapters = await _bibleRepo.getLocalChapters(abbr, book.id);
    if (chapters.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        error: 'No chapters found for ${book.name}',
      ));
      return;
    }
    final target = firstWhereOrFirst(chapters, (c) => c.id == chapterId);
    emit(state.copyWith(chapters: chapters, activeChapter: target));

    await _loadVerses(
      abbr,
      target,
      scrollTarget: scrollTarget,
      forceScrollToFirstVerse: forceScrollToFirstVerse,
    );
  }

  Future<Map<String, List<VerseDisplay>>> _loadParallel(
    String primaryAbbr,
    String chapterId,
  ) async {
    if (!readerMultiBibleEnabled(_prefs)) return {};
    final abbrs = parallelBibleAbbrs(
      primaryAbbr: primaryAbbr,
      savedBibles: state.savedBibles,
      secondary: readerSecondaryBibles(_prefs),
    );

    final map = <String, List<VerseDisplay>>{};
    for (final s in abbrs) {
      final verses = await _bibleRepo.getLocalVerses(s, chapterId);
      if (verses != null) map[s] = verses;
    }
    return map;
  }

  Future<void> _loadVerses(
    String abbr,
    BibleChapter chapter, {
    ScrollTarget? scrollTarget,
    bool forceScrollToFirstVerse = false,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    final verses = await _bibleRepo.getLocalVerses(abbr, chapter.id);
    if (verses == null) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Verses not cached. Please ensure download is complete.',
      ));
      return;
    }

    final parallel = await _loadParallel(abbr, chapter.id);
    final bookmarks = await _annotations.getBookmarksForChapter(abbr, chapter.id);
    final noted = await _annotations.getNotedVerseIds(abbr, chapter.id);
    final target = resolveReaderScrollTarget(
      explicit: scrollTarget,
      forceFirst: forceScrollToFirstVerse,
      isFirstLoad: _isFirstLoad,
      lastVerseId: readerLastVerseId(_prefs),
      verses: verses,
    );
    _isFirstLoad = false;

    emit(state.copyWith(
      isLoading: false,
      verses: verses,
      parallelVerses: parallel,
      activeChapter: chapter,
      activeBibleAbbr: abbr,
      bookmarks: bookmarks,
      notedVerseIds: noted,
      selectedVerseIds: const {},
      pendingHighlightColor: null,
      multiBibleReaderEnabled: readerMultiBibleEnabled(_prefs),
      restoreVerseId: target?.verseId,
      highlightQuery: target?.highlightQuery,
    ));

    await _recordVersesLoaded(abbr, chapter, verses);
  }

  Future<void> _recordVersesLoaded(
    String abbr,
    BibleChapter chapter,
    List<VerseDisplay> verses,
  ) async {
    saveReaderPosition(
      _prefs,
      bibleAbbr: abbr,
      bookId: chapter.bookId,
      chapterId: chapter.id,
    );

    final book = state.activeBook;
    if (book == null) return;
    await recordReaderPosition(
      _tracking,
      bibleAbbr: abbr,
      bibleName: state.activeBible,
      book: book,
      chapter: chapter,
      verseNumber: verses.isEmpty ? 1 : verses.first.number,
    );
  }

  Future<void> onVerseScrollPositionChanged(
    String verseId,
    int verseNumber,
  ) async {
    final chapter = state.activeChapter;
    final book = state.activeBook;
    if (chapter == null || book == null) return;
    saveReaderLastVerseId(_prefs, verseId);
    await recordReaderPosition(
      _tracking,
      bibleAbbr: state.activeBibleAbbr,
      bibleName: state.activeBible,
      book: book,
      chapter: chapter,
      verseNumber: verseNumber,
    );
  }

  Future<void> openTarget(ReaderTarget target) {
    return initialize(
      initialBibleAbbr: target.bibleAbbr,
      initialBookId: target.bookId,
      initialChapterId: target.chapterId,
      initialVerseId: target.verseId,
      initialSearchQry: target.searchQuery,
      resumePosition: false,
    );
  }

  void consumeRestoreVerseTarget() =>
      emit(state.copyWith(restoreVerseId: null));

  void navigateChapter(int direction) {
    final current = state.activeChapter;
    if (current == null) return;
    final idx = state.chapters.indexWhere((c) => c.id == current.id);
    final nextIdx = idx + direction;
    if (idx < 0 || nextIdx < 0 || nextIdx >= state.chapters.length) return;
    selectChapter(state.chapters[nextIdx]);
  }

  Future<void> selectChapter(BibleChapter chapter, {ScrollTarget? scrollTarget}) {
    return _loadVerses(
      state.activeBibleAbbr,
      chapter,
      scrollTarget: scrollTarget,
      forceScrollToFirstVerse: scrollTarget == null,
    );
  }

  Future<void> selectBook(BibleBook book) async {
    emit(state.copyWith(
      activeBook: book,
      chapters: const [],
      verses: const [],
    ));
    await _loadChapters(
      state.activeBibleAbbr,
      book,
      '',
      forceScrollToFirstVerse: true,
    );
  }

  Future<void> setPrimaryBible(String abbr) async {
    final chapter = state.activeChapter;
    if (chapter == null) return;
    final name =
        firstWhereOrFirst(state.savedBibles, (b) => b.abbreviation == abbr).name;

    saveReaderPrimaryBible(_prefs, abbr: abbr, name: name);
    emit(state.copyWith(activeBible: name, activeBibleAbbr: abbr));

    await _loadVerses(abbr, chapter);
    await _loadBooks(abbr, state.activeBook?.id ?? '', chapter.id);
  }

  Future<void> setMultiBibleReaderEnabled(bool enabled) async {
    saveReaderMultiBibleEnabled(_prefs, enabled);
    emit(state.copyWith(multiBibleReaderEnabled: enabled));
    final chapter = state.activeChapter;
    if (chapter != null) await _loadVerses(state.activeBibleAbbr, chapter);
  }

  void setFontSize(int size) {
    final clamped = clampReaderFontSize(size);
    saveReaderFontSize(_prefs, clamped);
    emit(state.copyWith(fontSize: clamped));
  }

  Future<void> quickToggleBookmark(String verseId) async {
    final abbr = state.activeBibleAbbr;
    final bookId = state.activeBook?.id;
    final chapterId = state.activeChapter?.id;
    if (bookId == null || chapterId == null) return;

    if (state.bookmarks.containsKey(verseId)) {
      await _annotations.removeBookmarks(abbr, [verseId]);
      emit(state.copyWith(bookmarks: withoutBookmark(state.bookmarks, verseId)));
    } else {
      await _annotations.setBookmarks(abbr, [verseId], bookId, chapterId);
      emit(state.copyWith(bookmarks: withBookmarks(state.bookmarks, [verseId], null)));
    }
  }

  void toggleVerseSelected(String verseId) {
    emit(state.copyWith(
      selectedVerseIds: toggleVerseSelection(state.selectedVerseIds, verseId),
    ));
  }

  void clearSelection() => emit(state.copyWith(
        selectedVerseIds: const {},
        pendingHighlightColor: null,
      ));

  void chooseHighlightColor(String colorHex) =>
      emit(state.copyWith(pendingHighlightColor: colorHex));

  void cancelPendingHighlight() =>
      emit(state.copyWith(pendingHighlightColor: null));

  List<VerseDisplay> get _selectedVersesSorted =>
      selectedVersesSorted(state.verses, state.selectedVerseIds);

  NotesRequest _buildNotesRequest(VerseDisplay verse) => buildNotesRequest(
        bibleAbbr: state.activeBibleAbbr,
        verse: verse,
        book: state.activeBook,
        chapter: state.activeChapter,
      );

  NotesRequest? notesRequestForVerse(String verseId) {
    for (final v in state.verses) {
      if (v.verseId == verseId) return _buildNotesRequest(v);
    }
    return null;
  }

  NotesRequest? openNotesForSelection() {
    if (state.selectedVerseIds.length != 1) return null;
    final request = notesRequestForVerse(state.selectedVerseIds.first);
    if (request == null) return null;
    emit(state.copyWith(selectedVerseIds: const {}));
    return request;
  }

  Future<void> _applyHighlight() async {
    final color = state.pendingHighlightColor;
    final bookId = state.activeBook?.id;
    final chapterId = state.activeChapter?.id;
    if (color == null || bookId == null || chapterId == null) return;
    final ids = state.selectedVerseIds;
    await _annotations.setBookmarks(
      state.activeBibleAbbr,
      ids,
      bookId,
      chapterId,
      colorHex: color,
    );
    emit(state.copyWith(
      bookmarks: withBookmarks(state.bookmarks, ids, color),
      selectedVerseIds: const {},
      pendingHighlightColor: null,
    ));
  }

  Future<void> confirmBookmarkOnly() => _applyHighlight();

  Future<NotesRequest?> confirmBookmarkWithNotes() async {
    final selected = _selectedVersesSorted;
    if (selected.isEmpty || state.pendingHighlightColor == null) return null;
    final request = _buildNotesRequest(selected.first);
    await _applyHighlight();
    return request;
  }

  Future<void> refreshNotedVerses() async {
    final chapterId = state.activeChapter?.id;
    if (chapterId == null) return;
    final noted = await _annotations.getNotedVerseIds(
      state.activeBibleAbbr,
      chapterId,
    );
    emit(state.copyWith(notedVerseIds: noted));
  }

  String? buildSelectionShareText() => buildVerseSelectionShareText(
        selected: _selectedVersesSorted,
        chapterVerses: state.verses,
        book: state.activeBook,
        chapter: state.activeChapter,
        bibleName: state.activeBible,
        language: state.activeBibleLanguage,
      );

  String? buildActiveChapterShareText() => buildChapterShareText(
        chapterVerses: state.verses,
        book: state.activeBook,
        chapter: state.activeChapter,
        bibleName: state.activeBible,
        language: state.activeBibleLanguage,
      );
}
