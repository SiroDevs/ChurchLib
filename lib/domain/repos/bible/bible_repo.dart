// Project imports:
import '../../../data/models/bible/bible_book.dart';
import '../../../data/models/bible/bible_chapter.dart';
import '../../../data/models/bible/bible_version.dart';
import '../../../data/sources/remote/bible/bible_dtos.dart';
import '../../entities/bible/verse_display.dart';

/// BibleLib's data-layer contract — ported from biblelib-android's
/// `BibleRepo`, split from its implementation the same way SongLib's
/// `DatabaseRepo`/`DatabaseRepoImpl` are split.
abstract class BibleRepo {
  /// Fetches every translation available from the remote API (grouped by
  /// language/collection server-side, flattened here) — not yet saved
  /// locally. Ported from `BibleRepo.fetchAvailableBibles`.
  Future<List<BibleInfoDto>> fetchAvailableBibles();

  /// Downloads one translation's full text: books, then chapters, then
  /// verses (chapter content fetched with bounded concurrency across
  /// books). Resumable — chapters already cached in
  /// [BibleConstants.versesTable] are skipped on retry. [onProgress]
  /// receives a human-readable step description and 0.0-1.0 progress,
  /// same shape as Android's callback.
  Future<void> downloadBible(
    String abbr, {
    Future<void> Function(String step, double progress)? onProgress,
  });

  Future<List<BibleBook>> getLocalBooks(String abbr);

  Future<List<BibleChapter>> getLocalChapters(String abbr, String bookId);

  /// Null when this chapter hasn't been downloaded/cached yet.
  Future<List<VerseDisplay>?> getLocalVerses(String abbr, String chapterId);

  /// Verse-level text search within one downloaded translation.
  Future<List<VerseDisplay>> searchVerses(String abbr, String query);

  /// Locally saved translation records (downloaded or in-progress).
  Future<List<BibleVersion>> getBibles();

  Future<void> saveBibles(List<BibleVersion> versions);

  /// Removes a translation and all of its books/chapters/verses.
  Future<void> deleteBible(String abbr);

  /// Removes a translation's downloaded content but keeps its `bibles`
  /// row, reset to not-downloaded — lets the user re-download without
  /// losing its place in their translation list.
  Future<void> clearBibleContent(String abbr);

  Future<void> markDownloadFailed(String abbr);

  /// Wipes every BibleLib table — bibles, books, chapters, verses.
  Future<void> deleteAllData();
}
