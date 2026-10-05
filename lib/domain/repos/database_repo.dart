// Project imports:
import '../../data/models/models.dart';

abstract class DatabaseRepo {
  Future<List<SongBook>> fetchBooks();

  Future<void> saveBook(SongBook book);

  Future<void> removeBook(SongBook book);

  Future<void> removeAllBooks();

  Future<List<SongExt>> fetchSongs({int bid = 0});

  Future<List<SongExt>> fetchLikes();

  Future<Song?> findSongById(int rid);

  Future<void> saveSong(Song song);

  Future<void> updateSong(
    int rid,
    String title,
    String content,
    bool liked,
    String updated,
  );

  Future<void> syncSong(
    int rid,
    String title,
    String content,
    String updated,
  );

  Future<void> removeSong(Song song);

  Future<void> removeAllSongs();

  Future<List<SongDraft>> fetchSongDrafts();

  Future<void> saveSongDraft(SongDraft draft);

  Future<void> removeSongDraft(SongDraft draft);

  Future<void> removeAllSongDrafts();

  Future<List<SongEdit>> fetchSongEdits();

  Future<void> saveSongEdit(SongEdit edit);

  Future<void> removeSongEdit(SongEdit edit);

  Future<void> removeAllSongEdits();

  Future<List<SongList>> fetchSongLists();

  Future<List<SongListExt>> fetchSongListExts();

  Future<void> saveSongList(SongList songList);

  Future<void> removeSongList(SongList songList);

  Future<void> removeAllSongLists();

  Future<List<SearchEntry>> fetchSearches();

  Future<void> saveSearch(SearchEntry search);

  Future<void> removeSearch(SearchEntry search);

  Future<void> removeAllSearches();

  Future<List<HistoryEntry>> fetchHistories();

  Future<List<HistoryExt>> fetchHistoryExts();

  Future<void> saveHistory(HistoryEntry history);

  Future<void> removeHistory(HistoryEntry history);

  Future<void> removeAllHistories();
}
