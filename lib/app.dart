// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'common/navigator/app_router.dart';
import 'core/auth/auth_bloc.dart';
import 'core/di/injectable.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/theme_data.dart';
import 'domain/repos/auth_repo.dart';
import 'domain/repos/pref_repo.dart';
import 'common/widgets/text_scale_factor.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
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

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => AppViewState();
}

class AppViewState extends State<AppView> {
  final _prefRepo = getIt<PrefRepo>();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            routerConfig: _router,
            themeMode: _prefRepo.getThemeMode(),
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            supportedLocales: const [Locale('en'), Locale('sw')],
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) =>
                TextScaleFactor(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}
