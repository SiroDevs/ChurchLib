import 'package:go_router/go_router.dart';

import '../../core/di/injectable.dart';
import '../../domain/repos/pref_repo.dart';
import '../utils/constants/pref_constants.dart';
import 'route_names.dart';

/// Gate the whole app behind "is setup finished?".
///
/// * `/splash` is never redirected — it shows itself for a moment and then
///   navigates to `/main`, which lands here and is routed on.
/// * Until every module the user picked has its data loaded, everything
///   goes to the single Selection flow (module pick → songbooks → Bibles;
///   the screen works out which steps are still needed from the prefs).
/// * Once loaded, the Selection screen bounces to Home and every other
///   route (settings, search, ...) is left untouched.
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
