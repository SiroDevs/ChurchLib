// Project imports:
import '../../data/models/bible/bible_book.dart';
import '../../data/models/bible/bible_chapter.dart';
import '../../data/models/bible/bible_version.dart';
import '../../domain/entities/bible/bible_reader.dart';
import '../../domain/entities/bible/verse_display.dart';
import '../../domain/repos/bible/bible_tracking_repo.dart';
import '../../domain/repos/pref_repo.dart';
import 'constants/pref_constants.dart';

const readerDefaultFontSize = 26;
const readerMinFontSize = 14;
const readerMaxFontSize = 56;

int clampReaderFontSize(int size) =>
    size.clamp(readerMinFontSize, readerMaxFontSize);

String readerLastBibleAbbr(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastBibleAbbrKey);

String readerLastBookId(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastBookIdKey);

String readerLastChapterId(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastChapterIdKey);

String readerLastVerseId(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastVerseIdKey);

bool readerMultiBibleEnabled(PrefRepo prefs) => prefs.getPrefBool(
      PrefConstants.bibleMultiBibleEnabledKey,
      defaultValue: true,
    );

int readerStoredFontSize(PrefRepo prefs) {
  final stored = prefs.getPrefInt(PrefConstants.bibleFontSizeKey);
  return stored > 0 ? stored : readerDefaultFontSize;
}

List<String> readerSecondaryBibles(PrefRepo prefs) {
  final csv = prefs.getPrefString(PrefConstants.bibleSecondaryKey);
  return csv.isEmpty ? [] : csv.split(',').where((e) => e.isNotEmpty).toList();
}

void saveReaderFontSize(PrefRepo prefs, int size) =>
    prefs.setPrefInt(PrefConstants.bibleFontSizeKey, size);

void saveReaderMultiBibleEnabled(PrefRepo prefs, bool enabled) =>
    prefs.setPrefBool(PrefConstants.bibleMultiBibleEnabledKey, enabled);

void saveReaderLastVerseId(PrefRepo prefs, String verseId) =>
    prefs.setPrefString(PrefConstants.bibleLastVerseIdKey, verseId);

void saveReaderPosition(
  PrefRepo prefs, {
  required String bibleAbbr,
  required String bookId,
  required String chapterId,
}) {
  prefs.setPrefString(PrefConstants.bibleLastBibleAbbrKey, bibleAbbr);
  prefs.setPrefString(PrefConstants.bibleLastBookIdKey, bookId);
  prefs.setPrefString(PrefConstants.bibleLastChapterIdKey, chapterId);
}

void saveReaderPrimaryBible(
  PrefRepo prefs, {
  required String abbr,
  required String name,
}) {
  prefs.setPrefString(PrefConstants.biblePrimaryKey, abbr);
  prefs.setPrefString(PrefConstants.bibleLastBibleKey, name);
  prefs.setPrefString(
    PrefConstants.bibleSecondaryKey,
    readerSecondaryBibles(prefs).where((a) => a != abbr).join(','),
  );
}

T firstWhereOrFirst<T>(List<T> items, bool Function(T) test) =>
    items.firstWhere(test, orElse: () => items.first);

({String abbr, String name}) resolveReaderBible({
  required List<BibleVersion> bibles,
  required String requestedAbbr,
  required String lastAbbr,
}) {
  final abbr = requestedAbbr.isNotEmpty
      ? requestedAbbr
      : (lastAbbr.isNotEmpty ? lastAbbr : bibles.first.abbreviation);
  final name =
      firstWhereOrFirst(bibles, (b) => b.abbreviation == abbr).name;
  return (abbr: abbr, name: name);
}

ScrollTarget? initialReaderScrollTarget({
  required String verseId,
  required String searchQuery,
}) {
  if (verseId.isEmpty) return null;
  return ScrollTarget(
    verseId,
    highlightQuery: searchQuery.isEmpty ? null : searchQuery,
  );
}

ScrollTarget? resolveReaderScrollTarget({
  required ScrollTarget? explicit,
  required bool forceFirst,
  required bool isFirstLoad,
  required String lastVerseId,
  required List<VerseDisplay> verses,
}) {
  if (explicit != null) return explicit;
  if (forceFirst) {
    return verses.isEmpty ? null : ScrollTarget(verses.first.verseId);
  }
  if (isFirstLoad && lastVerseId.isNotEmpty) return ScrollTarget(lastVerseId);
  return null;
}

List<String> parallelBibleAbbrs({
  required String primaryAbbr,
  required List<BibleVersion> savedBibles,
  required List<String> secondary,
}) {
  final downloaded = savedBibles
      .where((b) => b.isDownloaded)
      .map((b) => b.abbreviation)
      .toSet();

  final ordered = secondary
      .where((a) => a != primaryAbbr && downloaded.contains(a))
      .toList();
  if (ordered.isNotEmpty) return ordered;

  return savedBibles
      .where((b) => b.abbreviation != primaryAbbr && b.isDownloaded)
      .map((b) => b.abbreviation)
      .toList();
}

Future<void> recordReaderPosition(
  BibleTrackingRepo tracking, {
  required String bibleAbbr,
  required String bibleName,
  required BibleBook book,
  required BibleChapter chapter,
  required int verseNumber,
}) {
  return tracking.recordReading(
    bibleAbbr: bibleAbbr,
    bibleName: bibleName,
    bookId: book.id,
    bookName: book.name,
    chapterId: chapter.id,
    chapterRef: chapter.reference,
    verseNumber: verseNumber,
    readAt: DateTime.now().millisecondsSinceEpoch,
  );
}

Set<String> toggleVerseSelection(Set<String> selected, String verseId) {
  final next = {...selected};
  if (!next.remove(verseId)) next.add(verseId);
  return next;
}

List<VerseDisplay> selectedVersesSorted(
  List<VerseDisplay> verses,
  Set<String> selectedIds,
) {
  return verses.where((v) => selectedIds.contains(v.verseId)).toList()
    ..sort((a, b) => a.number.compareTo(b.number));
}

Map<String, String?> withoutBookmark(
  Map<String, String?> bookmarks,
  String verseId,
) =>
    {...bookmarks}..remove(verseId);

Map<String, String?> withBookmarks(
  Map<String, String?> bookmarks,
  Iterable<String> verseIds,
  String? colorHex,
) =>
    {...bookmarks, for (final id in verseIds) id: colorHex};

NotesRequest buildNotesRequest({
  required String bibleAbbr,
  required VerseDisplay verse,
  required BibleBook? book,
  required BibleChapter? chapter,
}) {
  final bookName = book?.name ?? verse.bookId;
  final chapterNumber = chapter?.number ?? '';
  return NotesRequest(
    bibleAbbr: bibleAbbr,
    verseId: verse.verseId,
    bookId: book?.id ?? verse.bookId,
    chapterId: chapter?.id ?? verse.chapterId,
    title: '$bookName $chapterNumber:${verse.number}',
    verseText: verse.text,
  );
}

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
