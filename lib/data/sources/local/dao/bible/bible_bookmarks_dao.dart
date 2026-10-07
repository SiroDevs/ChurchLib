// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_bookmark.dart';

@dao
abstract class BibleBookmarksDao {
  @Query(
    'SELECT * FROM ${BibleConstants.bookmarksTable} '
    'WHERE bibleAbbr = :abbr AND chapterId = :chapterId',
  )
  Future<List<BibleBookmark>> getForChapter(String abbr, String chapterId);

  @Query(
    'SELECT * FROM ${BibleConstants.bookmarksTable} ORDER BY createdAt DESC',
  )
  Future<List<BibleBookmark>> getAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<BibleBookmark> records);

  @Query(
    'DELETE FROM ${BibleConstants.bookmarksTable} '
    'WHERE bibleAbbr = :abbr AND verseId IN (:verseIds)',
  )
  Future<void> deleteVerses(String abbr, List<String> verseIds);

  @Query('DELETE FROM ${BibleConstants.bookmarksTable} WHERE bibleAbbr = :abbr')
  Future<void> deleteByBible(String abbr);

  @Query('DELETE FROM ${BibleConstants.bookmarksTable}')
  Future<void> deleteAll();
}
