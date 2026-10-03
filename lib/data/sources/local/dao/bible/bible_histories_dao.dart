// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_history.dart';

/// Ported from biblelib-android's `HistoryDao`.
@dao
abstract class BibleHistoriesDao {
  @Query(
    'SELECT * FROM ${BibleConstants.historiesTable} '
    'ORDER BY readAt DESC LIMIT 100',
  )
  Future<List<BibleHistory>> getRecent();

  @Query(
    'SELECT * FROM ${BibleConstants.historiesTable} '
    'WHERE bibleAbbr = :abbr AND chapterId = :chapterId AND dayKey = :dayKey '
    'LIMIT 1',
  )
  Future<BibleHistory?> findForDay(String abbr, String chapterId, String dayKey);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(BibleHistory history);

  @Update()
  Future<void> update(BibleHistory history);

  @Query(
    'DELETE FROM ${BibleConstants.historiesTable} WHERE id NOT IN '
    '(SELECT id FROM ${BibleConstants.historiesTable} '
    'ORDER BY readAt DESC LIMIT 200)',
  )
  Future<void> pruneOld();

  @Query('DELETE FROM ${BibleConstants.historiesTable}')
  Future<void> deleteAll();
}
