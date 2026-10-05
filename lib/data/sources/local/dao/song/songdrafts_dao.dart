// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/song_constants.dart';
import '../../../../models/song/songdraft.dart';

@dao
abstract class SongDraftsDao {
  @Query('SELECT * FROM ${SongConstants.draftsTable} WHERE rid = :rid')
  Future<SongDraft?> findSongDraftById(int rid);

  @Query('SELECT * FROM ${SongConstants.draftsTable}')
  Future<List<SongDraft>> fetchSongDrafts();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSongDraft(SongDraft draft);

  @update
  Future<void> updateSongDraft(SongDraft draft);

  @delete
  Future<void> deleteSongDraft(SongDraft draft);

  @Query("DELETE FROM ${SongConstants.draftsTable}")
  Future<void> deleteAllSongDrafts();
}
