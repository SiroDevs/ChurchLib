// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../core/di/injectable.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/theme_data.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../l10n/app_localizations.dart';

class ThemeButton extends StatefulWidget {
  const ThemeButton({super.key});

  @override
  State<ThemeButton> createState() => ThemeButtonState();
}

class ThemeButtonState extends State<ThemeButton> {
  late ThemeBloc _themeBloc;
  late PrefRepo _prefRepo;

  late AppLocalizations l10n;
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

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;
    var isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
      child: IconButton(
        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        onPressed: () => {
          onThemeChanged(isDark ? ThemeMode.light : ThemeMode.dark),
        },
      ),
    );
  }
}
