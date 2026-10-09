// Project imports:
import '../../data/models/bible/bible_book.dart';
import '../../data/models/bible/bible_chapter.dart';
import '../../data/models/bible/bible_version.dart';
import '../../domain/entities/bible/bible_reader.dart';
import '../../domain/entities/bible/verse_display.dart';
import '../../domain/repos/bible/bible_tracking_repo.dart';

export 'reader_prefs_utils.dart';
export 'reader_share_utils.dart';

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
