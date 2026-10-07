// Project imports:
import '../../../data/models/shared/entry_source.dart';
import '../../../data/models/shared/history_entry.dart';
import '../../../data/models/shared/search_entry.dart';
import '../../../data/sources/local/app_database.dart';

class BibleTrackingRepo {
  final AppDatabase _appDB;

  BibleTrackingRepo(this._appDB);

  static String _dayKey(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}$m$day';
  }

  Future<void> recordReading({
    required String bibleAbbr,
    required String bibleName,
    required String bookId,
    required String bookName,
    required String chapterId,
    required String chapterRef,
    int? verseNumber,
    required int readAt,
  }) async {
    final dayKey = _dayKey(readAt);
    final existing = await _appDB.historiesDao.findForDay(
      EntrySource.bible,
      chapterId,
      dayKey,
    );
    if (existing != null) {
      existing.bibleName = bibleName;
      existing.bookName = bookName;
      existing.chapterRef = chapterRef;
      existing.verseNumber = verseNumber ?? existing.verseNumber;
      await _appDB.historiesDao.updateHistory(existing);
    } else {
      await _appDB.historiesDao.insertHistory(
        HistoryEntry(
          source: EntrySource.bible,
          refId: chapterId,
          bibleAbbr: bibleAbbr,
          bibleName: bibleName,
          bookId: bookId,
          bookName: bookName,
          chapterRef: chapterRef,
          verseNumber: verseNumber,
          dayKey: dayKey,
          occurredAt: readAt,
        ),
      );
      await _appDB.historiesDao.pruneOld(EntrySource.bible, 200);
    }
  }

  Future<List<HistoryEntry>> getReadingHistory() =>
      _appDB.historiesDao.fetchRecent(EntrySource.bible, 100);

  Future<void> clearHistory() =>
      _appDB.historiesDao.deleteAllHistories(EntrySource.bible);

  Future<void> recordSearch(String qry) async {
    await _appDB.searchesDao.deleteByQuery(EntrySource.bible, qry);
    await _appDB.searchesDao.insertSearch(
      SearchEntry(
        source: EntrySource.bible,
        query: qry,
        queriedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _appDB.searchesDao.pruneOld(EntrySource.bible, 50);
  }

  Future<List<SearchEntry>> getSearchHistory() =>
      _appDB.searchesDao.fetchRecent(EntrySource.bible, 50);

  Future<void> clearSearchHistory() =>
      _appDB.searchesDao.deleteAllSearches(EntrySource.bible);
}
