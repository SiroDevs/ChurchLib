// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/scripture_list.dart';

@dao
abstract class ScriptureListsDao {
  @Insert()
  Future<int> insert(ScriptureList list);

  @Query(
    'SELECT * FROM ${BibleConstants.scriptureListsTable} '
    'ORDER BY createdAt DESC',
  )
  Future<List<ScriptureList>> getAll();

  @Query(
    'SELECT * FROM ${BibleConstants.scriptureListsTable} '
    'WHERE id = :listId LIMIT 1',
  )
  Future<ScriptureList?> getById(int listId);

  @Query(
    'UPDATE ${BibleConstants.scriptureListsTable} SET name = :name '
    'WHERE id = :listId',
  )
  Future<void> rename(int listId, String name);

  @Query('DELETE FROM ${BibleConstants.scriptureListsTable} WHERE id = :listId')
  Future<void> delete(int listId);

  @Query('DELETE FROM ${BibleConstants.scriptureListsTable}')
  Future<void> deleteAll();
}
