part of 'bible_history_cubit.dart';

class HistoryGroup {
  final String dateLabel;
  final List<HistoryEntry> entries;
  HistoryGroup(this.dateLabel, this.entries);
}

class BibleHistoryState {
  final bool isLoading;
  final List<HistoryGroup> reading;
  final List<SearchEntry> searches;

  const BibleHistoryState({
    this.isLoading = true,
    this.reading = const [],
    this.searches = const [],
  });

  BibleHistoryState copyWith({
    bool? isLoading,
    List<HistoryGroup>? reading,
    List<SearchEntry>? searches,
  }) {
    return BibleHistoryState(
      isLoading: isLoading ?? this.isLoading,
      reading: reading ?? this.reading,
      searches: searches ?? this.searches,
    );
  }
}
