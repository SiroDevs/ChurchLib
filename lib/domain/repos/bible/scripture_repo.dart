// Project imports:
import '../../../data/models/bible/scripture_item.dart';
import '../../../data/models/bible/scripture_list.dart';
import '../../../data/sources/local/app_database.dart';

/// Ported from biblelib-android's `ScriptureRepo`.
class ScriptureRepo {
  final AppDatabase _appDB;

  ScriptureRepo(this._appDB);

  /// Saves a new list from freshly-built items (their `listId`/`sortOrder`
  /// are set here, like Android does before inserting). Returns the new
  /// list's id.
  Future<int> saveList(List<ScriptureItem> items, {String? name}) async {
    if (items.isEmpty) {
      throw ArgumentError('Cannot save an empty scripture list');
    }
    final listName =
        (name != null && name.trim().isNotEmpty) ? name.trim() : items.first.reference;
    final listId = await _appDB.scriptureListsDao.insert(
      ScriptureList(
        name: listName,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    for (var i = 0; i < items.length; i++) {
      items[i].listId = listId;
      items[i].sortOrder = i;
    }
    await _appDB.scriptureItemsDao.insertAll(items);
    return listId;
  }

  Future<List<ScriptureList>> getAllLists() => _appDB.scriptureListsDao.getAll();

  Future<ScriptureList?> getList(int listId) =>
      _appDB.scriptureListsDao.getById(listId);

  Future<List<ScriptureItem>> getItems(int listId) =>
      _appDB.scriptureItemsDao.getForList(listId);

  Future<int> getItemCount(int listId) async =>
      await _appDB.scriptureItemsDao.countForList(listId) ?? 0;

  Future<void> renameList(int listId, String name) =>
      _appDB.scriptureListsDao.rename(listId, name);

  Future<void> deleteList(int listId) async {
    await _appDB.scriptureItemsDao.deleteForList(listId);
    await _appDB.scriptureListsDao.delete(listId);
  }
}
