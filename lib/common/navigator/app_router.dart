import 'package:go_router/go_router.dart';

import '../../core/auth/auth_bloc.dart';
import 'app_router_redirect.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/${RouteNames.splash}',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => appRouterRedirect(state),
    routes: appRoutes,
  );
}
