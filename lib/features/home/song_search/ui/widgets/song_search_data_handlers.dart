part of '../song_search_screen.dart';

extension SongSearchDataHandlers on SongSearchScreenState {
  SongExt _emptySong() => SongExt(0, 0, 0, 0, '', '', '', 0, 0, false, '');

  void _onBooksLoaded(List<SongBook> loadedBooks, List<SongExt> loadedSongs) {
    books = loadedBooks;
    songs = loadedSongs;
    if (books.isEmpty) {
      selectedBook = 0;
      filtered = [];
      selectedSong = _emptySong();
      dataReady = true;
      return;
    }

    selectedBook = selectedBook.clamp(0, books.length - 1).toInt();
    _bloc.add(FilterData(books[selectedBook]));
  }

  Widget _emptyLibrary(AppLocalizations l10n) => Scaffold(
    body: EmptyState(
      title: l10n.noSongbooksAvailable,
      titleRetry: l10n.selectSongsAfresh,
      showRetry: true,
      onRetry: () => context.read<SongSearchBloc>().add(const ResetData()),
    ),
  );
}
