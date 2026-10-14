part of 'selection_bloc.dart';

mixin SongSelectionHandlers on Bloc<SelectionEvent, SelectionState> {
  PrefRepo get _prefRepo;
  DatabaseRepo get _dbRepo;
  SongSelectionRepo get _songRepo;
  bool get _booksPersisted;
  set _booksPersisted(bool value);
  Future<void> _next(Emitter<SelectionState> emit);

  Set<int> _savedBookIds() => _prefRepo
      .getPrefString(PrefConstants.selectedBooksKey)
      .split(',')
      .map((e) => int.tryParse(e.trim()))
      .whereType<int>()
      .toSet();

  Future<void> _onBooksRequested(
    BooksRequested event,
    Emitter<SelectionState> emit,
  ) async {
    emit(state.copyWith(booksStatus: LoadStatus.loading));
    if (!await NetworkUtil.hasInternetConnection()) {
      emit(state.copyWith(booksStatus: LoadStatus.noInternet));
      return;
    }
    try {
      final books = await _songRepo.fetchBooks();

      final saved = state.selectedBookIds.isNotEmpty
          ? state.selectedBookIds
          : _savedBookIds();
      emit(
        state.copyWith(
          booksStatus: LoadStatus.loaded,
          books: books,
          selectedBookIds: {
            for (final b in books)
              if (b.bookId != null && saved.contains(b.bookId)) b.bookId!,
          }.take(maxSongbookSelections).toSet(),
        ),
      );
    } on SongApiException catch (e) {
      logger('Books request failed: $e');
      emit(
        state.copyWith(
          booksStatus: LoadStatus.failure,
          booksError: e.statusCode.toString(),
        ),
      );
    } catch (e) {
      logger('Error log: $e');
      emit(state.copyWith(booksStatus: LoadStatus.failure, booksError: '100'));
    }
  }

  void _onBookToggled(BookToggled event, Emitter<SelectionState> emit) {
    final selected = {...state.selectedBookIds};
    if (!selected.remove(event.bookId)) {
      if (selected.length >= maxSongbookSelections) return;
      selected.add(event.bookId);
    }
    emit(state.copyWith(selectedBookIds: selected));
  }

  Future<void> _onBooksConfirmed(
    BooksConfirmed event,
    Emitter<SelectionState> emit,
  ) async {
    if (state.selectedBookIds.isEmpty) return;
    await _next(emit);
  }

  Future<void> _persistBooks() async {
    final selected = state.selectedBooks;
    final newIds = {for (final b in selected) b.bookId!};

    for (final existing in await _dbRepo.fetchBooks()) {
      final id = existing.bookId;
      if (id != null && !newIds.contains(id)) {
        await _dbRepo.removeSongsByBook(id);
        await _dbRepo.removeBookByBookId(id);
      }
    }
    for (final book in selected) {
      await _dbRepo.removeBookByBookId(book.bookId!);
      await _dbRepo.saveBook(book);
    }

    _prefRepo.setPrefString(PrefConstants.selectedBooksKey, newIds.join(','));
    _prefRepo.setPrefBool(PrefConstants.dataIsSelectedKey, true);
    _prefRepo.setPrefBool(PrefConstants.dataIsLoadedKey, false);
    _prefRepo.setPrefBool(PrefConstants.slideVerticalKey, true);
  }

  Future<bool> _saveSongs(Emitter<SelectionState> emit) async {
    emit(state.copyWith(songsPhase: SongsPhase.fetching, songsProgress: 0));
    if (!await NetworkUtil.hasInternetConnection()) {
      emit(state.copyWith(songsPhase: SongsPhase.noInternet));
      return false;
    }

    if (!_booksPersisted) {
      try {
        await _persistBooks();
        _booksPersisted = true;
      } catch (e) {
        logger('Unable to save books: $e');
        emit(state.copyWith(songsPhase: SongsPhase.failed, songsError: '100'));
        return false;
      }
    }

    final selectedBooks = _prefRepo.getPrefString(
      PrefConstants.selectedBooksKey,
    );
    final List<Song> songs;
    try {
      songs = await _songRepo.fetchSongsByBooks(selectedBooks);
    } on SongApiException catch (e) {
      logger('Songs request failed: $e');
      emit(
        state.copyWith(
          songsPhase: SongsPhase.failed,
          songsError: e.statusCode.toString(),
        ),
      );
      return false;
    } catch (e) {
      logger('Error log: $e');
      emit(state.copyWith(songsPhase: SongsPhase.failed, songsError: '100'));
      return false;
    }

    if (songs.isNotEmpty) {
      for (final id in _savedBookIds()) {
        await _dbRepo.removeSongsByBook(id);
      }

      var index = 0;
      for (final song in songs) {
        try {
          final progress = ((index / songs.length) * 100).toInt();
          emit(
            state.copyWith(
              songsPhase: SongsPhase.saving,
              songsProgress: progress,
              songsFeedback: _songsFeedback(progress),
            ),
          );
          await _dbRepo.saveSong(song);
          index++;
        } catch (e) {
          logger('Unable to save song ${song.songId}: $e');
        }
      }
      _prefRepo.setPrefBool(PrefConstants.dataIsLoadedKey, true);
      _prefRepo.setPrefBool(PrefConstants.wakeLockCheckKey, true);
    }

    emit(state.copyWith(songsPhase: SongsPhase.done));
    return true;
  }

  String _songsFeedback(int progress) => switch (progress) {
        1 => 'On your\nmarks ...',
        5 => 'Set. \nReady ...',
        10 => 'Loading\nsongs ...',
        20 => 'Patience\npays ...',
        40 => 'Loading\nsongs ...',
        75 => 'Thanks for\nyour patience!',
        85 => 'Finishing up',
        95 => "We're almost done",
        _ => state.songsFeedback,
      };
}
