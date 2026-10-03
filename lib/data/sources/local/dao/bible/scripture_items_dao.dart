// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/scripture_item.dart';

/// Ported from biblelib-android's `ScriptureItemDao`.
@dao
abstract class ScriptureItemsDao {
  @Insert(onConflict: OnConflictStrategy.abort)
  Future<void> insertAll(List<ScriptureItem> items);

  @Query(
    'SELECT * FROM ${BibleConstants.scriptureItemsTable} '
    'WHERE listId = :listId ORDER BY sortOrder ASC',
  )
  Future<List<ScriptureItem>> getForList(int listId);

  @Query(
    'SELECT COUNT(*) FROM ${BibleConstants.scriptureItemsTable} '
    'WHERE listId = :listId',
  )
  Future<int?> countForList(int listId);

  @Query(
    'DELETE FROM ${BibleConstants.scriptureItemsTable} WHERE listId = :listId',
  )
  Future<void> deleteForList(int listId);

  @Query('DELETE FROM ${BibleConstants.scriptureItemsTable}')
  Future<void> deleteAll();
}
