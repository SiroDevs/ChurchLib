// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../common/utils/constants/song_constants.dart';
import '../../../models/shared/search_entry.dart';

@dao
abstract class SearchesDao {
  @Query(
    'SELECT * FROM ${SongConstants.searchesTable} '
    'WHERE source = :source ORDER BY queriedAt DESC LIMIT :limit',
  )
  Future<List<SearchEntry>> fetchRecent(String source, int limit);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSearch(SearchEntry search);

  @delete
  Future<void> deleteSearch(SearchEntry search);

  @Query(
    'DELETE FROM ${SongConstants.searchesTable} '
    'WHERE source = :source AND query = :query COLLATE NOCASE',
  )
  Future<void> deleteByQuery(String source, String query);

  @Query(
    'DELETE FROM ${SongConstants.searchesTable} WHERE source = :source',
  )
  Future<void> deleteAllSearches(String source);

  @Query(
    'DELETE FROM ${SongConstants.searchesTable} WHERE source = :source '
    'AND id NOT IN (SELECT id FROM ${SongConstants.searchesTable} '
    'WHERE source = :source ORDER BY queriedAt DESC LIMIT :keep)',
  )
  Future<void> pruneOld(String source, int keep);
}
