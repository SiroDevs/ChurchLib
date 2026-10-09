part of 'scripture_opener_cubit.dart';

enum ExpandedField { none, book, chapter, verse }

int _rowKeySeq = 0;

String _newRowKey() => '${DateTime.now().microsecondsSinceEpoch}-${_rowKeySeq++}';

class ScriptureSearchRowState {
  final String key;
  final bool locked;
  final ExpandedField expanded;

  final List<BibleBook> books;
  final BibleBook? selectedBook;

  final bool isLoadingChapters;
  final List<BibleChapter> chapters;
  final BibleChapter? selectedChapter;

  final bool isLoadingVerses;
  final List<VerseDisplay> verses;
  final int? selectedVerseNumber;

  ScriptureSearchRowState({
    String? key,
    this.locked = false,
    this.expanded = ExpandedField.book,
    this.books = const [],
    this.selectedBook,
    this.isLoadingChapters = false,
    this.chapters = const [],
    this.selectedChapter,
    this.isLoadingVerses = false,
    this.verses = const [],
    this.selectedVerseNumber,
  }) : key = key ?? _newRowKey();

  String get bookLabel => selectedBook?.name ?? '';
  String get chapterLabel => selectedChapter?.number ?? '';
  String get verseLabel => selectedVerseNumber?.toString() ?? '';

  bool get canExpandChapter => selectedBook != null;
  bool get canExpandVerse => selectedChapter != null;

  bool get isComplete =>
      selectedBook != null && selectedChapter != null && selectedVerseNumber != null;

  String? get selectedVerseId => verses
      .where((v) => v.number == selectedVerseNumber)
      .map((v) => v.verseId)
      .firstOrNull;

  String get reference => isComplete
      ? '${selectedBook!.name} ${selectedChapter!.number}:$selectedVerseNumber'
      : '';

  ScriptureSearchRowState copyWith({
    bool? locked,
    ExpandedField? expanded,
    List<BibleBook>? books,
    Object? selectedBook = _unset,
    bool? isLoadingChapters,
    List<BibleChapter>? chapters,
    Object? selectedChapter = _unset,
    bool? isLoadingVerses,
    List<VerseDisplay>? verses,
    Object? selectedVerseNumber = _unset,
  }) {
    return ScriptureSearchRowState(
      key: key,
      locked: locked ?? this.locked,
      expanded: expanded ?? this.expanded,
      books: books ?? this.books,
      selectedBook:
          identical(selectedBook, _unset) ? this.selectedBook : selectedBook as BibleBook?,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      chapters: chapters ?? this.chapters,
      selectedChapter: identical(selectedChapter, _unset)
          ? this.selectedChapter
          : selectedChapter as BibleChapter?,
      isLoadingVerses: isLoadingVerses ?? this.isLoadingVerses,
      verses: verses ?? this.verses,
      selectedVerseNumber: identical(selectedVerseNumber, _unset)
          ? this.selectedVerseNumber
          : selectedVerseNumber as int?,
    );
  }

  ScriptureItem? toItem(String bibleAbbr, String bibleName, int order) {
    final book = selectedBook;
    final chapter = selectedChapter;
    final verseNumber = selectedVerseNumber;
    final verseId = selectedVerseId;
    if (book == null ||
        chapter == null ||
        verseNumber == null ||
        verseId == null) {
      return null;
    }
    return ScriptureItem(
      listId: 0,
      bibleAbbr: bibleAbbr,
      bibleName: bibleName,
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

  ReaderTarget? toTarget(String bibleAbbr) {
    final book = selectedBook;
    final chapter = selectedChapter;
    final verseId = selectedVerseId;
    if (book == null || chapter == null || verseId == null) return null;
    return ReaderTarget(
      bibleAbbr: bibleAbbr,
      bookId: book.id,
      chapterId: chapter.id,
      verseId: verseId,
    );
  }
}
