// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

@Entity(tableName: SongConstants.listsTable)
class SongList {
  @PrimaryKey(autoGenerate: true)
  int? rid;
  int? parentid;
  int? song;
  String? title;
  String? description;
  int? position;
  String? created;
  String? updated;

  SongList({
    this.rid,
    this.parentid,
    this.song,
    this.title,
    this.description,
    this.position,
    this.created,
    this.updated,
  });
}
