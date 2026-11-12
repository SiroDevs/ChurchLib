part of '../song_search_screen.dart';

extension SongSearchDataHandlers on SongSearchScreenState {
  SongSearchState get _songState => _bloc.state;

  List<SongBook> get books => _songState.books;

  List<SongExt> get songs => _songState.allSongs;

  List<SongExt> get filtered {
    final selectedSongs = _songState.selectedSongs;
    if (searchQuery.isEmpty) return selectedSongs;
    return filterSongsByQuery(searchQuery.toLowerCase(), selectedSongs);
  }

  int get selectedBook {
    final bookId = _songState.selectedBook?.bookId;
    final index = books.indexWhere((book) => book.bookId == bookId);
    return index < 0 ? 0 : index;
  }

  SongExt _emptySong() => SongExt(0, 0, 0, 0, '', '', '', 0, 0, false, '');

  void onSearch(String query) => setState(() => searchQuery = query);

  void _onSearchStateLoaded(SongSearchState state) {
    if (state.books.isEmpty) {
      selectedSong = _emptySong();
      return;
    }
    if (state.selectedBook == null) {
      _bloc.add(FilterData(state.books.first));
      return;
    }
    selectedSong = state.selectedSongs.isEmpty
        ? _emptySong()
        : state.selectedSongs.first;
  }

  Widget _emptyLibrary(BuildContext context, AppLocalizations l10n) => Scaffold(
    body: EmptyState(
      title: l10n.noSongbooksAvailable,
      titleRetry: l10n.selectSongsAfresh,
      showRetry: true,
      onRetry: () => context.read<SongSearchBloc>().add(const ResetData()),
    ),
  );
}
