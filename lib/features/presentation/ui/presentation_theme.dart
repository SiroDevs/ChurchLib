import 'package:flutter/material.dart';

/// The preview side is always black and white, whatever the app theme is,
/// because it mirrors what the audience sees.
ThemeData presentationTheme(BuildContext context) {
  final base = Theme.of(context);
  final scheme = base.colorScheme.copyWith(
    brightness: Brightness.dark,
    primary: Colors.white,
    onPrimary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
    secondaryContainer: Colors.black,
    onSecondaryContainer: Colors.white,
    outline: Colors.white54,
    outlineVariant: Colors.white24,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.black,
    dividerColor: Colors.white24,
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
