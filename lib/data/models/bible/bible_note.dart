import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../core/utils/constants/bible_constants.dart';

part 'bible_note.g.dart';

/// A user note attached to a verse. Ported from biblelib-android's
/// `NoteEntity` (`notes` table).
@Entity(
  tableName: BibleConstants.notesTable,
  primaryKeys: ['verseId', 'bibleAbbr'],
  indices: [
    Index(value: ['bibleAbbr']),
    Index(value: ['chapterId']),
  ],
)
@JsonSerializable()
class BibleNote {
  String verseId;
  String bibleAbbr;
  String bookId;
  String chapterId;
  String title;
  String verseText;
  String noteText;
  int updatedAt;

  BibleNote({
    required this.verseId,
    required this.bibleAbbr,
    required this.bookId,
    required this.chapterId,
    required this.title,
    required this.verseText,
    required this.noteText,
    required this.updatedAt,
  });

  factory BibleNote.fromJson(Map<String, dynamic> json) =>
      _$BibleNoteFromJson(json);

  Map<String, dynamic> toJson() => _$BibleNoteToJson(this);
}
