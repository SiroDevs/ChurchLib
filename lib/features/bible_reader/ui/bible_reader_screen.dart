// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../common/navigator/route_names.dart';
import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/bible/scripture_item.dart';
import '../../scripture/bloc/scripture_queue_cubit.dart';
import '../../scripture/ui/scripture_lists_screen.dart';
import '../../scripture/ui/scripture_opener_screen.dart';
import '../../settings/settings_screen.dart';
import '../bloc/reader_cubit.dart';
import 'book_chapter_pickers.dart';
import 'reader_dialogs.dart';
import 'verse_row.dart';

/// BibleLib's reader, ported from biblelib-android's reader feature.
/// Implemented so far: content loading, book/chapter/Bible switching,
/// parallel translations, last-position restore, reading history, quick
/// bookmarks, multi-select with highlight colors, notes, copy, font size.
/// Not yet: scripture queue, casting, reader font/background themes.
class BibleReaderScreen extends StatelessWidget {
  /// Optional deep-link target (from search / history / bookmarks).
  final String bibleAbbr;
  final String bookId;
  final String chapterId;
  final String verseId;
  final String searchQuery;

  const BibleReaderScreen({
    super.key,
    this.bibleAbbr = '',
    this.bookId = '',
    this.chapterId = '',
    this.verseId = '',
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReaderCubit()
        ..initialize(
          initialBibleAbbr: bibleAbbr,
          initialBookId: bookId,
          initialChapterId: chapterId,
          initialVerseId: verseId,
          initialSearchQry: searchQuery,
        ),
      child: const _ReaderView(),
    );
  }
}

class _ReaderView extends StatefulWidget {
  const _ReaderView();

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  final _scrollController = ScrollController();
  final _viewportKey = GlobalKey();
  final _verseKeys = <String, GlobalKey>{};
  Timer? _scrollReportTimer;

  @override
  void dispose() {
    _scrollReportTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String verseId) =>
      _verseKeys.putIfAbsent(verseId, () => GlobalKey());

