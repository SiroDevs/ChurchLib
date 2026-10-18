// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../data/models/song/songbook.dart';
import '../../data/models/song/songext.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/license/ui/screens/paywall_screen.dart';
import '../../features/onboarding/selection/bloc/selection_bloc.dart';
import '../../features/onboarding/selection/ui/selection_screen.dart';
import '../../features/onboarding/splash/ui/splash_screen.dart';
import '../../features/song/presentor/ui/presentor_screen.dart';
import 'route_names.dart';

typedef PresentorArgs = ({SongExt song, SongBook book, List<SongExt> songs});

final List<RouteBase> appRoutes = [
  GoRoute(
    path: '/${RouteNames.splash}',
    name: RouteNames.splash,
    builder: (_, _) => const SplashScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.selection}',
    name: RouteNames.selection,
    builder: (_, _) => const SelectionScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.biblelibSetup}',
    name: RouteNames.biblelibSetup,
    builder: (_, _) => const SelectionScreen(only: SelectionStepType.bibles),
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
    builder: (_, _) => const PaywallScreen(),
  ),
  GoRoute(
    path: '/${RouteNames.presentor}',
    name: RouteNames.presentor,
    builder: (_, state) {
      final args = state.extra as PresentorArgs;
      return PresentorScreen(
        song: args.song,
        book: args.book,
        songs: args.songs,
      );
    },
  ),
];
