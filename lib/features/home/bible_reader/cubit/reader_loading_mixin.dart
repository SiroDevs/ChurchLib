part of 'bible_reader_cubit.dart';

mixin ReaderLoadingMixin on Cubit<BibleReaderState> {
  BibleRepo get _bibleRepo;
  PrefRepo get _prefs;
  set _isFirstLoad(bool value);
  Future<void> _loadVerses(
    String abbr,
    BibleChapter chapter, {
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
}
