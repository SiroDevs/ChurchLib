import 'package:go_router/go_router.dart';

import '../../core/di/injectable.dart';
import '../../domain/repos/pref_repo.dart';
import '../utils/constants/pref_constants.dart';
import 'route_names.dart';

const _onboardingPaths = {
  '/${RouteNames.splash}',
  '/${RouteNames.welcome}',
  '/${RouteNames.step1}',
  '/${RouteNames.step2}',
  '/${RouteNames.biblelibSetup}',
  '/${RouteNames.seeding}',
};

/// Gate the whole app behind "is setup finished?" — same decision tree
/// [AppViewState] used to run once per [AuthBloc] emission via an
/// imperative `pushNamedAndRemoveUntil`. As a go_router `redirect`, this
/// instead runs on every navigation attempt, so once [isLoaded] it must
/// stop being an unconditional destination and become a guard: only
/// intercept someone stuck on an onboarding screen, otherwise return null
/// and let normal navigation (settings, search, ...) through untouched.
String? appRouterRedirect(GoRouterState state) {
  final prefs = getIt<PrefRepo>();
  final loc = state.matchedLocation;

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
  final songlibSelected = prefs.getPrefBool(PrefConstants.dataIsSelectedKey);
  final songlibLoaded = prefs.getPrefBool(PrefConstants.dataIsLoadedKey);
  final biblelibLoaded = prefs.getPrefBool(
    PrefConstants.biblelibDataLoadedKey,
  );

  final isLoaded = hasChosenModules &&
      (!songlibEnabled || songlibLoaded) &&
      (!biblelibEnabled || biblelibLoaded);

  if (isLoaded) {
    return _onboardingPaths.contains(loc) ? '/${RouteNames.main}' : null;
  }
  if (!hasChosenModules) return '/${RouteNames.welcome}';
  if (songlibEnabled && !songlibLoaded) {
    return songlibSelected ? '/${RouteNames.step2}' : '/${RouteNames.step1}';
  }
  if (biblelibEnabled && !biblelibLoaded) {
    return '/${RouteNames.biblelibSetup}';
  }
  return '/${RouteNames.seeding}';
}
