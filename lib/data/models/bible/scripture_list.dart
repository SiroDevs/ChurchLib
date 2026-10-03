// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'scripture_list.g.dart';

/// A named collection of scriptures built via the Scripture Opener, e.g.
/// for a sermon or a devotional reading plan. [name] defaults to the
/// reference of the first scripture added, but can be renamed by the user.
/// Ported from biblelib-android's `ScriptureListEntity`
/// (`scripture_lists` table).
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
