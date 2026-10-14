part of 'bible_search_cubit.dart';

class BibleSearchState {
  final List<BibleVersion> bibles;
  final String selectedAbbr;
  final Map<String, String> bookNames;
  final List<VerseDisplay> results;
  final List<SearchEntry> history;
  final bool isSearching;
  final String query;

  const BibleSearchState({
    this.bibles = const [],
    this.selectedAbbr = '',
    this.bookNames = const {},
    this.results = const [],
    this.history = const [],
    this.isSearching = false,
    this.query = '',
  });

  BibleSearchState copyWith({
    List<BibleVersion>? bibles,
    String? selectedAbbr,
    Map<String, String>? bookNames,
    List<VerseDisplay>? results,
    List<SearchEntry>? history,
    bool? isSearching,
    String? query,
  }) {
    return BibleSearchState(
      bibles: bibles ?? this.bibles,
      selectedAbbr: selectedAbbr ?? this.selectedAbbr,
      bookNames: bookNames ?? this.bookNames,
      results: results ?? this.results,
      history: history ?? this.history,
      isSearching: isSearching ?? this.isSearching,
      query: query ?? this.query,
    );
  }
}
