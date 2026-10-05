// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/song_constants.dart';
import '../../../../models/song/songedit.dart';

@dao
abstract class SongEditsDao {
  @Query('SELECT * FROM ${SongConstants.editsTable} WHERE rid = :rid')
  Future<SongEdit?> findSongEditById(int rid);

  @Query('SELECT * FROM ${SongConstants.editsTable}')
  Future<List<SongEdit>> fetchSongEdits();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSongEdit(SongEdit edit);

  @update
  Future<void> updateSongEdit(SongEdit edit);

  @delete
  Future<void> deleteSongEdit(SongEdit edit);

  @Query("DELETE FROM ${SongConstants.editsTable}")
  Future<void> deleteAllSongEdits();
}
