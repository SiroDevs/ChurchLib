class ApiConstants {
  /// 'https://songlive.vercel.app/api'
  static String songliveApi = 'https://songlive.vercel.app/api/v2';

  /// books route: '/book'
  static const String books = '/books';
  static const String songs = '/songs';
  static const String songsByBook = '/songs/books/';

  /// Songs are served in pages (`{data: [...], pagination: {...}}`).
  static const int songsPageLimit = 500;

  static String bibleApi = 'https://biblive.vercel.app/v2';
}
