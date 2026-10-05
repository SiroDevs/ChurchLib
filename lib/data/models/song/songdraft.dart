// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

part 'songdraft.g.dart';

@Entity(tableName: SongConstants.draftsTable)
@JsonSerializable()
class SongDraft {
  @PrimaryKey(autoGenerate: true)
  int? rid;
  int? songId;
  int? songNo;
  String? title;
  String? alias;
  String? content;
  int? views;
  int? likes;
  bool? liked;
  String? created;
  String? updated;

  SongDraft({
    this.rid,
    this.songId,
    this.songNo,
    this.title,
    this.alias,
    this.content,
    this.views,
    this.likes,
    this.liked,
    this.created,
    this.updated,
  });

  factory SongDraft.fromJson(Map<String, dynamic> json) => _$SongDraftFromJson(json);

  Map<String, dynamic> toJson() => _$SongDraftToJson(this);
}
