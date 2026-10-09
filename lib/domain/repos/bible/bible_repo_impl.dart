// Dart imports:
import 'dart:convert';

// Project imports:
import '../../../common/utils/app_util.dart';
import '../../../common/utils/async_semaphore.dart';
import '../../../data/models/bible/bible_book.dart';
import '../../../data/models/bible/bible_chapter.dart';
import '../../../data/models/bible/bible_verse_cache.dart';
import '../../../data/models/bible/bible_version.dart';
import '../../../data/sources/local/app_database.dart';
import '../../../data/sources/remote/bible/bible_api_service.dart';
import '../../../data/sources/remote/bible/bible_dtos.dart';
import '../../entities/bible/verse_display.dart';
import 'bible_repo.dart';
import 'retry_policy.dart';

part 'bible_download_mixin.dart';

const _maxConcurrentBookBatches = 20;

class BibleRepoImpl with BibleDownloadMixin implements BibleRepo {
  final AppDatabase _appDB;
  final BibleApiService _service;

  BibleRepoImpl(this._appDB, this._service);

  @override
  Future<List<BibleInfoDto>> fetchAvailableBibles() async {
    final groups = await retrying(() => _service.getGroups());
    final results = await Future.wait(
      groups.map((group) async {
        try {
          return await retrying(() => _service.getGroupInfo(group));
        } catch (e) {
          logger("⚠️ Couldn't fetch group '$group', skipping: $e");
          return <BibleInfoDto>[];
        }
      }),
    );
    return results.expand((list) => list).toList();
  }

  @override
  Future<List<BibleBook>> getLocalBooks(String abbr) {
    return _appDB.bibleBooksDao.getByBible(abbr);
  }

  @override
  Future<List<BibleChapter>> getLocalChapters(String abbr, String bookId) {
    return _appDB.bibleChaptersDao.getByBook(abbr, bookId);
  }

  @override
  Future<List<VerseDisplay>?> getLocalVerses(
    String abbr,
    String chapterId,
  ) async {
    final entity = await _appDB.bibleVersesDao.getChapter(abbr, chapterId);
    if (entity == null) return null;
    final decoded = jsonDecode(entity.contentJson) as List<dynamic>;
    return decoded
        .map((e) => VerseDisplay.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<VerseDisplay>> searchVerses(String abbr, String query) async {
    final entities = await _appDB.bibleVersesDao.searchInBible(abbr, query);
    final lowerQuery = query.toLowerCase();
    return entities.expand((entity) {
      final decoded = jsonDecode(entity.contentJson) as List<dynamic>;
      final verses = decoded
          .map((e) => VerseDisplay.fromJson(e as Map<String, dynamic>))
          .toList();
      return verses.where((v) => v.text.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<BibleVersion>> getBibles() {
    return _appDB.bibleVersionsDao.getAll();
  }

  @override
  Future<void> saveBibles(List<BibleVersion> versions) {
    return _appDB.bibleVersionsDao.insertAll(versions);
  }

  @override
  Future<void> deleteBible(String abbr) async {
    await _appDB.bibleVersionsDao.deleteByAbbr(abbr);
    await _appDB.bibleBooksDao.deleteByBible(abbr);
    await _appDB.bibleChaptersDao.deleteByBible(abbr);
    await _appDB.bibleVersesDao.deleteByBible(abbr);
  }

  @override
  Future<void> clearBibleContent(String abbr) async {
    await _appDB.bibleBooksDao.deleteByBible(abbr);
    await _appDB.bibleChaptersDao.deleteByBible(abbr);
    await _appDB.bibleVersesDao.deleteByBible(abbr);
    final existing = await _appDB.bibleVersionsDao.getByAbbr(abbr);
    if (existing != null) {
      existing.isDownloaded = false;
      existing.downloadProgress = 0;
      existing.downloadFailed = false;
      await _appDB.bibleVersionsDao.insert(existing);
    }
  }

  @override
  Future<void> markDownloadFailed(String abbr) async {
    final existing = await _appDB.bibleVersionsDao.getByAbbr(abbr);
    await _appDB.bibleVersionsDao.markFailed(
      abbr,
      existing?.downloadProgress ?? 0,
    );
  }

  @override
  Future<void> deleteAllData() async {
    await _appDB.bibleVersionsDao.deleteAll();
    await _appDB.bibleBooksDao.deleteAll();
    await _appDB.bibleChaptersDao.deleteAll();
    await _appDB.bibleVersesDao.deleteAll();
  }
}
