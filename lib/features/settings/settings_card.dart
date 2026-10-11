import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../common/utils/theme_switcher_mixin.dart';
import '../../common/widgets/inputs/radio_input.dart';
import '../../core/theme/theme_data.dart';
import '../../core/theme/theme_fonts.dart';
import '../../core/theme/theme_styles.dart';
import '../../l10n/app_localizations.dart';

class SettingCard extends StatelessWidget {
  final String title;
  final List<Widget> widgets;

  const SettingCard({super.key, required this.title, required this.widgets});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.headingStyle3,
        ).padding(left: Sizes.sm, top: Sizes.sm, bottom: Sizes.m),
        for (final widget in widgets) Card(child: widget).padding(bottom: 10),
      ],
    );
  }
}

class SettingsThemeItem extends StatefulWidget {
  const SettingsThemeItem({super.key});

  @override
  State<SettingsThemeItem> createState() => SettingsThemeItemState();
}

class SettingsThemeItemState extends State<SettingsThemeItem>
    with ThemeSwitcherMixin<SettingsThemeItem> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: Text(l10n.appTheme),
      subtitle: Text('${l10n.appThemeDesc} $appTheme'),
      onTap: () => selectThemeDialog(context),
    );
  }

  Future<void> selectThemeDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set the Theme'),
          content: SizedBox(
            height: 135,
            child: RadioInput(
              initValue: appTheme,
              options: const ['System Theme', 'Light Theme', 'Dark Theme'],
              vertical: true,
              onChanged: (String? newValue) {
                setState(() {
                  switch (newValue) {
                    case 'Light Theme':
                      onThemeChanged(ThemeMode.light);
                    case 'Dark Theme':
                      onThemeChanged(ThemeMode.dark);
                    default:
                      onThemeChanged(ThemeMode.system);
                  }
                  appTheme = AppTheme.currentTheme();
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
        );
      },
    );
  }
}
