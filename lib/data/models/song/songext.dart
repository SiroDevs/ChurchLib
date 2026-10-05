// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

@DatabaseView(
  '${SongConstants.songExtSql};',
  viewName: SongConstants.songsTableViews,
)
class SongExt {
  int rid;
  int book;
  int songId;
  int songNo;
  String title;
  String alias;
  String content;
  int views;
  int likes;
  bool liked;
  String songbook;

  SongExt(
    this.rid,
    this.book,
    this.songId,
    this.songNo,
    this.title,
    this.alias,
    this.content,
    this.views,
    this.likes,
    this.liked,
    this.songbook,
  );
}

class SongExtSort {
  int bookNo;
  List<SongExt> songs;

  SongExtSort(this.bookNo, this.songs);
}
