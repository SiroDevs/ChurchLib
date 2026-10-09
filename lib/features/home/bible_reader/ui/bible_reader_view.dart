// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../bible/scripture/scripture_queue/cubit/scripture_queue_cubit.dart';
import '../../main/shell/app_module.dart';
import '../../main/shell/app_shell.dart';
import '../cubit/bible_reader_cubit.dart';
import 'widgets/dialogs/reader_options_sheet.dart';
import 'widgets/toolbars/export.dart';
import 'widgets/verses/reader_auto_scroll.dart';
import 'widgets/verses/reader_body.dart';

class BiblerReaderView extends StatefulWidget {
  const BiblerReaderView({super.key});

  @override
  State<BiblerReaderView> createState() => BiblerReaderViewState();
}

class BiblerReaderViewState extends State<BiblerReaderView>
    with ReaderAutoScrollMixin {
  @override
  final scrollController = ScrollController();
  final _viewportKey = GlobalKey();
  final _verseKeys = <String, GlobalKey>{};
  Timer? _scrollReportTimer;

  @override
  void dispose() {
    disposeAutoScroll();
    _scrollReportTimer?.cancel();
    scrollController.dispose();
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
    stopAutoScroll();
    final target = state.restoreVerseId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (target != null) {
        _scrollToVerse(target);
        context.read<BibleReaderCubit>().consumeRestoreVerseTarget();
      } else if (scrollController.hasClients) {
        scrollController.jumpTo(0);
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
            return AppShell(
              module: AppModule.biblelib,
              sidebarItems: bibleSidebarItems(context),
              titleBar: state.isSelectionMode
                  ? SelectionBar(state: state)
                  : BibleTitleBar(state: state),
              body: Column(
                children: [
                  if (state.isLoading && state.verses.isNotEmpty)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: ThemeColors.primary,
                    ),
                  Expanded(
                    child: Listener(
                      onPointerDown: (_) => stopAutoScroll(),
                      child: ColoredBox(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        child: ReaderBody(
                          state: state,
                          scrollController: scrollController,
                          viewportKey: _viewportKey,
                          keyFor: _keyFor,
                          onScrollEnd: _scheduleScrollReport,
                        ),
                      ),
                    ),
                  ),
                  if (state.activeChapter != null)
                    BlocBuilder<ScriptureQueueCubit, ScriptureQueueState>(
                      bloc: getIt<ScriptureQueueCubit>(),
                      builder: (context, queueState) => queueState.isOpen
                          ? ScriptureQueueBar(queueState: queueState)
                          : BibleBottomBar(
                              state: state,
                              autoScrolling: autoScrolling,
                              autoScrollSpeed: autoSpeed,
                              onToggleAutoScroll: toggleAutoScroll,
                              onSpeedUp: () => changeSpeed(
                                ReaderAutoScrollMixin.autoSpeedStep,
                              ),
                              onSpeedDown: () => changeSpeed(
                                -ReaderAutoScrollMixin.autoSpeedStep,
                              ),
                              onPrevious: () => cubit.navigateChapter(-1),
                              onNext: () => cubit.navigateChapter(1),
                              onPickChapter: () =>
                                  pickChapterAction(context, state),
                              onQuickOptions: () =>
                                  showReaderOptionsSheet(context),
                            ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
