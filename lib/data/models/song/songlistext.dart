// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

@DatabaseView(
  '${SongConstants.listExtSql};',
  viewName: SongConstants.listsTableViews,
)
class SongListExt {
  int rid;
  int parentid;
  int position;
  String created;
  String updated;
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

  SongListExt(
    this.rid,
    this.parentid,
    this.position,
    this.created,
    this.updated,
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
