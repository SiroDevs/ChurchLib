// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../scripture_queue/cubit/scripture_queue_cubit.dart';
import '../cubit/bible_reader_cubit.dart';
import 'widgets/dialogs/export.dart';
import 'widgets/toolbars/export.dart';
import 'widgets/verses/verse_row.dart';

class BiblerReaderView extends StatefulWidget {
  const BiblerReaderView({super.key});

  @override
  State<BiblerReaderView> createState() => BiblerReaderViewState();
}

class BiblerReaderViewState extends State<BiblerReaderView> {
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

  void _onStateChanged(BuildContext context, BibleReaderState state) {
    final target = state.restoreVerseId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (target != null) {
        _scrollToVerse(target);
        context.read<BibleReaderCubit>().consumeRestoreVerseTarget();
      } else if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
    final chapter = state.activeChapter;
    if (chapter != null) {
      getIt<ScriptureQueueCubit>().syncActiveByChapter(
        state.activeBibleAbbr,
        chapter.id,
      );
    }
  }

  void _scheduleScrollReport() {
    _scrollReportTimer?.cancel();
    _scrollReportTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final cubit = context.read<BibleReaderCubit>();
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
    final cubit = context.read<BibleReaderCubit>();
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
        child: BlocConsumer<BibleReaderCubit, BibleReaderState>(
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
                        ? SelectionBar(state: state)
                        : TopBar(state: state),
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
                            ? ScriptureQueueBar(queueState: queueState)
                            : ChapterNavBar(state: state),
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
    final cubit = context.read<BibleReaderCubit>();
    await showNoteEditor(context, request);
    await cubit.refreshNotedVerses();
  }

  Widget _buildBody(BuildContext context, BibleReaderState state) {
    if (state.error != null && state.verses.isEmpty) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 56,
              color: ThemeColors.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<BibleReaderCubit>().initialize(),
              style: FilledButton.styleFrom(
                backgroundColor: ThemeColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ).padding(all: 32).center();
    }
    if (state.isLoading && state.verses.isEmpty) {
      return CircularProgressIndicator(color: ThemeColors.primary).center();
    }

    final cubit = context.read<BibleReaderCubit>();
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
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.activeBook != null && state.activeChapter != null)
                    Text(
                      state.activeChapter!.reference,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.primary,
                      ),
                    ).padding(bottom: 12, left: 8),
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
                                e.key:
                                    e.value
                                        .where((p) => p.number == v.number)
                                        .map((p) => p.text)
                                        .firstOrNull ??
                                    '',
                            }
                          : const {},
                      isBookmarked: state.bookmarks.containsKey(v.verseId),
                      bookmarkColorHex: state.bookmarks[v.verseId],
                      hasNote: state.notedVerseIds.contains(v.verseId),
                      onToggleBookmark: () =>
                          cubit.quickToggleBookmark(v.verseId),
                      onOpenNote: () => _openNote(
                        context,
                        cubit.notesRequestForVerse(v.verseId),
                      ),
                      isSelected: state.selectedVerseIds.contains(v.verseId),
                      isSelectionMode: state.isSelectionMode,
                      onToggleSelected: () =>
                          cubit.toggleVerseSelected(v.verseId),
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ).center();
  }
}
