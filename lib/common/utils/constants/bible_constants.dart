/// Table names for BibleLib's froom entities, living alongside SongLib's
/// tables (see [AppConstants]) in the same shared ChurchLib database.
///
/// Prefixed with `bible_` throughout — SongLib already owns `books`,
/// `searches` and `histories`, and BibleLib needs its own versions of all
/// three, so every BibleLib table is prefixed for clarity and to avoid any
/// future collision, not just the three that would otherwise clash.
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
  static const String searchesTable = 'bible_searches';
  static const String historiesTable = 'bible_histories';
  static const String scriptureListsTable = 'bible_scripture_lists';
  static const String scriptureItemsTable = 'bible_scripture_items';
}
