// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'core/auth/auth_bloc.dart';
import 'core/di/injectable.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/theme_data.dart';
import 'common/utils/constants/pref_constants.dart';
import 'domain/repos/auth_repo.dart';
import 'domain/repos/pref_repo.dart';
import 'features/l10n/app_localizations.dart';
import 'features/navigator/main_navigator.dart';
import 'features/navigator/route_names.dart';

class MyApp extends StatefulWidget {
  final Widget? home;
  const MyApp({super.key, this.home});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final navigatorKey = MainNavigatorState.navigationKey;
  NavigatorState get navigator =>
      MainNavigatorState.navigationKey.currentState!;
  late final AuthRepo _authRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepo();
  }

  @override
  void dispose() {
    _authRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authRepo,
      child: BlocProvider(
        create: (_) => AuthBloc(authRepo: _authRepo),
        child: const AppView(),
      ),
    );
  }
}

/// A widget that builds the main view of the application. It sets up the
/// necessary providers and handles navigation and theming.
///
/// The [AppView] widget can optionally take a [home] widget to display as the
/// initial screen.
class AppView extends StatefulWidget {
  final Widget? home;
  const AppView({super.key, this.home});

  @override
  State<AppView> createState() => AppViewState();
}

class AppViewState extends State<AppView> {
  final navigatorKey = MainNavigatorState.navigationKey;
  NavigatorState get navigator =>
      MainNavigatorState.navigationKey.currentState!;
  // final _syncRepo = SongSyncRepo();
  final _prefrepo = getIt<PrefRepo>();

  @override
  Widget build(BuildContext context) {
    // Whether the user has been through the welcome screen at all. Absence
    // of both module keys means this is a fresh install.
    bool hasChosenModules = _prefrepo.keyExists(
          PrefConstants.songlibModuleEnabledKey,
        ) ||
        _prefrepo.keyExists(PrefConstants.biblelibModuleEnabledKey);

    bool songlibEnabled = _prefrepo.getPrefBool(
      PrefConstants.songlibModuleEnabledKey,
    );
    bool biblelibEnabled = _prefrepo.getPrefBool(
      PrefConstants.biblelibModuleEnabledKey,
    );

    bool songlibSelected = _prefrepo.getPrefBool(
      PrefConstants.dataIsSelectedKey,
    );
    bool songlibLoaded = _prefrepo.getPrefBool(PrefConstants.dataIsLoadedKey);
    bool biblelibLoaded = _prefrepo.getPrefBool(
      PrefConstants.biblelibDataLoadedKey,
    );

    // Every enabled module has finished its own setup + seeding.
    bool isLoaded = hasChosenModules &&
        (!songlibEnabled || songlibLoaded) &&
        (!biblelibEnabled || biblelibLoaded);

    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            home: widget.home,
            themeMode: _prefrepo.getThemeMode(),
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            supportedLocales: const [Locale('en'), Locale('sw')],
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            initialRoute: MainNavigatorState.initialRoute,
            onGenerateRoute: MainNavigatorState.onGenerateRoute,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => BlocListener<AuthBloc, AuthState>(
              listener: (context, state) async {
                // if (await isConnectedToInternet()) {
                //   await _syncRepo.syncData();
                // }
                if (isLoaded) {
                  navigator.pushNamedAndRemoveUntil<void>(
                    RouteNames.main,
                    (route) => false,
                  );
                } else if (!hasChosenModules) {
                  navigator.pushNamedAndRemoveUntil<void>(
                    RouteNames.welcome,
                    (route) => false,
                  );
                } else if (songlibEnabled && !songlibLoaded) {
                  navigator.pushNamedAndRemoveUntil<void>(
                    songlibSelected ? RouteNames.step2 : RouteNames.step1,
                    (route) => false,
                  );
                } else if (biblelibEnabled && !biblelibLoaded) {
                  navigator.pushNamedAndRemoveUntil<void>(
                    RouteNames.biblelibSetup,
                    (route) => false,
                  );
                } else {
                  navigator.pushNamedAndRemoveUntil<void>(
                    RouteNames.seeding,
                    (route) => false,
                  );
                }
              },
              child: child,
            ),
          );
        },
      ),
    );
  }
}
