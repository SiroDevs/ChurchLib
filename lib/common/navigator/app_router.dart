// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../core/license/license_cubit.dart';
import 'app_router_redirect.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

GoRouter buildAppRouter(LicenseCubit licenseCubit) {
  return GoRouter(
    initialLocation: '/${RouteNames.splash}',
    refreshListenable: GoRouterRefreshStream(licenseCubit.stream),
    redirect: (context, state) => appRouterRedirect(state, licenseCubit),
    routes: appRoutes,
  );
}
