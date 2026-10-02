import 'dart:async';

import 'package:froom/froom.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../models/models.dart';
import 'dao/bible/bible_bookmarks_dao.dart';
import 'dao/bible/bible_books_dao.dart';
import 'dao/bible/bible_chapters_dao.dart';
import 'dao/bible/bible_histories_dao.dart';
import 'dao/bible/bible_notes_dao.dart';
import 'dao/bible/bible_searches_dao.dart';
import 'dao/bible/bible_verses_dao.dart';
import 'dao/bible/bible_versions_dao.dart';
import 'dao/bible/scripture_items_dao.dart';
import 'dao/bible/scripture_lists_dao.dart';
import 'dao/songs/books_dao.dart';
import 'dao/songs/drafts_dao.dart';
import 'dao/songs/edits_dao.dart';
import 'dao/songs/histories_dao.dart';
import 'dao/songs/listeds_dao.dart';
import 'dao/songs/searches_dao.dart';
import 'dao/songs/songs_dao.dart';

part 'app_database.g.dart';

/// One shared database for all of ChurchLib. SongLib's entities/DAOs are
/// unchanged from songlib-flutter; BibleLib's entities/DAOs (ported from
/// biblelib-android's Room schema) live alongside them, using their own
/// `bible_`-prefixed tables (see BibleConstants) so nothing collides with
/// SongLib's `books`/`searches`/`histories`.
///
/// Version bumped 3 -> 4 for the BibleLib tables. There's no migration
/// path from v3 yet since ChurchLib has no existing installs to migrate;
/// add a Migration when that changes.
@Database(
  version: 4,
  entities: [
    // SongLib
    Book,
    Draft,
    Edit,
    History,
    Listed,
    Search,
    Song,
    // BibleLib
    BibleBook,
    BibleBookmark,
    BibleChapter,
    BibleHistory,
    BibleNote,
    BibleSearch,
    BibleVerseCache,
    BibleVersion,
    ScriptureItem,
    ScriptureList,
  ],
  views: [HistoryExt, ListedExt, SongExt],
)
abstract class AppDatabase extends FroomDatabase {
  // SongLib
  BooksDao get booksDao;
  DraftsDao get draftsDao;
  EditsDao get editsDao;
  HistoriesDao get historiesDao;
  ListedsDao get listedsDao;
  SearchesDao get searchesDao;
  SongsDao get songsDao;

  // BibleLib
  BibleBooksDao get bibleBooksDao;
  BibleBookmarksDao get bibleBookmarksDao;
  BibleChaptersDao get bibleChaptersDao;
  BibleHistoriesDao get bibleHistoriesDao;
  BibleNotesDao get bibleNotesDao;
  BibleSearchesDao get bibleSearchesDao;
  BibleVersesDao get bibleVersesDao;
  BibleVersionsDao get bibleVersionsDao;
  ScriptureItemsDao get scriptureItemsDao;
  ScriptureListsDao get scriptureListsDao;
}

Future<AppDatabase> buildInMemoryDatabase() {
  return $FroomAppDatabase
      .inMemoryDatabaseBuilder()
      .build();
}
