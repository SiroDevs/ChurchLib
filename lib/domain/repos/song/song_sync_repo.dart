// Dart imports:
import 'dart:convert';

// Project imports:
import '../../../core/di/injectable.dart';
import '../../../common/utils/constants/pref_constants.dart';
import '../../../data/models/models.dart';
import '../database_repo.dart';
import '../pref_repo.dart';
import 'song_selection_repo.dart';

class SongSyncRepo {
  final _prefRepo = getIt<PrefRepo>();
  final _dbRepo = getIt<DatabaseRepo>();
  final _selectRepo = SongSelectionRepo();

  Future<bool> syncData() async {
    bool updatesMade = false;
    String selectedBooks =
        _prefRepo.getPrefString(PrefConstants.selectedBooksKey);
    var resp = await _selectRepo.getSongsByBooks(selectedBooks);

    if (resp.statusCode == 200) {
      List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(
        jsonDecode(resp.body)['data'],
      );
      final fetchedSongs = dataList.map((item) => Song.fromJson(item)).toList();

      final storedSongs = await _dbRepo.fetchSongs();
      final storedSongsMap = {for (var song in storedSongs) song.songId: song};

      final updateTasks = fetchedSongs.map((song) async {
        final dbSong = storedSongsMap[song.songId];

        if (dbSong == null ||
            dbSong.title != song.title ||
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
      }).toList();
      await Future.wait(updateTasks);
    }
    return updatesMade;
  }
}
