// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../common/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../core/update/update_cubit.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../presentation/controller/presentation_controller.dart';
import '../settings_actions.dart';
import '../settings_card.dart';

class GeneralSection extends StatefulWidget {
  const GeneralSection({super.key});

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  late bool _audienceModeEnabled;
  late bool _autoDownloadUpdates;

  @override
  void initState() {
    super.initState();
    _audienceModeEnabled = PresentationController.instance.audienceModeEnabled;
    _autoDownloadUpdates = getIt<PrefRepo>().getAutoDownloadUpdates();
  }

  void _setAudienceMode(bool enabled) {
    PresentationController.instance.setAudienceModeEnabled(enabled);
    setState(() => _audienceModeEnabled = enabled);
  }

  /// Persists the update download preference and refreshes the release check.
  void _setAutoDownloadUpdates(bool enabled) {
    getIt<PrefRepo>().setAutoDownloadUpdates(enabled);
    setState(() => _autoDownloadUpdates = enabled);
    unawaited(getIt<UpdateCubit>().check());
  }

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
        SettingCard(
          title: l10n.updatesTitle,
          widgets: [
            ListTile(
              leading: const Icon(Icons.system_update_alt),
              title: Text(l10n.settingsAutoDownloadUpdates),
              subtitle: Text(l10n.settingsAutoDownloadUpdatesHelp),
              trailing: Switch(
                value: _autoDownloadUpdates,
                onChanged: _setAutoDownloadUpdates,
              ),
              onTap: () => _setAutoDownloadUpdates(!_autoDownloadUpdates),
            ),
          ],
        ),
        SettingCard(
          title: l10n.audienceModeSettingsTitle,
          widgets: [
            ListTile(
              leading: const Icon(Icons.present_to_all),
              title: Text(l10n.audienceModeTitle),
              subtitle: Text(l10n.audienceModeDescription),
              trailing: Switch(
                value: _audienceModeEnabled,
                onChanged: _setAudienceMode,
              ),
              onTap: () => _setAudienceMode(!_audienceModeEnabled),
            ),
          ],
        ),
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
