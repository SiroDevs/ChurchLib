// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/song_constants.dart';
import '../../../../models/song/songList.dart';
import '../../../../models/song/songListext.dart';

@dao
abstract class SongListsDao {
  @Query('SELECT * FROM ${SongConstants.listsTable}')
  Future<List<SongList>> fetchSongLists();

  @Query('SELECT * FROM ${SongConstants.listsTableViews}')
  Stream<List<SongListExt>> fetchSongListExts();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSongList(SongList songList);

  @delete
  Future<void> deleteSongList(SongList songList);

  @Query("DELETE FROM ${SongConstants.listsTable}")
  Future<void> deleteAllSongLists();
}
