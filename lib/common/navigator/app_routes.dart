import 'package:go_router/go_router.dart';

import '../../features/home/main/ui/home_screen.dart';
import '../../features/selection/bloc/selection_bloc.dart';
import '../../features/selection/ui/selection_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'route_names.dart';

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
];
