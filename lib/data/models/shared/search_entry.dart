// Package imports:
import 'package:froom/froom.dart';

// Project imports:
import '../../../common/utils/constants/song_constants.dart';

@Entity(tableName: SongConstants.searchesTable)
class SearchEntry {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String source;
  String query;
  int queriedAt;

  SearchEntry({
    this.id,
    required this.source,
    required this.query,
    required this.queriedAt,
  });
}
