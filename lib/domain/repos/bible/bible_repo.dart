// Project imports:
import '../../../data/models/bible/bible_book.dart';
import '../../../data/models/bible/bible_chapter.dart';
import '../../../data/models/bible/bible_version.dart';
import '../../../data/sources/remote/bible/bible_dtos.dart';
import '../../entities/bible/verse_display.dart';

abstract class BibleRepo {
  Future<List<BibleInfoDto>> fetchAvailableBibles();

  Future<void> downloadBible(
    String abbr, {
    Future<void> Function(String step, double progress)? onProgress,
  });

  Future<List<BibleBook>> getLocalBooks(String abbr);

  Future<List<BibleChapter>> getLocalChapters(String abbr, String bookId);

  Future<List<VerseDisplay>?> getLocalVerses(String abbr, String chapterId);

  Future<List<VerseDisplay>> searchVerses(String abbr, String query);

  Future<List<BibleVersion>> getBibles();

  Future<void> saveBibles(List<BibleVersion> versions);

  Future<void> deleteBible(String abbr);

  Future<void> clearBibleContent(String abbr);

  Future<void> markDownloadFailed(String abbr);

  Future<void> deleteAllData();
}
