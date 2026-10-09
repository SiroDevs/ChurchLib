// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../common/navigator/route_names.dart';
import '../../../../common/utils/app_util.dart';
import '../../../../common/windows/open_windows.dart';
import '../../../../data/models/models.dart';
import '../../../../data/sources/remote/song/api_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../common/widgets/state/general_progress.dart';
import '../../../../common/widgets/state/skeleton.dart';
import '../../../../common/widgets/search/search_songs_utils.dart';
import '../../../song/songs/songs_screen.dart';
import '../../../song/likes/likes_screen.dart';
import '../../main/shell/app_module.dart';
import '../../main/shell/app_shell.dart';
import '../../main/shell/shell_nav_item.dart';
import '../bloc/song_search_bloc.dart';

part 'widgets/search_widget.dart';
part 'widgets/song_title_bar.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({super.key});

  @override
  State<SongSearchScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<SongSearchScreen> {
  late SongSearchBloc _bloc;
  Timer? _syncTimer;

  bool periodicSyncStarted = false;
  int selectedPage = 0, selectedBook = 0;
  List<SongBook> books = [];
  late SongExt selectedSong;
  List<SongExt> songs = [], likes = [], filtered = [];
  PageController pageController = PageController();

  PageType currentPage = PageType.search;

  final FocusNode searchFocus = FocusNode();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedSong = SongExt(0, 0, 0, 0, '', '', '', 0, 0, false, '');
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    searchFocus.dispose();
    searchController.dispose();
    super.dispose();
  }

  void selectSong(SongExt song) => setState(() => selectedSong = song);

  void onSearch(String query) {
    setState(() {
      filtered = query.isEmpty
          ? songs
          : filterSongsByQuery(query.toLowerCase(), songs);
    });
  }

  Future<void> presentSelected(BuildContext context) async {
    final song = selectedSong;
    if (song.songId == 0 || books.isEmpty) return;
    final bloc = context.read<SongSearchBloc>();
    final book = books.firstWhere(
      (b) => b.bookId == song.book,
      orElse: () => books[0],
    );
    final changed = await openPresentor(
      context,
      song: song,
      book: book,
      songs: songs,
    );
    if (changed == true) bloc.add(FilterData(book));
  }

  void startPeriodicSync() {
    periodicSyncStarted = true;
    _syncTimer = Timer.periodic(Duration(minutes: 5), (_) async {
      if (await isConnectedToInternet()) _bloc.add(SyncData());
    });
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => SongSearchBloc()..add(FetchData()),
      child: BlocConsumer<SongSearchBloc, SongSearchState>(
        listener: (context, state) {
          _bloc = context.read<SongSearchBloc>();
          if (state is DataSyncedState) {
            books = state.books;
            songs = state.songs;
            _bloc.add(FilterData(books[selectedBook]));
          } else if (state is DataFetchedState) {
            books = state.books;
            songs = state.songs;
            _bloc.add(FilterData(books[selectedBook]));
          } else if (state is FilteredState) {
            likes = state.likes;
            filtered = state.songs;
            selectedBook = books.indexOf(state.book);
            selectedSong = state.songs[0];
          } else if (state is FailureState) {
            CustomSnackbar.show(context, feedbackMessage(state.feedback, l10n));
          } else if (state is ResettedState) {
            CustomSnackbar.show(context, l10n.redirectingYou);
            context.goNamed(RouteNames.selection);
          }
        },
        builder: (context, state) {
          final onSearchPage = currentPage == PageType.search;
          final homeView = AppShell(
            module: AppModule.songlib,
            sidebarItems: [
              ShellNavItem(
                Icons.search,
                l10n.searchTitle,
                isSelected: onSearchPage,
                onPressed: () => setState(() => currentPage = PageType.search),
              ),
              ShellNavItem(
                Icons.favorite,
                l10n.likesTitle,
                isSelected: currentPage == PageType.likes,
                onPressed: () => setState(() => currentPage = PageType.likes),
              ),
            ],
            titleBar: SongTitleBar(parent: this),
            body: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: pages.indexOf(currentPage),
                    children: <Widget>[
                      SongsScreen(parent: this),
                      LikesScreen(books: books),
                    ],
                  ),
                ),
              ],
            ),
          );
          return switch (state) {
            FailureState() => Scaffold(
              body: EmptyState(
                title: l10n.problemDisplaySongs,
                showRetry: true,
                titleRetry: l10n.selectSongsAfresh,
                onRetry: () => context.read<SongSearchBloc>().add(const ResetData()),
              ),
            ),
            FetchingState() => Scaffold(body: HomeLoading()),
            _ => homeView,
          };
        },
      ),
    );
  }
}
