// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../core/di/injectable.dart';
import '../../core/license/license_cubit.dart';
import '../../domain/repos/pref_repo.dart';
import '../constants/pref_constants.dart';
import 'route_names.dart';

String? appRouterRedirect(GoRouterState state, LicenseCubit license) {
  final loc = state.matchedLocation;
  const splash = '/${RouteNames.splash}';
  const selection = '/${RouteNames.selection}';
  if (loc == splash) return null;

  // License gate: the app itself (and the presenter) need a trial or license.
  // The setup screens stay reachable so first-time setup can finish.
  const licenseScreen = '/${RouteNames.license}';
  final gateOpen = license.isGateOpen;
  if (loc == licenseScreen) return gateOpen ? '/${RouteNames.main}' : null;
  if (!gateOpen &&
      (loc == '/${RouteNames.main}' || loc == '/${RouteNames.presentor}')) {
    return licenseScreen;
  }

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
