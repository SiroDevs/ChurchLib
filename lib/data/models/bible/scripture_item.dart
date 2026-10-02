import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../core/utils/constants/bible_constants.dart';

part 'scripture_item.g.dart';

/// A single book/chapter/verse reference belonging to a [ScriptureList].
/// Ported from biblelib-android's `ScriptureItemEntity`
/// (`scripture_items` table).
@Entity(
  tableName: BibleConstants.scriptureItemsTable,
  indices: [Index(value: ['listId'])],
)
@JsonSerializable()
class ScriptureItem {
  @PrimaryKey(autoGenerate: true)
  int? id;
  int listId;
  String bibleAbbr;
  String bibleName;
  String bookId;
  String bookName;
  String bookAbbr;
  String chapterId;
  String chapterNumber;
  String verseId;
  int verseNumber;

  /// Display label, e.g. "Genesis 1:1".
  String reference;
  int sortOrder;
  int addedAt;

  ScriptureItem({
    this.id,
    this.listId = 0,
    required this.bibleAbbr,
    required this.bibleName,
    required this.bookId,
    required this.bookName,
    required this.bookAbbr,
    required this.chapterId,
    required this.chapterNumber,
    required this.verseId,
    required this.verseNumber,
    required this.reference,
    this.sortOrder = 0,
    required this.addedAt,
  });

  factory ScriptureItem.fromJson(Map<String, dynamic> json) =>
      _$ScriptureItemFromJson(json);

  Map<String, dynamic> toJson() => _$ScriptureItemToJson(this);
}
