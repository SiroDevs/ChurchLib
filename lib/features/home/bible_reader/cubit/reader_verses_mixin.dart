part of 'bible_reader_cubit.dart';

mixin ReaderVersesMixin on Cubit<BibleReaderState> {
  BibleRepo get _bibleRepo;
  BibleTrackingRepo get _tracking;
  BibleAnnotationRepo get _annotations;
  PrefRepo get _prefs;
  bool get _isFirstLoad;
  set _isFirstLoad(bool value);
  Future<void> initialize({
    String initialBibleAbbr = '',
    String initialBookId = '',
    String initialChapterId = '',
    String initialVerseId = '',
    String initialSearchQry = '',
    bool resumePosition = true,
  });

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
}
