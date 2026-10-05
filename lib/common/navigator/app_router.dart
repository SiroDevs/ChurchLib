import 'package:go_router/go_router.dart';

import '../../core/auth/auth_bloc.dart';
import 'app_router_redirect.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

/// The app's one [GoRouter]. [authBloc] drives [refreshListenable] so the
/// onboarding gate in [appRouterRedirect] re-evaluates whenever auth
/// status changes, same trigger the old imperative navigator used.
GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/${RouteNames.splash}',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => appRouterRedirect(state),
    routes: appRoutes,
  );
}
