// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../l10n/gen/app_localizations.dart';
import '../utils/theme/theme_switcher_mixin.dart';

class ThemeButton extends StatefulWidget {
  final bool showLabel;

  const ThemeButton({super.key, this.showLabel = false});

  @override
  State<ThemeButton> createState() => ThemeButtonState();
}

class ThemeButtonState extends State<ThemeButton>
    with ThemeSwitcherMixin<ThemeButton> {
  late AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;
    var isDark = Theme.of(context).brightness == Brightness.dark;

    final icon = Icon(isDark ? Icons.light_mode : Icons.dark_mode);
    void toggle() => onThemeChanged(isDark ? ThemeMode.light : ThemeMode.dark);

    if (widget.showLabel) {
      return TextButton.icon(
        icon: icon,
        label: Text(isDark ? 'Light mode' : 'Dark mode'),
        onPressed: toggle,
      );
    }
    return Tooltip(
      message: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
      child: IconButton(icon: icon, onPressed: toggle),
    );
  }
}
