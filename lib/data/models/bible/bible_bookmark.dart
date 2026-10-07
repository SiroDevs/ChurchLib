// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_bookmark.g.dart';

@Entity(
  tableName: BibleConstants.bookmarksTable,
  primaryKeys: ['verseId', 'bibleAbbr'],
  indices: [
    Index(value: ['bibleAbbr']),
    Index(value: ['chapterId']),
  ],
)
@JsonSerializable()
class BibleBookmark {
  String verseId;
  String bibleAbbr;
  String bookId;
  String chapterId;
  String? colorHex;
  int createdAt;

  BibleBookmark({
    required this.verseId,
    required this.bibleAbbr,
    required this.bookId,
    required this.chapterId,
    this.colorHex,
    required this.createdAt,
  });

  factory BibleBookmark.fromJson(Map<String, dynamic> json) =>
      _$BibleBookmarkFromJson(json);

  Map<String, dynamic> toJson() => _$BibleBookmarkToJson(this);
}
