// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_note.dart';

/// Ported from biblelib-android's `NoteDao`.
@dao
abstract class BibleNotesDao {
  @Query(
    'SELECT * FROM ${BibleConstants.notesTable} '
    'WHERE bibleAbbr = :abbr AND verseId = :verseId LIMIT 1',
  )
  Future<BibleNote?> getForVerse(String abbr, String verseId);

  @Query(
    'SELECT verseId FROM ${BibleConstants.notesTable} '
    'WHERE bibleAbbr = :abbr AND chapterId = :chapterId',
  )
  Future<List<String>> getVerseIdsForChapter(String abbr, String chapterId);

  @Query('SELECT * FROM ${BibleConstants.notesTable} ORDER BY updatedAt DESC')
  Future<List<BibleNote>> getAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(BibleNote note);

  @Query(
    'DELETE FROM ${BibleConstants.notesTable} '
    'WHERE bibleAbbr = :abbr AND verseId = :verseId',
  )
  Future<void> delete(String abbr, String verseId);

  @Query('DELETE FROM ${BibleConstants.notesTable} WHERE bibleAbbr = :abbr')
  Future<void> deleteByBible(String abbr);

  @Query('DELETE FROM ${BibleConstants.notesTable}')
  Future<void> deleteAll();
}
