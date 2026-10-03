part of 'song_search_bloc.dart';

@freezed
sealed class SongSearchEvent with _$SongSearchEvent {
  const factory SongSearchEvent.fetch() = FetchData;

  const factory SongSearchEvent.sync() = SyncData;

  const factory SongSearchEvent.filter(Book book) = FilterData;
  
  const factory SongSearchEvent.reset() = ResetData;
  
}
