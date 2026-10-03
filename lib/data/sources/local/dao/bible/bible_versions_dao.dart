// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/bible_constants.dart';
import '../../../../models/bible/bible_version.dart';

/// Ported from biblelib-android's `BibleDao`.
@dao
abstract class BibleVersionsDao {
  @Query(
    'SELECT * FROM ${BibleConstants.biblesTable} ORDER BY sortOrder ASC',
  )
  Future<List<BibleVersion>> getAll();

  @Query(
    'SELECT * FROM ${BibleConstants.biblesTable} '
    'WHERE abbreviation = :abbr LIMIT 1',
  )
  Future<BibleVersion?> getByAbbr(String abbr);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(BibleVersion bible);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<BibleVersion> records);

  // @delete
  // Future<void> delete(BibleVersion bible);

  @Query('DELETE FROM ${BibleConstants.biblesTable} WHERE abbreviation = :abbr')
  Future<void> deleteByAbbr(String abbr);

  @Query('DELETE FROM ${BibleConstants.biblesTable}')
  Future<void> deleteAll();

  @Query(
    'UPDATE ${BibleConstants.biblesTable} SET isDownloaded = 1, '
    'downloadFailed = 0, downloadProgress = 1.0 WHERE abbreviation = :abbr',
  )
  Future<void> markDownloaded(String abbr);

  @Query(
    'UPDATE ${BibleConstants.biblesTable} SET downloadProgress = :progress, '
    'downloadFailed = 0 WHERE abbreviation = :abbr',
  )
  Future<void> updateProgress(String abbr, double progress);

  @Query(
    'UPDATE ${BibleConstants.biblesTable} SET downloadFailed = 1, '
    'downloadProgress = :progress WHERE abbreviation = :abbr',
  )
  Future<void> markFailed(String abbr, double progress);

  @Query(
    'UPDATE ${BibleConstants.biblesTable} SET downloadFailed = 0 '
    'WHERE abbreviation = :abbr',
  )
  Future<void> clearFailed(String abbr);
}
