// Project imports:
import '../../../common/utils/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../database_repo.dart';
import '../pref_repo.dart';
import 'song_selection_repo.dart';

class SongSyncRepo {
  final _prefRepo = getIt<PrefRepo>();
  final _dbRepo = getIt<DatabaseRepo>();
  final _selectRepo = SongSelectionRepo();

  Future<bool> syncData() async {
    final selectedBooks =
        _prefRepo.getPrefString(PrefConstants.selectedBooksKey);
    if (selectedBooks.isEmpty) return false;

    final fetchedSongs = await _selectRepo.fetchSongsByBooks(selectedBooks);

    final storedSongs = await _dbRepo.fetchSongs();
    final storedSongsMap = {for (final song in storedSongs) song.songId: song};

    var updatesMade = false;
    for (final song in fetchedSongs) {
      final dbSong = storedSongsMap[song.songId];
      if (dbSong == null) {
        await _dbRepo.saveSong(song);
        updatesMade = true;
      } else if (dbSong.title != song.title ||
          dbSong.alias != song.alias ||
          dbSong.content != song.content) {
        await _dbRepo.syncSong(
          song.songId ?? 0,
          song.title ?? '',
          song.alias ?? '',
          song.content ?? '',
        );
        updatesMade = true;
      }
    }
    return updatesMade;
  }
}
