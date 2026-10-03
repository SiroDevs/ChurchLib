// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../common/navigator/route_names.dart';
import '../../common/utils/app_util.dart';
import '../../common/utils/constants/pref_constants.dart';
import '../../core/di/injectable.dart';
import '../../core/theme/bloc/theme_bloc.dart';
import '../../core/theme/theme_data.dart';
import '../../core/theme/theme_fonts.dart';
import '../../core/theme/theme_styles.dart';
import '../../domain/repos/bible/bible_repo.dart';
import '../../domain/repos/database_repo.dart';
import '../../domain/repos/pref_repo.dart';
import '../../l10n/app_localizations.dart';
import 'bible_screen/ui/bibles_screen.dart';
import '../biblelib/bookmarks/bible_bookmarks_notes_screen.dart';
import '../biblelib/history/bible_history_screen.dart';
import '../widgets/inputs/radio_input.dart';
import '../widgets/progress/custom_snackbar.dart';

part 'settings_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late PrefRepo _prefRepo;
  late DatabaseRepo _dbRepo;
  late BibleRepo _bibleRepo;

  bool updateFound = false, slideVertical = true;
  bool songlibEnabled = false, biblelibEnabled = false;
  late AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    _prefRepo = getIt<PrefRepo>();
    _dbRepo = getIt<DatabaseRepo>();
    _bibleRepo = getIt<BibleRepo>();
    slideVertical = _prefRepo.getPrefBool(PrefConstants.slideVerticalKey);
    _refreshModules();
  }

  void _refreshModules() {
    songlibEnabled = _prefRepo.getPrefBool(
      PrefConstants.songlibModuleEnabledKey,
    );
    biblelibEnabled = _prefRepo.getPrefBool(
      PrefConstants.biblelibModuleEnabledKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;
    final items = <Widget>[
      SettingCard(title: l10n.displayTitle, widgets: [SettingsThemeItem()]),
      if (songlibEnabled) ..._songlibCards(),
      if (biblelibEnabled) ..._bibleLibCards(),
      SettingCard(title: 'Modules', widgets: _moduleWidgets()),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appSettings)),
      body: LayoutBuilder(
        builder: (context, dimens) {
          final axisCount = (dimens.maxWidth / 500).round();
          return GridView.builder(
            padding: const EdgeInsets.all(Sizes.sm),
            physics: const ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: axisCount,
              childAspectRatio: 4,
            ),
            itemCount: items.length,
            itemBuilder: (_, index) => items[index],
          );
        },
      ),
    );
  }

  List<Widget> _songlibCards() {
    return [
      SettingCard(
        title: l10n.collectionTitle,
        widgets: [
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text(l10n.reselectSongbooks),
            subtitle: Text(l10n.reselectSongbooksDesc),
            onTap: onResetSongLib,
          ),
        ],
      ),
      SettingCard(
        title: l10n.presentationTitle,
        widgets: [
          ListTile(
            leading: Icon(Icons.slideshow),
            title: Text(l10n.songPresentation),
            subtitle: Text(l10n.songPresentationDesc),
            trailing: Switch(
              value: slideVertical,
              onChanged: (value) => updateSlideAxis(value),
            ),
            onTap: () => updateSlideAxis(!slideVertical),
          ),
        ],
      ),
    ];
  }

  List<Widget> _bibleLibCards() {
    return [
      SettingCard(
        title: 'BibleLib',
        widgets: [
          ListTile(
            leading: const Icon(Icons.library_books_outlined),
            title: const Text('Manage Bibles'),
            subtitle: const Text(
              'Choose your primary Bible and parallel translations',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BiblesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Reading & search history'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BibleHistoryScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmarks_outlined),
            title: const Text('Bookmarks & notes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BibleBookmarksNotesScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Start over with BibleLib'),
            subtitle: const Text(
              'Delete all downloaded Bibles and choose translations again',
            ),
            onTap: onResetBibleLib,
          ),
        ],
      ),
    ];
  }

  List<Widget> _moduleWidgets() {
    return [
      if (!songlibEnabled)
        ListTile(
          leading: const Icon(Icons.library_music_outlined),
          title: const Text('Add SongLib'),
          subtitle: const Text('Set up your church songbook'),
          onTap: onAddSongLib,
        ),
      if (!biblelibEnabled)
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: const Text('Add BibleLib'),
          subtitle: const Text('Set up a Bible translation'),
          onTap: onAddBibleLib,
        ),
      ListTile(
        leading: const Icon(Icons.delete_forever_outlined),
        title: const Text('Reset ChurchLib'),
        subtitle: const Text(
          'Erase everything — songbooks, Bibles, bookmarks — and start over',
        ),
        onTap: onResetChurchLib,
      ),
    ];
  }

  Future<void> updateSlideAxis(bool value) async {
    _prefRepo.setPrefBool(PrefConstants.slideVerticalKey, value);
    setState(() => slideVertical = value);
  }

  Future<void> onResetSongLib() async {
    try {
      await _dbRepo.removeAllBooks();
      await _dbRepo.removeAllSongs();
      _prefRepo.clearData();
      if (!mounted) return;
      CustomSnackbar.show(context, l10n.redirectingYou);
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.step1,
        (route) => false,
      );
    } catch (e) {
      logger('Unable to reset SongLib: $e');
    }
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
    _prefRepo.removeKeyPair(PrefConstants.biblelibDataSelectedKey);
    _prefRepo.removeKeyPair(PrefConstants.biblelibDataLoadedKey);
    _prefRepo.removeKeyPair(PrefConstants.bibleSelectedBiblesKey);
    _prefRepo.removeKeyPair(PrefConstants.biblePrimaryKey);
    _prefRepo.removeKeyPair(PrefConstants.bibleSecondaryKey);
    _prefRepo.removeKeyPair(PrefConstants.bibleLastBibleKey);
    _prefRepo.removeKeyPair(PrefConstants.bibleLastBibleAbbrKey);
    _prefRepo.removeKeyPair(PrefConstants.bibleLastBookIdKey);
    _prefRepo.removeKeyPair(PrefConstants.bibleLastChapterIdKey);
    _prefRepo.removeKeyPair(PrefConstants.bibleLastVerseIdKey);
  }

  Future<void> onResetBibleLib() async {
    final ok = await _confirm(
      'Start over with BibleLib?',
      "This deletes every downloaded Bible, bookmark and note. This can't be undone.",
    );
    if (!ok || !mounted) return;
    try {
      await _bibleRepo.deleteAllData();
      _clearBibleLibPrefs();
      if (!mounted) return;
      CustomSnackbar.show(context, l10n.redirectingYou);
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.biblelibSetup,
        (route) => false,
      );
    } catch (e) {
      logger('Unable to reset BibleLib: $e');
    }
  }

  void onAddSongLib() {
    _prefRepo.setPrefBool(PrefConstants.songlibModuleEnabledKey, true);
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.step1,
      (route) => false,
    );
  }

  void onAddBibleLib() {
    _prefRepo.setPrefBool(PrefConstants.biblelibModuleEnabledKey, true);
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.biblelibSetup,
      (route) => false,
    );
  }

  Future<void> onResetChurchLib() async {
    final ok = await _confirm(
      'Reset ChurchLib?',
      "This erases everything — songbooks, Bibles, bookmarks, notes and "
      "settings — and takes you back to the welcome screen. This can't be undone.",
    );
    if (!ok || !mounted) return;
    try {
      await _dbRepo.removeAllBooks();
      await _dbRepo.removeAllSongs();
      await _bibleRepo.deleteAllData();
      _prefRepo.clearData();
      _clearBibleLibPrefs();
      _prefRepo.removeKeyPair(PrefConstants.songlibModuleEnabledKey);
      _prefRepo.removeKeyPair(PrefConstants.biblelibModuleEnabledKey);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.welcome,
        (route) => false,
      );
    } catch (e) {
      logger('Unable to reset ChurchLib: $e');
    }
  }
}
