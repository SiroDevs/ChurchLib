// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_book.g.dart';

/// A book (e.g. Genesis, Matthew) within one [BibleVersion]. Ported from
/// biblelib-android's `BookEntity` (`books` table) — composite key
/// (id, bibleAbbr) since the same book id repeats across translations.
@Entity(
  tableName: BibleConstants.booksTable,
  primaryKeys: ['id', 'bibleAbbr'],
  indices: [Index(value: ['bibleAbbr'])],
)
@JsonSerializable()
class BibleBook {
  String id;
  String bibleAbbr;
  String abbreviation;
  String name;
  String nameLong;
  int sortOrder;

  BibleBook({
    required this.id,
    required this.bibleAbbr,
    required this.abbreviation,
    required this.name,
    required this.nameLong,
    this.sortOrder = 0,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) =>
      _$BibleBookFromJson(json);

  Map<String, dynamic> toJson() => _$BibleBookToJson(this);
}
