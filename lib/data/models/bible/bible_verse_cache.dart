// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_verse_cache.g.dart';

@Entity(
  tableName: BibleConstants.versesTable,
  primaryKeys: ['chapterId', 'bibleAbbr'],
  indices: [
    Index(value: ['bibleAbbr']),
    Index(value: ['bookId']),
    Index(value: ['chapterId']),
  ],
)
@JsonSerializable()
class BibleVerseCache {
  String chapterId;
  String bibleAbbr;
  String bookId;
  int verseCount;
  String contentJson;
  int cachedAt;

  BibleVerseCache({
    required this.chapterId,
    required this.bibleAbbr,
    required this.bookId,
    required this.verseCount,
    required this.contentJson,
    required this.cachedAt,
  });

  factory BibleVerseCache.fromJson(Map<String, dynamic> json) =>
      _$BibleVerseCacheFromJson(json);

  Map<String, dynamic> toJson() => _$BibleVerseCacheToJson(this);
}
