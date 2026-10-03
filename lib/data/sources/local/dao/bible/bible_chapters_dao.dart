// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_chapter.dart';

/// Ported from biblelib-android's `ChapterDao`.
@dao
abstract class BibleChaptersDao {
  @Query(
    'SELECT * FROM ${BibleConstants.chaptersTable} '
    'WHERE bibleAbbr = :abbr AND bookId = :bookId '
    'ORDER BY CAST(number AS INTEGER) ASC',
  )
  Future<List<BibleChapter>> getByBook(String abbr, String bookId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<BibleChapter> records);

  @Query('DELETE FROM ${BibleConstants.chaptersTable} WHERE bibleAbbr = :abbr')
  Future<void> deleteByBible(String abbr);

  @Query('DELETE FROM ${BibleConstants.chaptersTable}')
  Future<void> deleteAll();
}
