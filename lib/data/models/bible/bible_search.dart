// Package imports:
import 'package:froom/froom.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import '../../../common/utils/constants/bible_constants.dart';

part 'bible_search.g.dart';

/// A recent BibleLib search query. Ported from biblelib-android's
/// `SearchEntity` (`searches` table) — kept separate from SongLib's own
/// [Search] entity/table, since the two apps' search histories are
/// unrelated.
@Entity(tableName: BibleConstants.searchesTable)
@JsonSerializable()
class BibleSearch {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String qry;
  int queriedAt;

  BibleSearch({
    this.id,
    required this.qry,
    required this.queriedAt,
  });

  factory BibleSearch.fromJson(Map<String, dynamic> json) =>
      _$BibleSearchFromJson(json);

  Map<String, dynamic> toJson() => _$BibleSearchToJson(this);
}
