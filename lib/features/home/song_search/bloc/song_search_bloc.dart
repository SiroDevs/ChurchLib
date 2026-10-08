import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/network_utils.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/models.dart';
import '../../../../domain/repos/database_repo.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../../../domain/repos/song/song_sync_repo.dart';

part 'song_search_event.dart';
part 'song_search_state.dart';

class SongSearchBloc extends Bloc<SongSearchEvent, SongSearchState> {
  SongSearchBloc() : super(const _MainState()) {
    on<SyncData>(_onSyncData);
    on<FetchData>(_onFetchData);
    on<FilterData>(_onFilterData);
    on<ResetData>(_onResetData);
  }

  final _syncRepo = SongSyncRepo();
  final _prefRepo = getIt<PrefRepo>();
  final _dbRepo = getIt<DatabaseRepo>();

  Future<void> _onSyncData(SyncData event, Emitter<SongSearchState> emit) async {
    if (await NetworkUtil.hasInternetConnection()) {
      try {
        await _syncRepo.syncData();
        var books = await _dbRepo.fetchBooks();
        var songs = await _dbRepo.fetchSongs();
        emit(DataSyncedState(books, songs));
      } catch (e, stackTrace) {
        logger("Error log: $e\n$stackTrace");
        emit(LoadedState());
      }
    } else {
      emit(const NoInternetState());
    }
  }

  Future<void> _onFetchData(FetchData event, Emitter<SongSearchState> emit) async {
    emit(FetchingState());
    try {
      var books = await _dbRepo.fetchBooks();
      var songs = await _dbRepo.fetchSongs();
      emit(DataFetchedState(books, songs));
    } catch (e) {
      logger('Unable to: $e');
      emit(FailureState('Unable to fetch songs'));
    }
  }

  Future<void> _onFilterData(FilterData event, Emitter<SongSearchState> emit) async {
    emit(FilteringState());
    try {
      var songs = await _dbRepo.fetchSongs(bid: event.book.bookId!);
      var likes = await _dbRepo.fetchLikes();
      emit(FilteredState(event.book, songs, likes));
    } catch (e) {
      logger('Unable to: $e');
      emit(LoadedState());
    }
  }

  Future<void> _onResetData(ResetData event, Emitter<SongSearchState> emit) async {
    emit(FetchingState());
    try {
      await _dbRepo.removeAllBooks();
      await _dbRepo.removeAllSongs();
      _prefRepo.clearData();
      emit(ResettedState());
    } catch (e) {
      logger('Unable to: $e');
      emit(LoadedState());
    }
  }
}
