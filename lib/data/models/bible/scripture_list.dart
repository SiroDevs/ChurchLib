// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'scripture_list.g.dart';

@Entity(tableName: BibleConstants.scriptureListsTable)
@JsonSerializable()
class ScriptureList {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String name;
  int createdAt;

  ScriptureList({
    this.id,
    required this.name,
    required this.createdAt,
  });

  factory ScriptureList.fromJson(Map<String, dynamic> json) =>
      _$ScriptureListFromJson(json);

  Map<String, dynamic> toJson() => _$ScriptureListToJson(this);
}
