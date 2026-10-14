import 'package:go_router/go_router.dart';

import '../../data/models/song/songbook.dart';
import '../../data/models/song/songext.dart';
import '../../features/home/main/ui/home_screen.dart';
import '../../features/license/ui/paywall_screen.dart';
import '../../features/selection/bloc/selection_bloc.dart';
import '../../features/selection/ui/selection_screen.dart';
import '../../features/song/presentor/ui/presentor_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'route_names.dart';

/// Extra payload for the [RouteNames.presentor] route — a record instead
/// of a one-off args class, since it's only ever read in one builder.
typedef PresentorArgs = ({SongExt song, SongBook book, List<SongExt> songs});

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
    path: '/${RouteNames.main}',
    name: RouteNames.main,
    pageBuilder: (_, state) =>
        NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
  ),
  GoRoute(
    path: '/${RouteNames.license}',
    name: RouteNames.license,
    builder: (_, __) => const PaywallScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.presentor}',
    name: RouteNames.presentor,
    builder: (_, state) {
      final args = state.extra as PresentorArgs;
      return PresentorScreen(song: args.song, book: args.book, songs: args.songs);
    },
  ),
];
