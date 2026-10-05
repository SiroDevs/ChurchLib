// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

part 'songedit.g.dart';

@Entity(tableName: SongConstants.editsTable)
@JsonSerializable()
class SongEdit {
  @PrimaryKey(autoGenerate: true)
  int? rid;
  String? song;
  int? book;
  int? songNo;
  String? title;
  String? alias;
  String? content;
  String? key;
  String? created;
  String? updated;

  SongEdit({
    this.rid,
    this.song,
    this.book,
    this.songNo,
    this.title,
    this.alias,
    this.content,
    this.key,
    this.created,
    this.updated,
  });

  factory SongEdit.fromJson(Map<String, dynamic> json) => _$SongEditFromJson(json);

  Map<String, dynamic> toJson() => _$SongEditToJson(this);
}
