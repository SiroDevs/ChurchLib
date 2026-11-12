// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../common/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../settings_actions.dart';
import '../settings_card.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = getIt<PrefRepo>();
    final songlib = prefs.getPrefBool(PrefConstants.songlibModuleEnabledKey);
    final biblelib = prefs.getPrefBool(PrefConstants.biblelibModuleEnabledKey);
    final actions = SettingsActions(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!songlib || !biblelib)
          SettingCard(
            title: l10n.modulesTitle,
            widgets: [
              if (!songlib)
                ListTile(
                  leading: const Icon(Icons.library_music_outlined),
                  title: Text(l10n.addSonglib),
                  subtitle: Text(l10n.songlibSetupSubtitle),
                  onTap: actions.addSongLib,
                ),
              if (!biblelib)
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(l10n.addBiblelib),
                  subtitle: Text(l10n.biblelibSetupSubtitle),
                  onTap: actions.addBibleLib,
                ),
            ],
          ),
        SettingCard(
          title: l10n.resetData,
          widgets: [
            if (songlib)
              ListTile(
                leading: const Icon(Icons.library_books),
                title: Text(l10n.reselectSongbooks),
                subtitle: Text(l10n.reselectSongbooksDesc),
                onTap: actions.resetSongLib,
              ),
            if (biblelib)
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: Text(l10n.startOverBiblelib),
                subtitle: Text(l10n.resetBibleSubtitle),
                onTap: actions.resetBibleLib,
              ),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: Text(l10n.resetChurchlib),
              subtitle: Text(l10n.resetChurchSubtitle),
              onTap: actions.resetChurchLib,
            ),
          ],
        ),
      ],
    );
  }
}
