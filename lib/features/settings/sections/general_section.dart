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
            title: 'Modules',
            widgets: [
              if (!songlib)
                ListTile(
                  leading: const Icon(Icons.library_music_outlined),
                  title: const Text('Add SongLib'),
                  subtitle: const Text('Set up your church songbook'),
                  onTap: actions.addSongLib,
                ),
              if (!biblelib)
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Add BibleLib'),
                  subtitle: const Text('Set up a Bible translation'),
                  onTap: actions.addBibleLib,
                ),
            ],
          ),
        SettingCard(
          title: 'Reset data',
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
                title: const Text('Start over with BibleLib'),
                subtitle: const Text(
                  'Delete all downloaded Bibles and choose translations again',
                ),
                onTap: actions.resetBibleLib,
              ),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Reset ChurchLib'),
              subtitle: const Text(
                'Erase everything — songbooks, Bibles, bookmarks — and start over',
              ),
              onTap: actions.resetChurchLib,
            ),
          ],
        ),
      ],
    );
  }
}
