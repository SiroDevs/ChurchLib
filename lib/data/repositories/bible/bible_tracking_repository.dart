import '../../models/bible/bible_history.dart';
import '../../models/bible/bible_search.dart';
import '../../sources/local/app_database.dart';

/// Ported from biblelib-android's `TrackingRepo`: one history row per
/// (bible, chapter, day) that is updated as the reader scrolls, plus a
/// pruned recent-search list.
class BibleTrackingRepository {
  final AppDatabase _appDB;

  BibleTrackingRepository(this._appDB);

  static String _dayKey(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}$m$day';
  }

  Future<void> recordReading(BibleHistory entry) async {
    final dayKey = _dayKey(entry.readAt);
    final existing = await _appDB.bibleHistoriesDao.findForDay(
      entry.bibleAbbr,
      entry.chapterId,
      dayKey,
    );
    if (existing != null) {
      existing.bibleName = entry.bibleName;
      existing.bookName = entry.bookName;
      existing.chapterRef = entry.chapterRef;
      existing.verseNumber = entry.verseNumber ?? existing.verseNumber;
      await _appDB.bibleHistoriesDao.update(existing);
    } else {
      entry.dayKey = dayKey;
      await _appDB.bibleHistoriesDao.insert(entry);
      await _appDB.bibleHistoriesDao.pruneOld();
    }
  }

  Future<List<BibleHistory>> getReadingHistory() =>
      _appDB.bibleHistoriesDao.getRecent();

  Future<void> clearHistory() => _appDB.bibleHistoriesDao.deleteAll();

  Future<void> recordSearch(String qry) async {
    await _appDB.bibleSearchesDao.deleteByQuery(qry);
    await _appDB.bibleSearchesDao.insert(
      BibleSearch(qry: qry, queriedAt: DateTime.now().millisecondsSinceEpoch),
    );
    await _appDB.bibleSearchesDao.pruneOld();
  }

  Future<List<BibleSearch>> getSearchHistory() =>
      _appDB.bibleSearchesDao.getRecent();

  Future<void> clearSearchHistory() => _appDB.bibleSearchesDao.deleteAll();
}
