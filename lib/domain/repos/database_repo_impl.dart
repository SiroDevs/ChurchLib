// Project imports:
import '../../data/models/models.dart';
import '../../data/sources/local/app_database.dart';
import 'database_repo.dart';

class DatabaseRepoImpl implements DatabaseRepo {
  final AppDatabase _appDB;

  DatabaseRepoImpl(this._appDB);

  @override
  Future<List<SongBook>> fetchBooks() async {
    return _appDB.booksDao.fetchBooks();
  }

  @override
  Future<void> removeBook(SongBook book) async {
    return _appDB.booksDao.deleteBook(book);
  }

  @override
  Future<void> removeBookByBookId(int bookId) async {
    return _appDB.booksDao.deleteBookByBookId(bookId);
  }

  @override
  Future<void> saveBook(SongBook book) async {
    return _appDB.booksDao.insertBook(book);
  }

  @override
  Future<void> removeAllBooks() async {
    return _appDB.booksDao.deleteAllBooks();
  }

  @override
  Future<Song?> findSongById(int rid) async {
    return _appDB.songsDao.findSongById(rid);
  }

  @override
  Future<List<SongExt>> fetchSongs({int bid = 0}) async {
    late Stream<List<SongExt>> streams;
    if (bid == 0) {
      streams = _appDB.songsDao.fetchAllSongs();
    } else {
      streams = _appDB.songsDao.fetchSongs(bid);
    }
    return await streams.first;
  }

  @override
  Future<List<SongExt>> fetchLikes() async {
    final Stream<List<SongExt>> streams = _appDB.songsDao.fetchLikes();
    return await streams.first;
  }

  @override
  Future<void> removeSong(Song song) async {
    return _appDB.songsDao.deleteSong(song);
  }

  @override
  Future<void> removeSongsByBook(int bookId) async {
    return _appDB.songsDao.deleteSongsByBook(bookId);
  }

  @override
  Future<void> saveSong(Song song) async {
    return _appDB.songsDao.insertSong(song);
  }

  @override
  Future<void> updateSong(
    int rid,
    String title,
    String content,
    bool liked,
    String updated,
  ) async {
    return _appDB.songsDao.updateSong(rid, title, content, liked, updated);
  }

  @override
  Future<void> syncSong(
    int songId,
    String title,
    String alias,
    String content,
  ) async {
    return _appDB.songsDao.syncSong(songId, title, alias, content);
  }

  @override
  Future<void> removeAllSongs() async {
    return _appDB.songsDao.deleteAllSongs();
  }

  @override
  Future<List<SongEdit>> fetchSongEdits() async {
    return _appDB.editsDao.fetchSongEdits();
  }

  @override
  Future<void> removeSongEdit(SongEdit edit) async {
    return _appDB.editsDao.deleteSongEdit(edit);
  }

  @override
  Future<void> saveSongEdit(SongEdit edit) async {
    return _appDB.editsDao.insertSongEdit(edit);
  }

  @override
  Future<void> removeAllSongEdits() async {
    return _appDB.editsDao.deleteAllSongEdits();
  }

  @override
  Future<List<SongDraft>> fetchSongDrafts() async {
    return _appDB.draftsDao.fetchSongDrafts();
  }

  @override
  Future<void> removeSongDraft(SongDraft draft) async {
    return _appDB.draftsDao.deleteSongDraft(draft);
  }

  @override
  Future<void> saveSongDraft(SongDraft draft) async {
    return _appDB.draftsDao.insertSongDraft(draft);
  }

  @override
  Future<void> removeAllSongDrafts() async {
    return _appDB.draftsDao.deleteAllSongDrafts();
  }

  @override
  Future<List<SongList>> fetchSongLists() async {
    return _appDB.songListsDao.fetchSongLists();
  }

  @override
  Future<List<SongListExt>> fetchSongListExts() async {
    final Stream<List<SongListExt>> streams = _appDB.songListsDao.fetchSongListExts();
    return await streams.first;
  }

  @override
  Future<void> removeSongList(SongList songList) async {
    return _appDB.songListsDao.deleteSongList(songList);
  }

  @override
  Future<void> saveSongList(SongList songList) async {
    return _appDB.songListsDao.insertSongList(songList);
  }

  @override
  Future<void> removeAllSongLists() async {
    return _appDB.songListsDao.deleteAllSongLists();
  }

  @override
  Future<List<SearchEntry>> fetchSearches() async {
    return _appDB.searchesDao.fetchRecent(EntrySource.song, 50);
  }

  @override
  Future<void> removeSearch(SearchEntry search) async {
    return _appDB.searchesDao.deleteSearch(search);
  }

  @override
  Future<void> saveSearch(SearchEntry search) async {
    return _appDB.searchesDao.insertSearch(search);
  }

  @override
  Future<void> removeAllSearches() async {
    return _appDB.searchesDao.deleteAllSearches(EntrySource.song);
  }

  @override
  Future<List<HistoryEntry>> fetchHistories() async {
    return _appDB.historiesDao.fetchRecent(EntrySource.song, 100);
  }

  @override
  Future<List<HistoryExt>> fetchHistoryExts() async {
    final Stream<List<HistoryExt>> streams =
        _appDB.historiesDao.fetchHistoryExts();
    return await streams.first;
  }

  @override
  Future<void> removeHistory(HistoryEntry history) async {
    return _appDB.historiesDao.deleteHistory(history);
  }

  @override
  Future<void> saveHistory(HistoryEntry history) async {
    return _appDB.historiesDao.insertHistory(history);
  }

  @override
  Future<void> removeAllHistories() async {
    return _appDB.historiesDao.deleteAllHistories(EntrySource.song);
  }
}
