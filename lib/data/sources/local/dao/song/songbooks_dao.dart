// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../../../common/utils/constants/song_constants.dart';
import '../../../../models/song/songbook.dart';

@dao
abstract class SongBooksDao {
  @Query('SELECT * FROM ${SongConstants.booksTable} WHERE rid = :rid')
  Future<SongBook?> findBookById(int rid);

  @Query('SELECT * FROM ${SongConstants.booksTable}')
  Future<List<SongBook>> fetchBooks();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertBook(SongBook book);

  @update
  Future<void> updateBook(SongBook book);

  @delete
  Future<void> deleteBook(SongBook book);

  @Query("DELETE FROM ${SongConstants.booksTable}")
  Future<void> deleteAllBooks();
}
