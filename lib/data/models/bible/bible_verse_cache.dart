// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_verse_cache.g.dart';

/// Cached verse content for one chapter. Ported from biblelib-android's
/// `VerseEntity` (`verses` table) — despite the name, Android stores one
/// row per *chapter* here, with all of that chapter's verses packed into
/// [contentJson], not one row per verse. Kept identical here so the same
/// parsing/caching logic can be ported later without a schema mismatch.
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
