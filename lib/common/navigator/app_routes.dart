import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../features/bible/search/ui/bible_search_screen.dart';
import '../../features/bible/bookmarks/ui/bookmarks_notes_screen.dart';
import '../../features/bible/history/ui/bible_history_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/song/presentor/ui/presentor_screen.dart';
import '../../features/bible/scripture/scripture_list_detail/ui/scripture_list_detail_screen.dart';
import '../../features/bible/scripture/scripture_list/ui/scripture_lists_screen.dart';
import '../../features/bible/scripture/scripture_opener/ui/scripture_opener_screen.dart';
import '../../features/selection/bloc/selection_bloc.dart';
import '../../features/selection/ui/selection_screen.dart';
import '../../features/settings/bible_screen/ui/bibles_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'route_names.dart';

/// Extra payload for the [RouteNames.presentor] route — a record instead
/// of a one-off args class, since it's only ever read in one builder.
typedef PresentorArgs = ({SongExt song, SongBook book, List<SongExt> songs});

/// Extra payload for [RouteNames.biblelibSetup] opened as the Scripture
/// Opener's host Bible.
typedef ScriptureOpenerArgs = ({String bibleAbbr, String bibleName});

final List<RouteBase> appRoutes = [
  GoRoute(
    path: '/${RouteNames.splash}',
    name: RouteNames.splash,
    builder: (_, __) => const SplashScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.selection}',
    name: RouteNames.selection,
    builder: (_, __) => const SelectionScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.biblelibSetup}',
    name: RouteNames.biblelibSetup,
    builder: (_, __) => const SelectionScreen(only: SelectionStepType.bibles),
  ),
  GoRoute(
    path: '/${RouteNames.bibleSearch}',
    name: RouteNames.bibleSearch,
    builder: (_, __) => const BibleSearchScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.bibleHistory}',
    name: RouteNames.bibleHistory,
    builder: (_, __) => const BibleHistoryScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.bibleBookmarksNotes}',
    name: RouteNames.bibleBookmarksNotes,
    builder: (_, __) => const BookmarksNotesScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.bibles}',
    name: RouteNames.bibles,
    builder: (_, __) => const BiblesScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.main}',
    name: RouteNames.main,
    builder: (_, __) => const HomeScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.settings}',
    name: RouteNames.settings,
    builder: (_, __) => const SettingsScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.presentor}',
    name: RouteNames.presentor,
    builder: (_, state) {
      final args = state.extra as PresentorArgs;
      return PresentorScreen(song: args.song, book: args.book, songs: args.songs);
    },
  ),
  GoRoute(
    path: '/${RouteNames.scriptureLists}',
    name: RouteNames.scriptureLists,
    builder: (_, __) => const ScriptureListsScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.scriptureListDetail}/:listId',
    name: RouteNames.scriptureListDetail,
    builder: (_, state) => ScriptureListDetailScreen(
      listId: int.parse(state.pathParameters['listId']!),
    ),
  ),
  GoRoute(
    path: '/${RouteNames.scriptureOpener}',
    name: RouteNames.scriptureOpener,
    builder: (_, state) {
      final args = state.extra as ScriptureOpenerArgs;
      return ScriptureOpenerScreen(
        bibleAbbr: args.bibleAbbr,
        bibleName: args.bibleName,
      );
    },
  ),
];
