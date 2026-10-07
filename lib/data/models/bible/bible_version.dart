// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_version.g.dart';

@Entity(tableName: BibleConstants.biblesTable)
@JsonSerializable()
class BibleVersion {
  @PrimaryKey()
  String abbreviation;
  String name;
  String description;
  String languageName;
  String scriptDirection;
  int sortOrder;
  bool isDownloaded;
  int addedAt;
  String countryName;
  double downloadProgress;
  bool downloadFailed;
  String path;

  BibleVersion({
    required this.abbreviation,
    required this.name,
    required this.description,
    required this.languageName,
    required this.scriptDirection,
    this.sortOrder = 0,
    this.isDownloaded = false,
    required this.addedAt,
    this.countryName = '',
    this.downloadProgress = 0,
    this.downloadFailed = false,
    required this.path,
  });

  factory BibleVersion.fromJson(Map<String, dynamic> json) =>
      _$BibleVersionFromJson(json);

  Map<String, dynamic> toJson() => _$BibleVersionToJson(this);
}
