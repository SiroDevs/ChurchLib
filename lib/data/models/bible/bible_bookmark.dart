import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../core/utils/constants/bible_constants.dart';

part 'bible_bookmark.g.dart';

/// A bookmarked verse. Ported from biblelib-android's `BookmarkEntity`
/// (`bookmarks` table).
///
/// [colorHex] is null for a "quick" single-verse bookmark (swipe action) —
/// shown in the reader as a small bookmark icon next to the verse. When a
/// color is set (chosen via the multi-select highlight flow) the verse row
/// is rendered with that color as a background wash.
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
