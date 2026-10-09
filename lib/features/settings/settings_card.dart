// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../common/widgets/inputs/radio_input.dart';
import '../../core/di/injectable.dart';
import '../../core/theme/bloc/theme_bloc.dart';
import '../../core/theme/theme_data.dart';
import '../../core/theme/theme_fonts.dart';
import '../../core/theme/theme_styles.dart';
import '../../domain/repos/pref_repo.dart';
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
        ).padding(left: Sizes.sm, top: Sizes.sm),
        for (final widget in widgets) Card(child: widget),
      ],
    );
  }
}

class SettingsThemeItem extends StatefulWidget {
  const SettingsThemeItem({super.key});

  @override
  State<SettingsThemeItem> createState() => SettingsThemeItemState();
}

class SettingsThemeItemState extends State<SettingsThemeItem> {
  late ThemeBloc _themeBloc;
  late PrefRepo _prefRepo;
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
