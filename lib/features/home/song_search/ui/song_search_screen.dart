// Dart imports:
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/navigator/route_names.dart';
import '../../../../common/utils/display/app_window.dart';
import '../../../../common/utils/formatting/app_util.dart';
import '../../../../common/widgets/search/search_songs_utils.dart';
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../common/widgets/state/general_progress.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/models.dart';
import '../../../../domain/repos/database_repo.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../../../domain/repos/song/song_sync_repo.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../song/likes/likes_screen.dart';
import '../../../song/songs/songs_screen.dart';
import '../../../presentation/controller/presentation_controller.dart';
import '../../../presentation/controller/presentation_sources.dart';
import '../../../presentation/ui/presentation_toggle.dart';
import '../../main/shell/app_module.dart';
import '../../main/shell/app_shell.dart';
import '../../main/shell/shell_nav_item.dart';
import '../bloc/song_search_bloc.dart';
import 'widgets/song_search_loading.dart';

part 'widgets/search_widget.dart';
part 'widgets/song_search_data_handlers.dart';
part 'widgets/song_search_fullscreen_handlers.dart';
part 'widgets/song_title_bar.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({super.key});

  @override
  State<SongSearchScreen> createState() => SongSearchScreenState();
}

class SongSearchScreenState extends State<SongSearchScreen> {
  bool dataReady = false;

  bool _presenting = false;
  int selectedBook = 0;
  List<SongBook> books = [];
  late SongExt selectedSong;
  List<SongExt> songs = [], filtered = [];

  PageType currentPage = PageType.search;

  final FocusNode searchFocus = FocusNode();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedSong = _emptySong();
    AppWindow.fullScreen.addListener(_onFullScreenChanged);
  }

  @override
  void dispose() {
    AppWindow.fullScreen.removeListener(_onFullScreenChanged);
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

  Future<void> presentSelected() async {
    if (selectedSong.songId == 0) return;
    if (!PresentationController.instance.hasExtendedDisplay) {
      PresentationController.instance.stop();
      await openFullScreenPresenter();
      return;
    }
    await presentSong(selectedSong);
  }

  Future<void> openFullScreenPresenter() async {
    final song = selectedSong;
    if (song.songId == 0 || books.isEmpty) return;
    // final bloc = context.read<SongSearchBloc>();
    final book = books.firstWhere(
      (b) => b.bookId == song.book,
      orElse: () => books[0],
    );

    _presenting = true;
    bool? result = await context.pushNamed<bool>(
      RouteNames.presentor,
      extra: (song: song, book: book, songs: songs),
    );

    _presenting = false;
    if (result == true) {
      // bloc.add(FilterData(book));
    }
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => SongSearchBloc(
        syncRepo: getIt<SongSyncRepo>(),
        prefRepo: getIt<PrefRepo>(),
        databaseRepo: getIt<DatabaseRepo>(),
      )..add(const FetchData()),
      child: BlocConsumer<SongSearchBloc, SongSearchState>(
        listener: (context, state) {
          if (state is DataSyncedState) {
            _onBooksLoaded(state.books, state.songs);
          } else if (state is DataFetchedState) {
            _onBooksLoaded(state.books, state.songs);
          } else if (state is FilteredState) {
            filtered = state.songs;
            selectedBook = books.indexWhere(
              (book) => book.bookId == state.book.bookId,
            );
            if (selectedBook < 0) selectedBook = 0;
            selectedSong = state.songs.isEmpty
                ? _emptySong()
                : state.songs.first;
            dataReady = true;
          } else if (state is LoadedState) {
            dataReady = true;
          } else if (state is FailureState) {
            CustomSnackbar.show(context, feedbackMessage(state.feedback, l10n));
          } else if (state is ResettedState) {
            CustomSnackbar.show(context, l10n.redirectingYou);
            context.goNamed(RouteNames.selection);
          }
        },
        builder: (context, state) {
          if (dataReady && books.isEmpty) {
            return _emptyLibrary(l10n);
          }
          final onSearchPage = currentPage == PageType.search;
          final homeView = AppShell(
            module: AppModule.songlib,
            onPresent: presentSelected,
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
                IndexedStack(
                  index: pages.indexOf(currentPage),
                  children: <Widget>[
                    SongsScreen(parent: this),
                    LikesScreen(books: books),
                  ],
                ).expanded(),
              ],
            ),
          );
          return switch (state) {
            FailureState() => Scaffold(
              body: EmptyState(
                title: l10n.problemDisplaySongs,
                showRetry: true,
                titleRetry: l10n.selectSongsAfresh,
                onRetry: () =>
                    context.read<SongSearchBloc>().add(const ResetData()),
              ),
            ),
            FetchingState() ||
            InitialState() => const Scaffold(body: SongSearchLoading()),
            _ when !dataReady => const Scaffold(body: SongSearchLoading()),
            _ => homeView,
          };
        },
      ),
    );
  }
}
