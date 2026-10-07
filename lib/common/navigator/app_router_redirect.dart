import 'package:go_router/go_router.dart';

import '../../core/di/injectable.dart';
import '../../domain/repos/pref_repo.dart';
import '../utils/constants/pref_constants.dart';
import 'route_names.dart';

String? appRouterRedirect(GoRouterState state) {
  final loc = state.matchedLocation;
  const splash = '/${RouteNames.splash}';
  const selection = '/${RouteNames.selection}';
  if (loc == splash) return null;

  final prefs = getIt<PrefRepo>();

  final hasChosenModules = prefs.keyExists(
        PrefConstants.songlibModuleEnabledKey,
      ) ||
      prefs.keyExists(PrefConstants.biblelibModuleEnabledKey);
  final songlibEnabled = prefs.getPrefBool(
    PrefConstants.songlibModuleEnabledKey,
  );
  final biblelibEnabled = prefs.getPrefBool(
    PrefConstants.biblelibModuleEnabledKey,
  );
  final songlibLoaded = prefs.getPrefBool(PrefConstants.dataIsLoadedKey);
  final biblelibLoaded = prefs.getPrefBool(
    PrefConstants.biblelibDataLoadedKey,
  );

  final isLoaded = hasChosenModules &&
      (!songlibEnabled || songlibLoaded) &&
      (!biblelibEnabled || biblelibLoaded);

  if (isLoaded) {
    return loc == selection ? '/${RouteNames.main}' : null;
  }
  return loc == selection ? null : selection;
}
