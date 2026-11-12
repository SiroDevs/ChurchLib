// Dart imports:
// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/logging/app_logger.dart';
import '../../../../common/utils/network/network_utils.dart';
import '../../../../data/models/models.dart';
import '../../../../domain/repos/database_repo.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../../../domain/repos/song/song_sync_repo.dart';

part 'song_search_event.dart';
part 'song_search_state.dart';

class SongSearchBloc extends Bloc<SongSearchEvent, SongSearchState> {
  SongSearchBloc({
    required SongSyncRepo syncRepo,
    required PrefRepo prefRepo,
    required DatabaseRepo databaseRepo,
  }) : _syncRepo = syncRepo,
       _prefRepo = prefRepo,
       _dbRepo = databaseRepo,
       super(const SongSearchState()) {
    on<SyncData>(_onSyncData);
    on<FetchData>(_onFetchData);
    on<FilterData>(_onFilterData);
    on<ResetData>(_onResetData);
  }

  final SongSyncRepo _syncRepo;
  final PrefRepo _prefRepo;
  final DatabaseRepo _dbRepo;
  int _filterRequestId = 0;
  int _dataRequestId = 0;

  Future<void> _onSyncData(
    SyncData event,
    Emitter<SongSearchState> emit,
  ) async {
    final requestId = ++_dataRequestId;
    _filterRequestId++;
    if (await NetworkUtil.hasNetworkConnectionNow()) {
      if (requestId != _dataRequestId || emit.isDone) return;
      try {
        await _syncRepo.syncData();
        if (requestId != _dataRequestId || emit.isDone) return;
        final books = await _dbRepo.fetchBooks();
        if (requestId != _dataRequestId || emit.isDone) return;
        final songs = await _dbRepo.fetchSongs();
        if (requestId != _dataRequestId || emit.isDone) return;
        final likes = await _dbRepo.fetchLikes();
        if (requestId != _dataRequestId || emit.isDone) return;
        final selectedBook = _resolveSelectedBook(books);
        emit(
          state.copyWith(
            status: SongSearchStatus.loaded,
            books: books,
            allSongs: songs,
            selectedBook: selectedBook,
            selectedSongs: _songsForBook(songs, selectedBook),
            likes: likes,
          ),
        );
      } catch (e, stackTrace) {
        if (requestId != _dataRequestId || emit.isDone) return;
        logger("Error log: $e\n$stackTrace");
        emit(state.copyWith(status: SongSearchStatus.loaded));
      }
    } else {
      if (requestId != _dataRequestId || emit.isDone) return;
      emit(state.copyWith(status: SongSearchStatus.noInternet));
    }
  }

  Future<void> _onFetchData(
    FetchData event,
    Emitter<SongSearchState> emit,
  ) async {
    final requestId = ++_dataRequestId;
    _filterRequestId++;
    emit(state.copyWith(status: SongSearchStatus.loading, feedback: null));
    try {
      final books = await _dbRepo.fetchBooks();
      if (requestId != _dataRequestId || emit.isDone) return;
      final songs = await _dbRepo.fetchSongs();
      if (requestId != _dataRequestId || emit.isDone) return;
      emit(
        state.copyWith(
          status: SongSearchStatus.loaded,
          books: books,
          allSongs: songs,
          selectedSongs: const [],
          likes: const [],
          selectedBook: null,
        ),
      );
    } catch (e) {
      if (requestId != _dataRequestId || emit.isDone) return;
      logger('Unable to: $e');
      emit(
        state.copyWith(
          status: SongSearchStatus.failure,
          feedback: 'Unable to fetch songs',
        ),
      );
    }
  }

  Future<void> _onFilterData(
    FilterData event,
    Emitter<SongSearchState> emit,
  ) async {
    final requestId = ++_filterRequestId;
    emit(state.copyWith(status: SongSearchStatus.filtering));
    try {
      final bookId = event.book.bookId;
      if (bookId == null) {
        if (requestId == _filterRequestId && !emit.isDone) {
          emit(
            state.copyWith(
              status: SongSearchStatus.loaded,
              selectedBook: event.book,
              selectedSongs: const [],
              feedback: null,
            ),
          );
        }
        return;
      }
      final songs = await _dbRepo.fetchSongs(bid: bookId);
      if (requestId != _filterRequestId || emit.isDone) return;
      final likes = await _dbRepo.fetchLikes();
      if (requestId != _filterRequestId || emit.isDone) return;
      emit(
        state.copyWith(
          status: SongSearchStatus.loaded,
          selectedBook: event.book,
          selectedSongs: songs,
          likes: likes,
          feedback: null,
        ),
      );
    } catch (e) {
      logger('Unable to: $e');
      if (requestId == _filterRequestId && !emit.isDone) {
        emit(
          state.copyWith(
            status: SongSearchStatus.failure,
            feedback: 'Unable to display songs',
          ),
        );
      }
    }
  }

  Future<void> _onResetData(
    ResetData event,
    Emitter<SongSearchState> emit,
  ) async {
    final requestId = ++_dataRequestId;
    _filterRequestId++;
    emit(state.copyWith(status: SongSearchStatus.loading));
    try {
      await _dbRepo.removeAllBooks();
      if (requestId != _dataRequestId || emit.isDone) return;
      await _dbRepo.removeAllSongs();
      if (requestId != _dataRequestId || emit.isDone) return;
      _prefRepo.clearData();
      emit(const SongSearchState(status: SongSearchStatus.reset));
    } catch (e) {
      if (requestId != _dataRequestId || emit.isDone) return;
      logger('Unable to: $e');
      emit(state.copyWith(status: SongSearchStatus.loaded));
    }
  }

  SongBook? _resolveSelectedBook(List<SongBook> books) {
    final selectedId = state.selectedBook?.bookId;
    for (final book in books) {
      if (book.bookId == selectedId) return book;
    }
    return books.isEmpty ? null : books.first;
  }

  List<SongExt> _songsForBook(List<SongExt> songs, SongBook? book) {
    final bookId = book?.bookId;
    if (bookId == null) return const [];
    return songs.where((song) => song.book == bookId).toList();
  }
}
