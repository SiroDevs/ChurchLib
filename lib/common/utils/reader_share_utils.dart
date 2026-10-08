// Project imports:
import '../../data/models/bible/bible_book.dart';
import '../../data/models/bible/bible_chapter.dart';
import '../../domain/entities/bible/verse_display.dart';

String? buildVerseSelectionShareText({
  required List<VerseDisplay> selected,
  required List<VerseDisplay> chapterVerses,
  required BibleBook? book,
  required BibleChapter? chapter,
  required String bibleName,
  required String? language,
}) {
  if (selected.isEmpty) return null;
  final reference = '${referencePrefix(book, chapter, chapterVerses)}'
      '${formatVerseRange(selected.map((v) => v.number).toList())}';
  final body = selected.map((v) => '${v.number} ${v.text}').join('\n');
  return buildShareText(reference, body, bibleName, language);
}

String? buildChapterShareText({
  required List<VerseDisplay> chapterVerses,
  required BibleBook? book,
  required BibleChapter? chapter,
  required String bibleName,
  required String? language,
}) {
  if (chapterVerses.isEmpty) return null;
  final reference = referencePrefix(book, chapter, chapterVerses)
      .replaceAll(RegExp(r'[: ]+$'), '');
  final sorted = [...chapterVerses]..sort((a, b) => a.number.compareTo(b.number));
  return buildShareText(
    reference,
    sorted.map((v) => '${v.number} ${v.text}').join('\n'),
    bibleName,
    language,
  );
}

String referencePrefix(
  BibleBook? book,
  BibleChapter? chapter,
  List<VerseDisplay> chapterVerses,
) {
  final bookName =
      book?.name ?? (chapterVerses.isEmpty ? '' : chapterVerses.first.bookId);
  final chapterNumber = chapter?.number;
  return (chapterNumber == null || chapterNumber.trim().isEmpty)
      ? '$bookName '
      : '$bookName $chapterNumber:';
}

String buildShareText(
  String reference,
  String body,
  String bibleName,
  String? language,
) {
  final footnote = language == null || language.trim().isEmpty
      ? bibleName
      : '$bibleName ($language)';
  return '$reference\n\n$body\n\n— $footnote';
}

String formatVerseRange(List<int> numbers) {
  if (numbers.isEmpty) return '';
  final sorted = [...numbers]..sort();
  final parts = <String>[];
  var start = sorted.first;
  var prev = sorted.first;
  for (final n in sorted.skip(1)) {
    if (n == prev + 1) {
      prev = n;
      continue;
    }
    parts.add(start == prev ? '$start' : '$start-$prev');
    start = n;
    prev = n;
  }
  parts.add(start == prev ? '$start' : '$start-$prev');
  return parts.join(', ');
}