  void _scrollToVerse(String verseId, {bool retry = true}) {
    final ctx = _verseKeys[verseId]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, alignment: 0.02, duration: Duration.zero);
    } else if (retry) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToVerse(verseId, retry: false),
      );
    }
  }

  void _onStateChanged(BuildContext context, ReaderState state) {
    final target = state.restoreVerseId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (target != null) {
        _scrollToVerse(target);
        context.read<ReaderCubit>().consumeRestoreVerseTarget();
      } else if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
    final chapter = state.activeChapter;
    if (chapter != null) {
      getIt<ScriptureQueueCubit>()
          .syncActiveByChapter(state.activeBibleAbbr, chapter.id);
    }
  }

  void _scheduleScrollReport() {
    _scrollReportTimer?.cancel();
    _scrollReportTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final cubit = context.read<ReaderCubit>();
      final viewport = _viewportKey.currentContext?.findRenderObject();
      if (viewport is! RenderBox || !viewport.attached) return;
      final top = viewport.localToGlobal(Offset.zero).dy;
      for (final v in cubit.state.verses) {
        final box = _verseKeys[v.verseId]?.currentContext?.findRenderObject();
        if (box is! RenderBox || !box.attached) continue;
        final dy = box.localToGlobal(Offset.zero).dy;
        if (dy + box.size.height > top + 4) {
          cubit.onVerseScrollPositionChanged(v.verseId, v.number);
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReaderCubit>();
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): () =>
            cubit.navigateChapter(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true): () =>
            cubit.navigateChapter(1),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            cubit.clearSelection(),
      },
      child: Focus(
        autofocus: true,
        child: BlocConsumer<ReaderCubit, ReaderState>(
          listenWhen: (p, c) =>
              p.activeChapter?.id != c.activeChapter?.id ||
              (!identical(p.verses, c.verses) && c.restoreVerseId != null),
          listener: _onStateChanged,
          builder: (context, state) {
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    state.isSelectionMode
                        ? _SelectionBar(state: state)
                        : _TopBar(state: state),
                    if (state.isLoading && state.verses.isNotEmpty)
                      const LinearProgressIndicator(
                        minHeight: 2,
                        color: ThemeColors.primary,
                      ),
                    Expanded(child: _buildBody(context, state)),
                    if (state.activeChapter != null)
                      BlocBuilder<ScriptureQueueCubit, ScriptureQueueState>(
                        bloc: getIt<ScriptureQueueCubit>(),
                        builder: (context, queueState) => queueState.isOpen
                            ? _ScriptureQueueBar(queueState: queueState)
                            : _ChapterNavBar(state: state),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openNote(BuildContext context, NotesRequest? request) async {
    if (request == null) return;
    final cubit = context.read<ReaderCubit>();
    await showNoteEditor(context, request);
    await cubit.refreshNotedVerses();
  }

  Widget _buildBody(BuildContext context, ReaderState state) {
    if (state.error != null && state.verses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_rounded,
                  size: 56, color: ThemeColors.mediumGrey),
              const SizedBox(height: 16),
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.read<ReaderCubit>().initialize(),
                style: FilledButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.isLoading && state.verses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }

    final cubit = context.read<ReaderCubit>();
    final parallelActive =
        state.multiBibleReaderEnabled && state.parallelVerses.isNotEmpty;

    return Directionality(
      textDirection: state.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (_) {
          _scheduleScrollReport();
          return false;
        },
        child: SingleChildScrollView(
          key: _viewportKey,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.activeBook != null && state.activeChapter != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 8),
                      child: Text(
                        state.activeChapter!.reference,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.primary,
                        ),
                      ),
                    ),
                  for (final v in state.verses)
                    VerseRow(
                      key: _keyFor(v.verseId),
                      number: v.number,
                      text: v.text,
                      fontSize: state.fontSize.toDouble(),
                      highlightQuery: state.highlightQuery,
                      parallelTexts: parallelActive
                          ? {
                              for (final e in state.parallelVerses.entries)
                                e.key: e.value
                                    .where((p) => p.number == v.number)
                                    .map((p) => p.text)
                                    .firstOrNull ??
                                    '',
                            }
                          : const {},
                      isBookmarked: state.bookmarks.containsKey(v.verseId),
                      bookmarkColorHex: state.bookmarks[v.verseId],
                      hasNote: state.notedVerseIds.contains(v.verseId),
                      onToggleBookmark: () => cubit.quickToggleBookmark(v.verseId),
                      onOpenNote: () => _openNote(
                        context,
                        cubit.notesRequestForVerse(v.verseId),
                      ),
                      isSelected: state.selectedVerseIds.contains(v.verseId),
                      isSelectionMode: state.isSelectionMode,
                      onToggleSelected: () => cubit.toggleVerseSelected(v.verseId),
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final ReaderState state;
  const _TopBar({required this.state});

  Future<void> _openTarget(BuildContext context, String route) async {
    final cubit = context.read<ReaderCubit>();
    final target = await Navigator.pushNamed<ReaderTarget>(context, route);
    if (target != null) await cubit.openTarget(target);
  }

  Future<void> _openScriptureOpener(BuildContext context) async {
    final cubit = context.read<ReaderCubit>();
    final target = await Navigator.push<ReaderTarget>(
      context,
      MaterialPageRoute(
        builder: (_) => ScriptureOpenerScreen(
          bibleAbbr: state.activeBibleAbbr,
          bibleName: state.activeBible,
        ),
      ),
    );
    if (target != null) await cubit.openTarget(target);
  }

  Future<void> _openScriptureLists(BuildContext context) async {
    final cubit = context.read<ReaderCubit>();
    final target = await Navigator.push<ReaderTarget>(
      context,
      MaterialPageRoute(builder: (_) => const ScriptureListsScreen()),
    );
    if (target != null) await cubit.openTarget(target);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReaderCubit>();
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
              label: Text(state.activeBook?.name ?? 'Book'),
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
              onPressed: () => Navigator.pushNamed(context, RouteNames.bibles),
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

/// Replaces the chapter nav bar while a scripture queue (from Scripture
/// Opener or a saved Scripture List) is open — Previous/Next step through
/// the queue's items instead of chapters. Ported from Android's floating
/// queue widget over `ChapterNavBar`.
class _ScriptureQueueBar extends StatelessWidget {
  final ScriptureQueueState queueState;
  const _ScriptureQueueBar({required this.queueState});

  void _open(BuildContext context, ScriptureItem item) {
    getIt<ScriptureQueueCubit>().setActiveItem(item.id!);
    context.read<ReaderCubit>().openTarget(
          ReaderTarget(
            bibleAbbr: item.bibleAbbr,
            bookId: item.bookId,
            chapterId: item.chapterId,
            verseId: item.verseId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final items = queueState.items;
    final index = queueState.activeIndex;
    final hasPrev = index > 0;
    final hasNext = index >= 0 && index < items.length - 1;
    final current = queueState.activeItem;

    return Material(
      color: ThemeColors.primary.withValues(alpha: 0.12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Close queue',
              onPressed: () => getIt<ScriptureQueueCubit>().dismiss(),
              icon: const Icon(Icons.close),
            ),
            IconButton(
              tooltip: 'Previous',
              onPressed: hasPrev ? () => _open(context, items[index - 1]) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current?.reference ?? queueState.listName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (index >= 0)
                    Text(
                      '${index + 1} of ${items.length} · ${queueState.listName}',
                      style: const TextStyle(fontSize: 11, color: ThemeColors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Next',
              onPressed: hasNext ? () => _open(context, items[index + 1]) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterNavBar extends StatelessWidget {
  final ReaderState state;
  const _ChapterNavBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReaderCubit>();
    final idx = state.chapters.indexWhere((c) => c.id == state.activeChapter!.id);
    final hasPrev = idx > 0;
    final hasNext = idx >= 0 && idx < state.chapters.length - 1;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: hasPrev ? () => cubit.navigateChapter(-1) : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
            Text(
              state.activeChapter!.reference,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: hasNext ? () => cubit.navigateChapter(1) : null,
              icon: const Icon(Icons.chevron_right),
              iconAlignment: IconAlignment.end,
              label: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Replaces the top bar while verses are selected. Ported from Android's
/// ReaderSelectionBar (Share is omitted on desktop; Copy covers it).
class _SelectionBar extends StatelessWidget {
  final ReaderState state;
  const _SelectionBar({required this.state});

  Future<void> _bookmark(BuildContext context) async {
    final cubit = context.read<ReaderCubit>();
    final color = await showHighlightColorPicker(context);
    if (color == null || !context.mounted) return;
    cubit.chooseHighlightColor(color);

    final choice = await showBookmarkOptionsDialog(context);
    if (!context.mounted) return;
    switch (choice) {
      case BookmarkChoice.bookmarkOnly:
        await cubit.confirmBookmarkOnly();
      case BookmarkChoice.withNotes:
        final request = await cubit.confirmBookmarkWithNotes();
        if (request != null && context.mounted) {
          await showNoteEditor(context, request);
          await cubit.refreshNotedVerses();
        }
      case null:
        cubit.cancelPendingHighlight();
    }
  }

  Future<void> _notes(BuildContext context) async {
    final cubit = context.read<ReaderCubit>();
    final request = cubit.openNotesForSelection();
    if (request == null) return;
    await showNoteEditor(context, request);
    await cubit.refreshNotedVerses();
  }

  Future<void> _copy(BuildContext context) async {
    final text = context.read<ReaderCubit>().buildSelectionShareText();
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReaderCubit>();
    final count = state.selectedVerseIds.length;
    return Material(
      color: ThemeColors.primary.withValues(alpha: 0.14),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Cancel selection (Esc)',
              onPressed: cubit.clearSelection,
              icon: const Icon(Icons.close),
            ),
            Text(
              '$count selected',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Bookmark / highlight',
              onPressed: () => _bookmark(context),
              icon: const Icon(Icons.bookmark_rounded),
            ),
            IconButton(
              tooltip: count == 1 ? 'Add note' : 'Select a single verse to add a note',
              onPressed: count == 1 ? () => _notes(context) : null,
              icon: const Icon(Icons.edit_note),
            ),
            IconButton(
              tooltip: 'Copy',
              onPressed: () => _copy(context),
              icon: const Icon(Icons.content_copy),
            ),
          ],
        ),
      ),
    );
  }
}
