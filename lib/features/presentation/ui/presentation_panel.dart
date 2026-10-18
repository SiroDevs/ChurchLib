import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../common/widgets/app_intents.dart';
import '../../song/presentor/utils/presentor_shortcuts.dart';
import '../controller/presentation_controller.dart';
import 'audience_screen.dart';
import 'presentation_theme.dart';
import 'presentation_toolbar.dart';
import 'session_grid.dart';

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
    p.session.addListener(_refocus);
    _refocus();
  }

  @override
  void dispose() {
    p.session.removeListener(_refocus);
    _focus.dispose();
    super.dispose();
  }

  /// Keys go to the preview, so it takes focus whenever something is shown.
  void _refocus() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _focus.requestFocus();
  });

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

  @override
  Widget build(BuildContext context) {
    final size = p.previewSize;
    final theme = presentationTheme(context);
    const line = BorderSide(color: Colors.white24);
    return Theme(
      data: theme,
      child: Listener(
        onPointerDown: (_) => _focus.requestFocus(),
        child: Focus(
          focusNode: _focus,
          autofocus: true,
          child: Shortcuts(
            shortcuts: _shortcuts,
            child: Actions(
              actions: _actions,
              child: ColoredBox(
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        border: Border(bottom: line),
                      ),
                      child: Text(
                        'PRESENTATION PREVIEW',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ).constrained(minHeight: 25).center().padding(all: 20),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: AspectRatio(
                        aspectRatio: size.width / size.height,
                        child: FittedBox(
                          child: SizedBox(
                            width: size.width,
                            height: size.height,
                            child: const AudienceCanvas(),
                          ),
                        ),
                      ),
                    ).padding(all: 5),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(top: line, bottom: line),
                      ),
                      child: PresentationToolbar(),
                    ),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: Listenable.merge([p.session, p.index]),
                        builder: (context, _) {
                          final session = p.session.value;
                          if (session == null) return const SizedBox.shrink();
                          return SessionGrid(
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
        ),
      ),
    );
  }
}
