// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_history.g.dart';

/// A reading-history entry. Ported from biblelib-android's `HistoryEntity`
/// (`histories` table) — kept separate from SongLib's own [History]
/// entity/table.
@Entity(tableName: BibleConstants.historiesTable)
@JsonSerializable()
class BibleHistory {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String bibleAbbr;
  String bibleName;
  String bookId;
  String bookName;
  String chapterId;
  String chapterRef;
  int? verseNumber;
  String dayKey;
  int readAt;

  BibleHistory({
    this.id,
    required this.bibleAbbr,
    this.bibleName = '',
    required this.bookId,
    required this.bookName,
    required this.chapterId,
    required this.chapterRef,
    this.verseNumber,
    this.dayKey = '',
    required this.readAt,
  });

  factory BibleHistory.fromJson(Map<String, dynamic> json) =>
      _$BibleHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$BibleHistoryToJson(this);
}
