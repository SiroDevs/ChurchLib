class ReaderTarget {
  final String bibleAbbr;
  final String bookId;
  final String chapterId;
  final String verseId;
  final String searchQuery;

  const ReaderTarget({
    required this.bibleAbbr,
    required this.bookId,
    required this.chapterId,
    this.verseId = '',
    this.searchQuery = '',
  });
}

class ScrollTarget {
  final String verseId;
  final String? highlightQuery;
  const ScrollTarget(this.verseId, {this.highlightQuery});
}

const readerHighlightColors = [
  '#FFF59D',
  '#A5D6A7',
  '#90CAF9',
  '#F48FB1',
  '#FFCC80',
  '#CE93D8',
];

class NotesRequest {
  final String bibleAbbr;
  final String verseId;
  final String bookId;
  final String chapterId;
  final String title;
  final String verseText;

  const NotesRequest({
    required this.bibleAbbr,
    required this.verseId,
    required this.bookId,
    required this.chapterId,
    required this.title,
    required this.verseText,
  });
}
