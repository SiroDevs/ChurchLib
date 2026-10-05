// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

@Entity(tableName: SongConstants.historiesTable)
class HistoryEntry {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String source;
  String refId;
  String? bibleAbbr;
  String? bibleName;
  String? bookId;
  String? bookName;
  String? chapterRef;
  int? verseNumber;
  String? dayKey;
  int occurredAt;

  HistoryEntry({
    this.id,
    required this.source,
    required this.refId,
    this.bibleAbbr,
    this.bibleName,
    this.bookId,
    this.bookName,
    this.chapterRef,
    this.verseNumber,
    this.dayKey,
    required this.occurredAt,
  });
}
