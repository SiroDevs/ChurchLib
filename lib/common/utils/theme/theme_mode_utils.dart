// Flutter imports:
import 'package:flutter/material.dart';

/// Returns the stable display value stored for a theme mode.
String getThemeModeString(ThemeMode themeMode) => switch (themeMode) {
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
  _ => 'System Theme',
};
