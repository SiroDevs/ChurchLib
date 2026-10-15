// Project imports:
import '../../../data/models/bible/bible_bookmark.dart';
import '../../../data/models/bible/bible_note.dart';
import '../../../data/sources/local/app_database.dart';

class BibleAnnotationRepo {
  final AppDatabase _appDB;

  BibleAnnotationRepo(this._appDB);

  Future<Map<String, String?>> getBookmarksForChapter(
    String abbr,
    String chapterId,
  ) async {
    final rows = await _appDB.bibleBookmarksDao.getForChapter(abbr, chapterId);
    return {for (final r in rows) r.verseId: r.colorHex};
  }

  Future<Set<String>> getNotedVerseIds(String abbr, String chapterId) async {
    final ids = await _appDB.bibleNotesDao.getVerseIdsForChapter(
      abbr,
      chapterId,
    );
    return ids.toSet();
  }

  Future<void> setBookmarks(
    String abbr,
    Iterable<String> verseIds,
    String bookId,
    String chapterId, {
    String? colorHex,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _appDB.bibleBookmarksDao.insertAll([
      for (final verseId in verseIds)
        BibleBookmark(
          verseId: verseId,
          bibleAbbr: abbr,
          bookId: bookId,
          chapterId: chapterId,
          colorHex: colorHex,
          createdAt: now,
        ),
    ]);
  }

  Future<void> removeBookmarks(String abbr, Iterable<String> verseIds) {
    return _appDB.bibleBookmarksDao.deleteVerses(abbr, verseIds.toList());
  }

  Future<BibleNote?> getNote(String abbr, String verseId) =>
      _appDB.bibleNotesDao.getForVerse(abbr, verseId);

  Future<void> saveNote(BibleNote note) => _appDB.bibleNotesDao.upsert(note);

  Future<void> deleteNote(String abbr, String verseId) =>
      _appDB.bibleNotesDao.delete(abbr, verseId);

  Future<void> deleteBookmarks(List<BibleBookmark> bookmarks) async {
    final byBible = <String, List<String>>{};
    for (final b in bookmarks) {
      (byBible[b.bibleAbbr] ??= []).add(b.verseId);
    }
    for (final e in byBible.entries) {
      await _appDB.bibleBookmarksDao.deleteVerses(e.key, e.value);
    }
  }

  Future<void> deleteNotes(List<BibleNote> notes) async {
    for (final n in notes) {
      await _appDB.bibleNotesDao.delete(n.bibleAbbr, n.verseId);
    }
  }

  Future<List<BibleBookmark>> getAllBookmarks() =>
      _appDB.bibleBookmarksDao.getAll();

  Future<List<BibleNote>> getAllNotes() => _appDB.bibleNotesDao.getAll();
}
