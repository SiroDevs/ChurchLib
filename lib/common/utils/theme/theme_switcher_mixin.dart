// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../core/di/injectable.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/theme_data.dart';
import '../../../domain/repos/pref_repo.dart';

mixin ThemeSwitcherMixin<T extends StatefulWidget> on State<T> {
  late final ThemeBloc _themeBloc;
  late final PrefRepo _prefRepo;
  String appTheme = '';

  @override
  void initState() {
    super.initState();
    _prefRepo = getIt<PrefRepo>();
    _themeBloc = context.read<ThemeBloc>();
    appTheme = AppTheme.currentTheme();
  }

  void onThemeChanged(ThemeMode themeMode) {
    _prefRepo.updateThemeMode(themeMode);
    _themeBloc.add(ThemeModeChanged(themeMode));
  }
}
