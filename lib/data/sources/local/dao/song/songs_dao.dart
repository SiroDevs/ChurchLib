// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/song_constants.dart';
import '../../../../models/song/song.dart';
import '../../../../models/song/songext.dart';

@dao
abstract class SongsDao {
  @Query('SELECT * FROM ${SongConstants.songsTable} WHERE rid = :rid')
  Future<Song?> findSongById(int rid);

  @Query('SELECT * FROM ${SongConstants.songsTableViews}')
  Stream<List<SongExt>> fetchAllSongs();

  @Query('SELECT * FROM ${SongConstants.songsTableViews} WHERE book = :bid')
  Stream<List<SongExt>> fetchSongs(int bid);

  @Query('SELECT * FROM ${SongConstants.songsTableViews} WHERE liked = 1')
  Stream<List<SongExt>> fetchLikes();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSong(Song song);

  @Query(
    'UPDATE ${SongConstants.songsTable} '
    'SET title = :title, content = :content, liked = :liked, updated = :updated WHERE rid = :rid',
  )
  Future<void> updateSong(
    int rid,
    String title,
    String content,
    bool liked,
    String updated,
  );

  @Query(
    'UPDATE ${SongConstants.songsTable} '
    'SET title = :title, alias = :alias, content = :content WHERE songId = :songId',
  )
  Future<void> syncSong(
    int songId,
    String title,
    String alias,
    String content,
  );

  @delete
  Future<void> deleteSong(Song song);

  @Query("DELETE FROM ${SongConstants.songsTable} WHERE book = :bookId")
  Future<void> deleteSongsByBook(int bookId);

  @Query("DELETE FROM ${SongConstants.songsTable}")
  Future<void> deleteAllSongs();
}
