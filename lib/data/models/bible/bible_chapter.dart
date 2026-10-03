// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_chapter.g.dart';

/// A chapter within a [BibleBook]. Ported from biblelib-android's
/// `ChapterEntity` (`chapters` table).
@Entity(
  tableName: BibleConstants.chaptersTable,
  primaryKeys: ['id', 'bibleAbbr'],
  indices: [
    Index(value: ['bibleAbbr']),
    Index(value: ['bookId']),
  ],
)
@JsonSerializable()
class BibleChapter {
  String id;
  String bibleAbbr;
  String bookId;
  String number;
  String reference;

  BibleChapter({
    required this.id,
    required this.bibleAbbr,
    required this.bookId,
    required this.number,
    required this.reference,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) =>
      _$BibleChapterFromJson(json);

  Map<String, dynamic> toJson() => _$BibleChapterToJson(this);
}
