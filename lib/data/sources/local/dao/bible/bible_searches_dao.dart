import 'package:froom/froom.dart';

import '../../../../../core/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_search.dart';

/// Ported from biblelib-android's `SearchDao`.
@dao
abstract class BibleSearchesDao {
  @Query(
    'SELECT * FROM ${BibleConstants.searchesTable} '
    'ORDER BY queriedAt DESC LIMIT 50',
  )
  Future<List<BibleSearch>> getRecent();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(BibleSearch search);

  @Query(
    'DELETE FROM ${BibleConstants.searchesTable} '
    'WHERE qry = :query COLLATE NOCASE',
  )
  Future<void> deleteByQuery(String query);

  @Query(
    'DELETE FROM ${BibleConstants.searchesTable} WHERE id NOT IN '
    '(SELECT id FROM ${BibleConstants.searchesTable} '
    'ORDER BY queriedAt DESC LIMIT 100)',
  )
  Future<void> pruneOld();

  @Query('DELETE FROM ${BibleConstants.searchesTable}')
  Future<void> deleteAll();
}
