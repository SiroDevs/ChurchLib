import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../features/bible_search/bible_search_screen.dart';
import '../../features/biblelib/bookmarks/bible_bookmarks_notes_screen.dart';
import '../../features/biblelib/history/bible_history_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/presentor/ui/presentor_screen.dart';
import '../../features/scripture/ui/scripture_list_detail_screen.dart';
import '../../features/scripture/ui/scripture_lists_screen.dart';
import '../../features/scripture/ui/scripture_opener_screen.dart';
import '../../features/selection/bible_selection/ui/bible_selection_screen.dart';
import '../../features/selection/seeding/seeding_screen.dart';
import '../../features/selection/step1/ui/step1_screen.dart';
import '../../features/selection/step2/ui/step2_screen.dart';
import '../../features/settings/bible_screen/ui/bibles_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
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
    path: '/${RouteNames.welcome}',
    name: RouteNames.welcome,
    builder: (_, __) => const WelcomeScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.step1}',
    name: RouteNames.step1,
    builder: (_, __) => const Step1Screen(),
  ),
  GoRoute(
    path: '/${RouteNames.step2}',
    name: RouteNames.step2,
    builder: (_, __) => const Step2Screen(),
  ),
  GoRoute(
    path: '/${RouteNames.biblelibSetup}',
    name: RouteNames.biblelibSetup,
    builder: (_, __) => const BibleSelectionScreen(),
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
    builder: (_, __) => const BibleBookmarksNotesScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.bibles}',
    name: RouteNames.bibles,
    builder: (_, __) => const BiblesScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.seeding}',
    name: RouteNames.seeding,
    builder: (_, __) => const SeedingScreen(),
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
