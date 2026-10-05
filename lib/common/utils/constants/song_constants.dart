
class SongConstants {
  SongConstants._();
  static const String editsTable = 'song_edits';
  static const String draftsTable = 'song_drafts';
  static const String booksTable = 'song_books';
  static const String songsTable = 'songs';
  static const String listsTable = 'song_lists';
  static const String searchesTable = 'search_entries';
  static const String historiesTable = 'history_entries';

  static const String songExtSql =
      'SELECT s.rid, s.book, s.songId, s.songNo, s.title, s.alias, '
      's.content, s.views, s.likes, s.liked, b.title AS songbook '
      'FROM $songsTable AS s '
      'LEFT JOIN $booksTable AS b '
      'ON s.book=b.bookNo '
      'ORDER BY songNo ASC';

  static const String historyExtSql =
      'SELECT s.rid, s.book, s.songId, s.songNo, s.title, s.alias, '
      's.content, s.views, s.likes, s.liked, b.title AS songbook '
      'FROM $songsTable AS s '
      'LEFT JOIN $booksTable AS b ON s.book=b.bookNo '
      'ORDER BY songNo ASC';

  static const String listExtSql =
      'SELECT l.parentid, l.id, l.position, l.id, l.created, l.updated, '
      'l.song, s.book, s.songNo, s.title, s.alias, s.content, s.views, '
      's.likes, s.liked, s.id AS songId, b.title AS songbook '
      'FROM $listsTable AS l '
      'LEFT JOIN $songsTable AS s ON l.song=s.id '
      'LEFT JOIN $booksTable AS b ON s.book=b.bookNo '
      'ORDER BY l.updated DESC';

  static const String songsTableViews = 'viewsongs';
  static const String listsTableViews = 'viewsongLists';
  static const String historiesTableViews = 'viewhistories';
}
