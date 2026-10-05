// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

part 'songbook.g.dart';

@Entity(tableName: SongConstants.booksTable)
@JsonSerializable()
class SongBook {
  @PrimaryKey(autoGenerate: true)
  int? rid;
  int? bookId;
  String? title;
  String? subTitle;
  int? songs;
  int? position;
  int? bookNo;
  bool? enabled;
  String? created;
  String? updated;

  SongBook({
    this.bookId,
    this.title,
    this.subTitle,
    this.songs,
    this.position,
    this.bookNo,
    this.enabled,
    this.created,
    this.updated,
  });

  factory SongBook.fromJson(Map<String, dynamic> json) => _$SongBookFromJson(json);

  Map<String, dynamic> toJson() => _$SongBookToJson(this);
}

