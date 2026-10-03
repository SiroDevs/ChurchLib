// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_verse_cache.dart';

/// Ported from biblelib-android's `VerseDao`.
@dao
abstract class BibleVersesDao {
  @Query(
    'SELECT * FROM ${BibleConstants.versesTable} '
    'WHERE bibleAbbr = :abbr AND chapterId = :chapterId LIMIT 1',
  )
  Future<BibleVerseCache?> getChapter(String abbr, String chapterId);

  @Query(
    'SELECT chapterId FROM ${BibleConstants.versesTable} '
    'WHERE bibleAbbr = :abbr',
  )
  Future<List<String>> getCachedChapterIds(String abbr);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(BibleVerseCache verse);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<BibleVerseCache> items);

  @Query('DELETE FROM ${BibleConstants.versesTable} WHERE bibleAbbr = :abbr')
  Future<void> deleteByBible(String abbr);

  @Query('DELETE FROM ${BibleConstants.versesTable}')
  Future<void> deleteAll();

  @Query(
    'SELECT * FROM ${BibleConstants.versesTable} '
    "WHERE bibleAbbr = :abbr AND contentJson LIKE '%' || :query || '%'",
  )
  Future<List<BibleVerseCache>> searchInBible(String abbr, String query);
}
