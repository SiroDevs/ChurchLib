part of 'song_search_bloc.dart';

sealed class SongSearchEvent {
  const SongSearchEvent();
}

class FetchData extends SongSearchEvent {
  const FetchData();
}

class SyncData extends SongSearchEvent {
  const SyncData();
}

class FilterData extends SongSearchEvent {
  const FilterData(this.book);
  final SongBook book;
}

class ResetData extends SongSearchEvent {
  const ResetData();
}
