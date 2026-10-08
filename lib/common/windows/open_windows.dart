// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../data/models/models.dart';
import '../../domain/entities/bible/bible_reader.dart';
import '../../features/bible/bookmarks/ui/bookmarks_notes_screen.dart';
import '../../features/bible/history/ui/bible_history_screen.dart';
import '../../features/bible/scripture/scripture_list/ui/scripture_lists_screen.dart';
import '../../features/bible/scripture/scripture_list_detail/ui/scripture_list_detail_screen.dart';
import '../../features/bible/scripture/scripture_opener/ui/scripture_opener_screen.dart';
import '../../features/bible/search/ui/bible_search_screen.dart';
import '../../features/home/main/shell/app_module.dart';
import '../../features/settings/bible_screen/ui/bibles_screen.dart';
import '../../features/settings/settings_window.dart';
import '../../features/song/presentor/ui/presentor_screen.dart';
import 'window_frame.dart';

Future<ReaderTarget?> openBibleSearch(BuildContext context) =>
    showAppWindow<ReaderTarget>(
      context,
      child: const BibleSearchScreen(),
      width: 900,
    );

Future<ReaderTarget?> openBibleHistory(BuildContext context) =>
    showAppWindow<ReaderTarget>(
      context,
      child: const BibleHistoryScreen(),
      width: 860,
    );

Future<ReaderTarget?> openBookmarksNotes(BuildContext context, {int tab = 0}) =>
    showAppWindow<ReaderTarget>(
      context,
      child: BookmarksNotesScreen(initialTab: tab),
      width: 860,
    );

Future<ReaderTarget?> openScriptureLists(BuildContext context) =>
    showAppWindow<ReaderTarget>(
      context,
      child: const ScriptureListsScreen(),
      width: 860,
    );

Future<ReaderTarget?> openScriptureListDetail(
  BuildContext context,
  int listId,
) =>
    showAppWindow<ReaderTarget>(
      context,
      child: ScriptureListDetailScreen(listId: listId),
      width: 860,
    );

Future<ReaderTarget?> openScriptureOpener(
  BuildContext context, {
  required String bibleAbbr,
  required String bibleName,
}) =>
    showAppWindow<ReaderTarget>(
      context,
      child: ScriptureOpenerScreen(bibleAbbr: bibleAbbr, bibleName: bibleName),
      width: 680,
    );

Future<void> openBibles(BuildContext context) => showAppWindow<void>(
      context,
      child: const BiblesScreen(),
      width: 860,
    );

Future<bool?> openPresentor(
  BuildContext context, {
  required SongExt song,
  required SongBook book,
  required List<SongExt> songs,
}) =>
    showAppWindow<bool>(
      context,
      child: PresentorScreen(song: song, book: book, songs: songs),
      width: 1600,
      height: 1000,
      inset: const EdgeInsets.all(12),
    );

Future<void> openSettings(BuildContext context, AppModule module) =>
    showAppWindow<void>(context, child: SettingsWindow(module: module));
