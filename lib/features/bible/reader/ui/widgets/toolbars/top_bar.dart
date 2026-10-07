// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../../../common/navigator/route_names.dart';
import '../../../../../../common/utils/reader_utils.dart';
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../cubit/bible_reader_cubit.dart';
import '../dialogs/book_picker_dialog.dart';
import '../dialogs/chapter_picker_dialog.dart';

class TopBar extends StatelessWidget {
  final BibleReaderState state;
  const TopBar({super.key, required this.state});

  Future<void> _openTarget(BuildContext context, String route) async {
    final cubit = context.read<BibleReaderCubit>();
    final target = await context.pushNamed<ReaderTarget>(route);
    if (target != null) await cubit.openTarget(target);
  }

  Future<void> _openScriptureOpener(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final target = await context.pushNamed<ReaderTarget>(
      RouteNames.scriptureOpener,
      extra: (
        bibleAbbr: state.activeBibleAbbr,
        bibleName: state.activeBible,
      ),
    );
    if (target != null) await cubit.openTarget(target);
  }

  Future<void> _openScriptureLists(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final target = await context.pushNamed<ReaderTarget>(
      RouteNames.scriptureLists,
    );
    if (target != null) await cubit.openTarget(target);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BibleReaderCubit>();
    final downloaded = state.savedBibles.where((b) => b.isDownloaded).toList();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: state.books.isEmpty
                  ? null
                  : () async {
                      final book = await showBookPicker(
                        context,
                        books: state.books,
                        activeBookId: state.activeBook?.id,
                      );
                      if (book != null) cubit.selectBook(book);
                    },
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(state.activeBook?.name ?? 'SongBook'),
            ),
            OutlinedButton(
              onPressed: state.chapters.isEmpty
                  ? null
                  : () async {
                      final chapter = await showChapterPicker(
                        context,
                        bookName: state.activeBook?.name ?? '',
                        chapters: state.chapters,
                        activeChapterId: state.activeChapter?.id,
                      );
                      if (chapter != null) cubit.selectChapter(chapter);
                    },
              child: Text('Chapter ${state.activeChapter?.number ?? ''}'),
            ),
            if (downloaded.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: 'Switch Bible',
                onSelected: cubit.setPrimaryBible,
                itemBuilder: (_) => [
                  for (final b in downloaded)
                    PopupMenuItem(
                      value: b.abbreviation,
                      child: Text('${b.abbreviation} · ${b.name}'),
                    ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: ThemeColors.lightGrey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.translate, size: 16),
                      const SizedBox(width: 6),
                      Text(state.activeBibleAbbr),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            if (downloaded.length > 1)
              IconButton(
                tooltip: state.multiBibleReaderEnabled
                    ? 'Hide parallel Bibles'
                    : 'Show parallel Bibles',
                onPressed: () => cubit.setMultiBibleReaderEnabled(
                  !state.multiBibleReaderEnabled,
                ),
                icon: Icon(
                  Icons.view_agenda_outlined,
                  color: state.multiBibleReaderEnabled
                      ? ThemeColors.primary
                      : ThemeColors.mediumGrey,
                ),
              ),
            IconButton(
              tooltip: 'Smaller text',
              onPressed: state.fontSize <= readerMinFontSize
                  ? null
                  : () => cubit.setFontSize(state.fontSize - 2),
              icon: const Icon(Icons.text_decrease),
            ),
            IconButton(
              tooltip: 'Larger text',
              onPressed: state.fontSize >= readerMaxFontSize
                  ? null
                  : () => cubit.setFontSize(state.fontSize + 2),
              icon: const Icon(Icons.text_increase),
            ),
            const VerticalDivider(width: 16, indent: 8, endIndent: 8),
            IconButton(
              tooltip: 'Search',
              onPressed: () => _openTarget(context, RouteNames.bibleSearch),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              tooltip: 'History',
              onPressed: () => _openTarget(context, RouteNames.bibleHistory),
              icon: const Icon(Icons.history),
            ),
            IconButton(
              tooltip: 'Bookmarks & Notes',
              onPressed: () =>
                  _openTarget(context, RouteNames.bibleBookmarksNotes),
              icon: const Icon(Icons.bookmarks_outlined),
            ),
            IconButton(
              tooltip: 'Manage Bibles',
              onPressed: () => context.pushNamed(RouteNames.bibles),
              icon: const Icon(Icons.library_books_outlined),
            ),
            const VerticalDivider(width: 16, indent: 8, endIndent: 8),
            IconButton(
              tooltip: 'Open Scripture',
              onPressed: state.activeChapter == null
                  ? null
                  : () => _openScriptureOpener(context),
              icon: const Icon(Icons.auto_stories_outlined),
            ),
            IconButton(
              tooltip: 'Scripture Lists',
              onPressed: () => _openScriptureLists(context),
              icon: const Icon(Icons.list_alt),
            ),
            const VerticalDivider(width: 16, indent: 8, endIndent: 8),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => context.pushNamed(RouteNames.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
