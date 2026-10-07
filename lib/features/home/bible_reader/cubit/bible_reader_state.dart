part of 'bible_reader_cubit.dart';

class BibleReaderState {
  final bool isLoading;
  final String? error;
  final List<BibleVersion> savedBibles;
  final String activeBible;
  final String activeBibleAbbr;
  final List<BibleBook> books;
  final BibleBook? activeBook;
  final List<BibleChapter> chapters;
  final BibleChapter? activeChapter;
  final List<VerseDisplay> verses;
  final Map<String, List<VerseDisplay>> parallelVerses;
  final int fontSize;
  final bool multiBibleReaderEnabled;
  final String? restoreVerseId;
  final String? highlightQuery;
  final Map<String, String?> bookmarks;
  final Set<String> notedVerseIds;
  final Set<String> selectedVerseIds;
  final String? pendingHighlightColor;

  const BibleReaderState({
    this.isLoading = true,
    this.error,
    this.savedBibles = const [],
    this.activeBible = '',
    this.activeBibleAbbr = '',
    this.books = const [],
    this.activeBook,
    this.chapters = const [],
    this.activeChapter,
    this.verses = const [],
    this.parallelVerses = const {},
    this.fontSize = readerDefaultFontSize,
    this.multiBibleReaderEnabled = true,
    this.restoreVerseId,
    this.highlightQuery,
    this.bookmarks = const {},
    this.notedVerseIds = const {},
    this.selectedVerseIds = const {},
    this.pendingHighlightColor,
  });

  bool get isSelectionMode => selectedVerseIds.isNotEmpty;

  String? get activeBibleLanguage {
    for (final b in savedBibles) {
      if (b.abbreviation == activeBibleAbbr) return b.languageName;
    }
    return null;
  }

  bool get isRtl {
    for (final b in savedBibles) {
      if (b.abbreviation == activeBibleAbbr) {
        return b.scriptDirection.toUpperCase() == 'RTL';
      }
    }
    return false;
  }

  BibleReaderState copyWith({
    bool? isLoading,
    Object? error = _unset,
    List<BibleVersion>? savedBibles,
    String? activeBible,
    String? activeBibleAbbr,
    List<BibleBook>? books,
    Object? activeBook = _unset,
    List<BibleChapter>? chapters,
    Object? activeChapter = _unset,
    List<VerseDisplay>? verses,
    Map<String, List<VerseDisplay>>? parallelVerses,
    int? fontSize,
    bool? multiBibleReaderEnabled,
    Object? restoreVerseId = _unset,
    Object? highlightQuery = _unset,
    Map<String, String?>? bookmarks,
    Set<String>? notedVerseIds,
    Set<String>? selectedVerseIds,
    Object? pendingHighlightColor = _unset,
  }) {
    return BibleReaderState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      savedBibles: savedBibles ?? this.savedBibles,
      activeBible: activeBible ?? this.activeBible,
      activeBibleAbbr: activeBibleAbbr ?? this.activeBibleAbbr,
      books: books ?? this.books,
      activeBook: identical(activeBook, _unset)
          ? this.activeBook
          : activeBook as BibleBook?,
      chapters: chapters ?? this.chapters,
      activeChapter: identical(activeChapter, _unset)
          ? this.activeChapter
          : activeChapter as BibleChapter?,
      verses: verses ?? this.verses,
      parallelVerses: parallelVerses ?? this.parallelVerses,
      fontSize: fontSize ?? this.fontSize,
      multiBibleReaderEnabled:
          multiBibleReaderEnabled ?? this.multiBibleReaderEnabled,
      restoreVerseId: identical(restoreVerseId, _unset)
          ? this.restoreVerseId
          : restoreVerseId as String?,
      highlightQuery: identical(highlightQuery, _unset)
          ? this.highlightQuery
          : highlightQuery as String?,
      bookmarks: bookmarks ?? this.bookmarks,
      notedVerseIds: notedVerseIds ?? this.notedVerseIds,
      selectedVerseIds: selectedVerseIds ?? this.selectedVerseIds,
      pendingHighlightColor: identical(pendingHighlightColor, _unset)
          ? this.pendingHighlightColor
          : pendingHighlightColor as String?,
    );
  }
}
