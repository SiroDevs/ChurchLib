// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../common/utils/app_util.dart';
import '../../domain/repos/pref_repo.dart';
import '../di/injectable.dart';
import 'theme_builder.dart';
import 'theme_colors.dart';

class AppTheme {
  AppTheme._();

  static String currentTheme() {
    var prefRepo = getIt<PrefRepo>();
    return getThemeModeString(prefRepo.getThemeMode());
  }

  static const _lightBg = Color(0xFFFBF8F4);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightChrome = Color(0xFFF4ECE0);
  static const _lightOutline = Color(0xFFE5DBCD);

  static const _darkBg = Color(0xFF0F0B0A);
  static const _darkSurface = Color(0xFF171211);
  static const _darkChrome = Color(0xFF201816);
  static const _darkOutline = Color(0xFF3A2E2A);

  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ThemeColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: ThemeColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFE2C2),
      onPrimaryContainer: ThemeColors.primaryDark1,
      secondary: ThemeColors.primary1,
      onSecondary: Colors.white,
      secondaryContainer: _lightChrome,
      onSecondaryContainer: ThemeColors.primaryDark,
      tertiary: ThemeColors.accent2,
      surface: _lightSurface,
      onSurface: const Color(0xFF1E1A18),
      surfaceContainerLowest: _lightBg,
      surfaceContainerLow: _lightBg,
      surfaceContainer: _lightChrome,
      onSurfaceVariant: const Color(0xFF6B5F58),
      outline: const Color(0xFFB8A99B),
      outlineVariant: _lightOutline,
      error: ThemeColors.error,
    );
    return buildThemeData(scheme, _lightBg);
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ThemeColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFF0A24B),
      onPrimary: const Color(0xFF2A1400),
      primaryContainer: ThemeColors.primary3,
      onPrimaryContainer: ThemeColors.accent1,
      secondary: ThemeColors.accent3,
      onSecondary: Colors.black,
      secondaryContainer: _darkChrome,
      onSecondaryContainer: ThemeColors.accent1,
      tertiary: ThemeColors.accent2,
      surface: _darkSurface,
      onSurface: const Color(0xFFF3ECE6),
      surfaceContainerLowest: _darkBg,
      surfaceContainerLow: _darkBg,
      surfaceContainer: _darkChrome,
      onSurfaceVariant: const Color(0xFFBFB2A8),
      outline: const Color(0xFF7A6A60),
      outlineVariant: _darkOutline,
      error: const Color(0xFFFFB4AB),
    );
    return buildThemeData(scheme, _darkBg);
  }

}
