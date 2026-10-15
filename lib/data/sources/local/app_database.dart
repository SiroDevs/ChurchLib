// Dart imports:
import 'dart:async';

// Package imports:
import 'package:froom/froom.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Project imports:
import '../../models/models.dart';
import 'dao/bible/bible_bookmarks_dao.dart';
import 'dao/bible/bible_books_dao.dart';
import 'dao/bible/bible_chapters_dao.dart';
import 'dao/bible/bible_notes_dao.dart';
import 'dao/bible/bible_verses_dao.dart';
import 'dao/bible/bible_versions_dao.dart';
import 'dao/bible/scripture_items_dao.dart';
import 'dao/bible/scripture_lists_dao.dart';
import 'dao/histories_dao.dart';
import 'dao/searches_dao.dart';
import 'dao/song/songbooks_dao.dart';
import 'dao/song/songdrafts_dao.dart';
import 'dao/song/songedits_dao.dart';
import 'dao/song/songlists_dao.dart';
import 'dao/song/songs_dao.dart';

part 'app_database.g.dart';

@Database(
  version: 1,
  entities: [
    HistoryEntry,
    SearchEntry,
    SongBook,
    SongDraft,
    SongEdit,
    SongList,
    Song,
    BibleBook,
    BibleBookmark,
    BibleChapter,
    BibleNote,
    BibleVerseCache,
    BibleVersion,
    ScriptureItem,
    ScriptureList,
  ],
  views: [HistoryExt, SongExt, SongListExt],
)
abstract class AppDatabase extends FroomDatabase {
  HistoriesDao get historiesDao;
  SearchesDao get searchesDao;

  SongBooksDao get booksDao;
  SongDraftsDao get draftsDao;
  SongEditsDao get editsDao;
  SongListsDao get songListsDao;
  SongsDao get songsDao;

  BibleBooksDao get bibleBooksDao;
  BibleBookmarksDao get bibleBookmarksDao;
  BibleChaptersDao get bibleChaptersDao;
  BibleNotesDao get bibleNotesDao;
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
