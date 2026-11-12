part of 'bible_reader_cubit.dart';

mixin ReaderLoadingMixin on Cubit<BibleReaderState> {
  BibleRepo get _bibleRepo;
  PrefRepo get _prefs;
  int _startLoadRequest();
  bool _isCurrentLoadRequest(int requestId);
  set _isFirstLoad(bool value);
  Future<void> _loadVerses(
    String abbr,
    BibleChapter chapter, {
    required int requestId,
    ScrollTarget? scrollTarget,
    bool forceScrollToFirstVerse = false,
  });

  Future<void> initialize({
    String initialBibleAbbr = '',
    String initialBookId = '',
    String initialChapterId = '',
    String initialVerseId = '',
    String initialSearchQry = '',
    bool resumePosition = true,
  }) async {
    final requestId = _startLoadRequest();
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final bibles = await _bibleRepo.getBibles();
      if (!_isCurrentLoadRequest(requestId)) return;
      if (bibles.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'noBiblesDownloaded'));
        return;
      }

      final (:abbr, :name) = resolveReaderBible(
        bibles: bibles,
        requestedAbbr: initialBibleAbbr,
        lastAbbr: readerLastBibleAbbr(_prefs),
      );

      _isFirstLoad = resumePosition;

      emit(
        state.copyWith(
          savedBibles: bibles,
          activeBible: name,
          activeBibleAbbr: abbr,
          fontSize: readerStoredFontSize(_prefs),
          multiBibleReaderEnabled: readerMultiBibleEnabled(_prefs),
        ),
      );

      await _loadBooks(
        abbr,
        initialBookId,
        initialChapterId,
        requestId: requestId,
        forceScrollToFirstVerse: !resumePosition && initialVerseId.isEmpty,
        scrollTarget: initialReaderScrollTarget(
          verseId: initialVerseId,
          searchQuery: initialSearchQry,
        ),
      );
    } catch (e) {
      if (!_isCurrentLoadRequest(requestId)) return;
      logger('Reader initialize error: $e');
      emit(state.copyWith(isLoading: false, error: 'readerLoadFailed'));
    }
  }

  Future<void> _loadBooks(
    String abbr,
    String bookId,
    String chapterId, {
    required int requestId,
    bool forceScrollToFirstVerse = false,
    ScrollTarget? scrollTarget,
  }) async {
    final books = await _bibleRepo.getLocalBooks(abbr);
    if (!_isCurrentLoadRequest(requestId)) return;
    if (books.isEmpty) {
      emit(state.copyWith(isLoading: false, error: 'bibleDataUnavailable'));
      return;
    }

    final resolvedBookId = bookId.isEmpty ? readerLastBookId(_prefs) : bookId;
    final resolvedChapterId = chapterId.isEmpty
        ? readerLastChapterId(_prefs)
        : chapterId;

    final targetBook = firstWhereOrFirst(books, (b) => b.id == resolvedBookId);
    emit(state.copyWith(books: books, activeBook: targetBook));

    await _loadChapters(
      abbr,
      targetBook,
      resolvedChapterId,
      requestId: requestId,
      forceScrollToFirstVerse: forceScrollToFirstVerse,
      scrollTarget: scrollTarget,
    );
  }

  Future<void> _loadChapters(
    String abbr,
    BibleBook book,
    String chapterId, {
    required int requestId,
    bool forceScrollToFirstVerse = false,
    ScrollTarget? scrollTarget,
  }) async {
    final chapters = await _bibleRepo.getLocalChapters(abbr, book.id);
    if (!_isCurrentLoadRequest(requestId)) return;
    if (chapters.isEmpty) {
      emit(
        state.copyWith(isLoading: false, error: 'noChaptersFound:${book.name}'),
      );
      return;
    }
    final target = firstWhereOrFirst(chapters, (c) => c.id == chapterId);
    emit(state.copyWith(chapters: chapters, activeChapter: target));

    await _loadVerses(
      abbr,
      target,
      requestId: requestId,
      scrollTarget: scrollTarget,
      forceScrollToFirstVerse: forceScrollToFirstVerse,
    );
  }
}
