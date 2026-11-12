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
  late SongSearchBloc _bloc;
  bool _presenting = false;
  String searchQuery = '';
  late SongExt selectedSong;

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
    final book = books.firstWhere(
      (b) => b.bookId == song.book,
      orElse: () => books[0],
    );

    _presenting = true;
    try {
      await context.pushNamed<bool>(
        RouteNames.presentor,
        extra: (song: song, book: book, songs: songs),
      );
    } finally {
      _presenting = false;
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
          _bloc = context.read<SongSearchBloc>();
          if (state.status == SongSearchStatus.loaded) {
            _onSearchStateLoaded(state);
          } else if (state.status == SongSearchStatus.failure) {
            CustomSnackbar.show(
              context,
              feedbackMessage(state.feedback ?? '', l10n),
            );
          } else if (state.status == SongSearchStatus.reset) {
            CustomSnackbar.show(context, l10n.redirectingYou);
            context.goNamed(RouteNames.selection);
          }
        },
        builder: (context, state) {
          if (state.status == SongSearchStatus.loaded && state.books.isEmpty) {
            return _emptyLibrary(context, l10n);
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
                    const LikesScreen(),
                  ],
                ).expanded(),
              ],
            ),
          );
          if (state.status == SongSearchStatus.failure) {
            return Scaffold(
              body: EmptyState(
                title: l10n.problemDisplaySongs,
                showRetry: true,
                titleRetry: l10n.selectSongsAfresh,
                onRetry: () =>
                    context.read<SongSearchBloc>().add(const ResetData()),
              ),
            );
          }
          if (state.status == SongSearchStatus.initial ||
              state.status == SongSearchStatus.loading ||
              (state.status == SongSearchStatus.filtering &&
                  state.selectedBook == null) ||
              (state.status == SongSearchStatus.loaded &&
                  state.books.isNotEmpty &&
                  state.selectedBook == null)) {
            return const Scaffold(body: SongSearchLoading());
          }
          return homeView;
        },
      ),
    );
  }
}
