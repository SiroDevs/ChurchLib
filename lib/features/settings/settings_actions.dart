// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../common/navigator/route_names.dart';
import '../../common/utils/app_util.dart';
import '../../common/utils/constants/pref_constants.dart';
import '../../common/widgets/state/custom_snackbar.dart';
import '../../core/di/injectable.dart';
import '../../domain/repos/bible/bible_repo.dart';
import '../../domain/repos/database_repo.dart';
import '../../domain/repos/pref_repo.dart';
import '../../l10n/app_localizations.dart';

class SettingsActions {
  SettingsActions(this.context);

  final BuildContext context;
  final _prefRepo = getIt<PrefRepo>();
  final _dbRepo = getIt<DatabaseRepo>();
  final _bibleRepo = getIt<BibleRepo>();

  void _goToSelection() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.goNamed(RouteNames.selection);
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _clearBibleLibPrefs() {
    for (final key in [
      PrefConstants.biblelibDataSelectedKey,
      PrefConstants.biblelibDataLoadedKey,
      PrefConstants.bibleSelectedBiblesKey,
      PrefConstants.biblePrimaryKey,
      PrefConstants.bibleSecondaryKey,
      PrefConstants.bibleLastBibleKey,
      PrefConstants.bibleLastBibleAbbrKey,
      PrefConstants.bibleLastBookIdKey,
      PrefConstants.bibleLastChapterIdKey,
      PrefConstants.bibleLastVerseIdKey,
    ]) {
      _prefRepo.removeKeyPair(key);
    }
  }

  Future<void> resetSongLib() async {
    try {
      await _dbRepo.removeAllBooks();
      await _dbRepo.removeAllSongs();
      _prefRepo.clearData();
      if (!context.mounted) return;
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context)!.redirectingYou,
      );
      _goToSelection();
    } catch (e) {
      logger('Unable to reset SongLib: $e');
    }
  }

  Future<void> resetBibleLib() async {
    final ok = await _confirm(
      'Start over with BibleLib?',
      "This deletes every downloaded Bible, bookmark and note. This can't be undone.",
    );
    if (!ok || !context.mounted) return;
    try {
      await _bibleRepo.deleteAllData();
      _clearBibleLibPrefs();
      if (!context.mounted) return;
      CustomSnackbar.show(
        context,
        AppLocalizations.of(context)!.redirectingYou,
      );
      _goToSelection();
    } catch (e) {
      logger('Unable to reset BibleLib: $e');
    }
  }

  void addSongLib() {
    _prefRepo.setPrefBool(PrefConstants.songlibModuleEnabledKey, true);
    _goToSelection();
  }

  void addBibleLib() {
    _prefRepo.setPrefBool(PrefConstants.biblelibModuleEnabledKey, true);
    _goToSelection();
  }

  Future<void> resetChurchLib() async {
    final ok = await _confirm(
      'Reset ChurchLib?',
      'This erases everything — songbooks, Bibles, bookmarks, notes and '
          "settings — and takes you back to the setup screen. This can't be undone.",
    );
    if (!ok || !context.mounted) return;
    try {
      await _dbRepo.removeAllBooks();
      await _dbRepo.removeAllSongs();
      await _bibleRepo.deleteAllData();
      _prefRepo.clearData();
      _clearBibleLibPrefs();
      _prefRepo.removeKeyPair(PrefConstants.songlibModuleEnabledKey);
      _prefRepo.removeKeyPair(PrefConstants.biblelibModuleEnabledKey);
      if (!context.mounted) return;
      _goToSelection();
    } catch (e) {
      logger('Unable to reset ChurchLib: $e');
    }
  }
}
