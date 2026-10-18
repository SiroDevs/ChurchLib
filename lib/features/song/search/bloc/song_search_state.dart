part of 'song_search_bloc.dart';

sealed class SongSearchState extends Equatable {
  const SongSearchState();

  @override
  List<Object?> get props => [];
}

class _MainState extends SongSearchState {
  const _MainState();
}

class LoadedState extends SongSearchState {
  const LoadedState();
}

class DataFetchedState extends SongSearchState {
  const DataFetchedState(this.books, this.songs);
  final List<SongBook> books;
  final List<SongExt> songs;

  @override
  List<Object?> get props => [books, songs];
}

class DataSyncedState extends SongSearchState {
  const DataSyncedState(this.books, this.songs);
  final List<SongBook> books;
  final List<SongExt> songs;

  @override
  List<Object?> get props => [books, songs];
}

class FilteredState extends SongSearchState {
  const FilteredState(this.book, this.songs, this.likes);
  final SongBook book;
  final List<SongExt> songs;
  final List<SongExt> likes;

  @override
  List<Object?> get props => [book, songs, likes];
}

class FetchingState extends SongSearchState {
  const FetchingState();
}

class FilteringState extends SongSearchState {
  const FilteringState();
}

class SuccessState extends SongSearchState {
  const SuccessState();
}

class ResettedState extends SongSearchState {
  const ResettedState();
}

class FailureState extends SongSearchState {
  const FailureState(this.feedback);
  final String feedback;

  @override
  List<Object?> get props => [feedback];
}

class NoInternetState extends SongSearchState {
  const NoInternetState();
}
