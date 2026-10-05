/// Table names for BibleLib's froom entities, living alongside SongLib's
/// tables (see [AppConstants]) in the same shared ChurchLib database.
///
/// Prefixed with `bible_` throughout — SongLib already owns `books`, so
/// every BibleLib table is prefixed for clarity and to avoid any future
/// collision, not just the one that would otherwise clash. Search and
/// history are NOT here — they're shared tables; see
/// `AppConstants.searchesTable`/`historiesTable` and `EntrySource`.
///
/// Ported from biblelib-android's Room schema
/// (core/database/src/main/java/com/biblelib/core/database/entities).
class BibleConstants {
  BibleConstants._();

  static const String biblesTable = 'bible_bibles';
  static const String booksTable = 'bible_books';
  static const String chaptersTable = 'bible_chapters';
  static const String versesTable = 'bible_verses';
  static const String bookmarksTable = 'bible_bookmarks';
  static const String notesTable = 'bible_notes';
  static const String scriptureListsTable = 'bible_scripture_lists';
  static const String scriptureItemsTable = 'bible_scripture_items';
}
