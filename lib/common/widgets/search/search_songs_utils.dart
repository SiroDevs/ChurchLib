import '../../../data/models/song/songext.dart';

List<SongExt> filterSongsByQuery(String query, List<SongExt> songs) {
  final queryText = _normalizeSearchText(query);
  if (queryText.isEmpty) return songs;

  final songNumber = int.tryParse(query.trim());
  final queryWords = queryText.split(' ');
  return songs.where((song) {
    if (songNumber != null && song.songNo == songNumber) return true;
    return _matchesAnyField(queryText, queryWords, [
      song.title,
      song.alias,
      song.content,
    ]);
  }).toList();
}

bool _matchesAnyField(
  String queryText,
  List<String> queryWords,
  List<String> fields,
) => fields.any((field) => _matchesField(queryText, queryWords, field));

bool _matchesField(String queryText, List<String> queryWords, String field) {
  final normalizedField = _normalizeSearchText(field);
  if (normalizedField.isEmpty) return false;
  if (normalizedField.contains(queryText)) return true;

  final availableWords = normalizedField.split(' ');
  final matchedIndexes = <int>{};
  for (final queryWord in queryWords) {
    var bestIndex = -1;
    var bestScore = 1000;
    for (var index = 0; index < availableWords.length; index++) {
      if (matchedIndexes.contains(index)) continue;
      final score = _wordMatchScore(queryWord, availableWords[index]);
      if (score != null && score < bestScore) {
        bestIndex = index;
        bestScore = score;
      }
    }
    if (bestIndex < 0) return false;
    matchedIndexes.add(bestIndex);
  }
  return true;
}

int? _wordMatchScore(String query, String candidate) {
  if (candidate == query) return 0;
  if (candidate.startsWith(query)) return 1;
  if (query.length >= 3 && candidate.contains(query)) return 2;

  final tolerance = _maxEditDistance(query.length);
  if (tolerance == 0 || (candidate.length - query.length).abs() > tolerance) {
    return null;
  }
  final distance = _editDistance(query, candidate, tolerance);
  return distance <= tolerance ? distance + 3 : null;
}

int _maxEditDistance(int wordLength) => switch (wordLength) {
  < 4 => 0,
  < 8 => 1,
  _ => 2,
};

int _editDistance(String first, String second, int limit) {
  var previous = List<int>.generate(second.length + 1, (index) => index);
  for (var row = 1; row <= first.length; row++) {
    final current = List<int>.filled(second.length + 1, 0);
    current[0] = row;
    var rowMinimum = row;
    for (var column = 1; column <= second.length; column++) {
      final insertion = current[column - 1] + 1;
      final deletion = previous[column] + 1;
      final substitution =
          previous[column - 1] +
          (first.codeUnitAt(row - 1) == second.codeUnitAt(column - 1) ? 0 : 1);
      var value = insertion < deletion ? insertion : deletion;
      if (substitution < value) value = substitution;
      current[column] = value;
      if (value < rowMinimum) rowMinimum = value;
    }
    if (rowMinimum > limit) return limit + 1;
    previous = current;
  }
  return previous.last;
}

String _normalizeSearchText(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[\s,.;:!?()\[\]{}<>/\\|_+=#\-–—]+'), ' ')
    .trim();
