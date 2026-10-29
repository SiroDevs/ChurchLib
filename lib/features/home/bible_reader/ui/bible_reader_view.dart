// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/utils/display/app_window.dart';
import '../../../../common/utils/reader/reader_prefs_utils.dart';
import '../../../../common/widgets/app_intents.dart';
import '../../../../common/widgets/presentor/presentation_scaffold.dart';
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../bible/scripture/scripture_queue/cubit/scripture_queue_cubit.dart';
import '../../main/shell/app_module.dart';
import '../../main/shell/app_shell.dart';
import '../../main/shell/module_focus.dart';
import '../cubit/bible_reader_cubit.dart';
import 'widgets/dialogs/reader_options_sheet.dart';
import 'widgets/toolbars/export.dart';
import 'widgets/verses/reader_auto_scroll.dart';
import 'widgets/verses/reader_body.dart';
import 'widgets/verses/reader_scroll.dart';

/// How far one press of the Up / Down arrow scrolls the chapter.
const double _arrowScrollStep = 90;

class BiblerReaderView extends StatefulWidget {
  const BiblerReaderView({super.key});

  @override
  State<BiblerReaderView> createState() => BiblerReaderViewState();
}

class BiblerReaderViewState extends State<BiblerReaderView>
    with ReaderAutoScrollMixin, ReaderScrollMixin {
  @override
  final scrollController = ScrollController();

  final _contentKey = GlobalKey();

  @override
  void dispose() {
    disposeAutoScroll();
    disposeScrollReport();
    scrollController.dispose();
    super.dispose();
  }

  void _changeFontSize(BibleReaderCubit cubit, int delta) {
    final current = cubit.state.fontSize;
    final next = clampReaderFontSize(current + delta);
    if (next != current) cubit.setFontSize(next);
  }

  void _onEscape(BibleReaderCubit cubit) {
    if (cubit.state.isSelectionMode) {
      cubit.clearSelection();
    } else if (AppWindow.fullScreen.value) {
      AppWindow.setFullScreen(false);
    }
  }

  void _onStateChanged(BuildContext context, BibleReaderState state) {
    stopAutoScroll();
    final target = state.restoreVerseId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (target != null) {
        scrollToVerse(target);
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
            _onEscape(cubit),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            scrollBy(_arrowScrollStep),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            scrollBy(-_arrowScrollStep),
        for (final key in smallerFontKeys) key: () => _changeFontSize(cubit, -2),
        for (final key in biggerFontKeys) key: () => _changeFontSize(cubit, 2),
      },
      child: ModuleFocus(
        module: AppModule.biblelib,
        child: BlocConsumer<BibleReaderCubit, BibleReaderState>(
          listenWhen: (p, c) =>
              p.activeChapter?.id != c.activeChapter?.id ||
              (!identical(p.verses, c.verses) && c.restoreVerseId != null),
          listener: _onStateChanged,
          builder: (context, state) {
            return ValueListenableBuilder<bool>(
              valueListenable: AppWindow.fullScreen,
              builder: (context, presenting, _) =>
                  _screen(context, cubit, state, presenting),
            );
          },
        ),
      ),
    );
  }

  Widget _screen(
    BuildContext context,
    BibleReaderCubit cubit,
    BibleReaderState state,
    bool presenting,
  ) {
    final content = KeyedSubtree(
      key: _contentKey,
      child: Column(
        children: [
          if (state.isLoading && state.verses.isNotEmpty)
            LinearProgressIndicator(
              minHeight: 2,
              color: presenting ? Colors.white : ThemeColors.primary,
            ),
          Listener(
            onPointerDown: (_) => stopAutoScroll(),
            child: ColoredBox(
              color: presenting || Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              child: ReaderBody(
                state: state,
                scrollController: scrollController,
                viewportKey: viewportKey,
                keyFor: keyFor,
                onScrollEnd: scheduleScrollReport,
                presenting: presenting,
              ),
            ),
          ).expanded(),
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
                      onSpeedUp: () =>
                          changeSpeed(ReaderAutoScrollMixin.autoSpeedStep),
                      onSpeedDown: () =>
                          changeSpeed(-ReaderAutoScrollMixin.autoSpeedStep),
                      onPrevious: () => cubit.navigateChapter(-1),
                      onNext: () => cubit.navigateChapter(1),
                      onPickChapter: () => pickChapterAction(context, state),
                      onQuickOptions: () => showReaderOptionsSheet(context),
                      presenting: presenting,
                      onSmallerFont: () => _changeFontSize(cubit, -2),
                      onBiggerFont: () => _changeFontSize(cubit, 2),
                    ),
            ),
        ],
      ),
    );

    if (presenting) {
      return PresentationScaffold(
        title: [
          state.activeChapter?.reference ?? '',
          state.activeBible,
        ].where((part) => part.isNotEmpty).join(' • '),
        onBack: () => AppWindow.setFullScreen(false),
        body: content,
      );
    }
    return AppShell(
      module: AppModule.biblelib,
      sidebarItems: bibleSidebarItems(context),
      titleBar: state.isSelectionMode
          ? SelectionBar(state: state)
          : BibleTitleBar(state: state),
      body: content,
    );
  }
}
