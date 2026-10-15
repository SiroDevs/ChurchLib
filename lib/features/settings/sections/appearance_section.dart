// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../l10n/app_localizations.dart';
import '../settings_card.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingCard(
      title: l10n.displayTitle,
      widgets: const [SettingsThemeItem()],
    );
  }
}
