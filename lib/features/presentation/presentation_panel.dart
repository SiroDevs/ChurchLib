import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../common/widgets/app_intents.dart';
import '../home/bible_reader/ui/widgets/toolbars/bible_bottom_bar.dart';
import '../home/main/shell/shell_nav_item.dart';
import '../song/presentor/utils/presentor_shortcuts.dart';
import 'audience_screen.dart';
import 'presentation_controller.dart';

class PresentationToggle extends StatelessWidget {
  const PresentationToggle({super.key, this.onPresent});

  final FutureOr<void> Function()? onPresent;

  @override
  Widget build(BuildContext context) {
    final p = PresentationController.instance;
    return ListenableBuilder(
      listenable: p,
      builder: (context, _) => ShellNavItem(
        p.active ? Icons.cancel_presentation : Icons.present_to_all,
        p.active ? 'Stop presenting' : 'Start Presenting',
        onPressed: () async {
          if (p.active) {
            p.stop(byUser: true);
            return;
          }
          await onPresent?.call();
          if (!p.active) p.start();
        },
      ),
    );
  }
}

class PresentationPanel extends StatefulWidget {
  const PresentationPanel({super.key});

  @override
  State<PresentationPanel> createState() => _PresentationPanelState();
}

class _PresentationPanelState extends State<PresentationPanel> {
  final _focus = FocusNode();
  final p = PresentationController.instance;

  late final _shortcuts = <ShortcutActivator, Intent>{
    ...presentorShortcuts,
    const SingleActivator(LogicalKeyboardKey.arrowLeft): const PreviousIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowRight): const NextIntent(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _jumpToLabel(String label, {bool last = false}) {
    final labels = p.session.value?.labels ?? const <String>[];
    final at = last ? labels.length - 1 : labels.indexOf(label);
    if (at >= 0) p.select(at);
  }

  Map<Type, Action<Intent>> get _actions => {
    NextIntent: CallbackAction<NextIntent>(
      onInvoke: (_) => p.select(p.index.value + 1),
    ),
    PreviousIntent: CallbackAction<PreviousIntent>(
      onInvoke: (_) => p.select(p.index.value - 1),
    ),
    SmallerFontIntent: CallbackAction<SmallerFontIntent>(
      onInvoke: (_) => p.resize(-0.1),
    ),
    BiggerFontIntent: CallbackAction<BiggerFontIntent>(
      onInvoke: (_) => p.resize(0.1),
    ),
    SlideNumberIntent: CallbackAction<SlideNumberIntent>(
      onInvoke: (i) => p.select(i.slideNumber - 1),
    ),
    SlideLetterIntent: CallbackAction<SlideLetterIntent>(
      onInvoke: (i) => _jumpToLabel(i.letter, last: i.letter == 'L'),
    ),
    CloseIntent: CallbackAction<CloseIntent>(
      onInvoke: (_) => p.stop(byUser: true),
    ),
  };

  IconData _alignIcon(TextAlign align) => switch (align) {
    TextAlign.center => Icons.format_align_center,
    TextAlign.justify => Icons.format_align_justify,
    _ => Icons.format_align_left,
  };

  String _alignLabel(TextAlign align) => switch (align) {
    TextAlign.center => 'Center',
    TextAlign.justify => 'Justify',
    _ => 'Left',
  };

  Widget _toolbar(ColorScheme scheme) => ListenableBuilder(
    listenable: Listenable.merge([p.blackout, p.align]),
    builder: (context, _) => Material(
      color: scheme.secondaryContainer,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          BarButton(
            icon: Icons.arrow_upward,
            label: 'Previous',
            tooltip: 'Previous (Up)',
            onTap: () => p.select(p.index.value - 1),
          ),
          BarButton(
            icon: Icons.arrow_downward,
            label: 'Next',
            tooltip: 'Next (Down)',
            onTap: () => p.select(p.index.value + 1),
          ),
          BarButton(
            icon: Icons.text_decrease,
            label: 'Smaller',
            tooltip: 'Smaller text (-)',
            onTap: () => p.resize(-0.1),
          ),
          BarButton(
            icon: Icons.text_increase,
            label: 'Bigger',
            tooltip: 'Bigger text (=)',
            onTap: () => p.resize(0.1),
          ),
          BarButton(
            icon: _alignIcon(p.align.value),
            label: _alignLabel(p.align.value),
            tooltip: 'Text alignment',
            onTap: p.cycleAlign,
          ),
          BarButton(
            icon: p.blackout.value ? Icons.visibility : Icons.visibility_off,
            label: p.blackout.value ? 'Show' : 'Blackout',
            tooltip: 'Blackout the screen',
            onTap: p.toggleBlackout,
            highlighted: p.blackout.value,
          ),
          BarButton(
            icon: Icons.cancel_presentation,
            label: 'Stop',
            tooltip: 'Stop presenting (Esc)',
            onTap: () => p.stop(byUser: true),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = p.previewSize;
    final scheme = Theme.of(context).colorScheme;
    return Listener(
      onPointerDown: (_) => _focus.requestFocus(),
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        child: Shortcuts(
          shortcuts: _shortcuts,
          child: Actions(
            actions: _actions,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: scheme.secondaryContainer,
                  elevation: 0,
                  child: Text(
                    'PRESENTATION PREVIEW',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ).constrained(minHeight: 25).center().padding(all: 20),
                ),
                AspectRatio(
                  aspectRatio: size.width / size.height,
                  child: FittedBox(
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: const AudienceCanvas(),
                    ),
                  ),
                ),
                _toolbar(scheme),
                Expanded(
                  child: ListenableBuilder(
                    listenable: Listenable.merge([p.session, p.index]),
                    builder: (context, _) {
                      final session = p.session.value;
                      if (session == null) return const SizedBox.shrink();
                      return _SessionGrid(
                        session: session,
                        active: p.index.value,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionGrid extends StatelessWidget {
  const _SessionGrid({required this.session, required this.active});

  final PresentationSession session;
  final int active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ).padding(horizontal: 14, top: 10),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 96,
          ),
          padding: const EdgeInsets.all(8),
          itemCount: session.items.length,
          itemBuilder: (context, i) => InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => PresentationController.instance.select(i),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: i == active ? Colors.grey.withValues(alpha: 0.45) : null,
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.labels[i],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    session.items[i].split('\n').take(2).join('\n'),
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ).expanded(),
      ],
    );
  }
}
