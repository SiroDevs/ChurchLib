// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../common/utils/constants/song_constants.dart';
import '../../../models/shared/history_entry.dart';
import '../../../models/shared/historyext.dart';

@dao
abstract class HistoriesDao {
  @Query(
    'SELECT * FROM ${SongConstants.historiesTable} '
    'WHERE source = :source ORDER BY occurredAt DESC LIMIT :limit',
  )
  Future<List<HistoryEntry>> fetchRecent(String source, int limit);

  /// One row per (source, refId, dayKey) — used to update today's entry
  /// in place instead of inserting a new one on every verse scrolled.
  @Query(
    'SELECT * FROM ${SongConstants.historiesTable} WHERE source = :source '
    'AND refId = :refId AND dayKey = :dayKey LIMIT 1',
  )
  Future<HistoryEntry?> findForDay(String source, String refId, String dayKey);

  @Query('SELECT * FROM ${SongConstants.historiesTableViews}')
  Stream<List<HistoryExt>> fetchHistoryExts();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertHistory(HistoryEntry history);

  @Update()
  Future<void> updateHistory(HistoryEntry history);

  @delete
  Future<void> deleteHistory(HistoryEntry history);

  @Query(
    'DELETE FROM ${SongConstants.historiesTable} WHERE source = :source',
  )
  Future<void> deleteAllHistories(String source);

  @Query(
    'DELETE FROM ${SongConstants.historiesTable} WHERE source = :source '
    'AND id NOT IN (SELECT id FROM ${SongConstants.historiesTable} '
    'WHERE source = :source ORDER BY occurredAt DESC LIMIT :keep)',
  )
  Future<void> pruneOld(String source, int keep);
}
