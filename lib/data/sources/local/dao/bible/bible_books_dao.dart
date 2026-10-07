// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_book.dart';

@dao
abstract class BibleBooksDao {
  @Query(
    'SELECT * FROM ${BibleConstants.booksTable} '
    'WHERE bibleAbbr = :abbr ORDER BY sortOrder ASC',
  )
  Future<List<BibleBook>> getByBible(String abbr);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<BibleBook> records);

  @Query('DELETE FROM ${BibleConstants.booksTable} WHERE bibleAbbr = :abbr')
  Future<void> deleteByBible(String abbr);

  @Query('DELETE FROM ${BibleConstants.booksTable}')
  Future<void> deleteAll();
}
