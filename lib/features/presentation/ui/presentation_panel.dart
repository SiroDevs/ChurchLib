import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../common/widgets/app_intents.dart';
import '../../../core/theme/theme_data.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../song/presentor/utils/presentor_shortcuts.dart';
import '../controller/presentation_controller.dart';
import 'audience_frame_capture.dart';
import 'audience_screen.dart';
import 'presentation_toolbar.dart';
import 'session_grid.dart';

class PresentationPanel extends StatefulWidget {
  const PresentationPanel({super.key});

  @override
  State<PresentationPanel> createState() => _PresentationPanelState();
}

class _PresentationPanelState extends State<PresentationPanel> {
  final _focusNode = FocusNode();
  final _presentation = PresentationController.instance;
  late final _frameCapture =
      AudienceFrameCapture(_presentation.sendAudienceFrame);
  late final _frameChanges = Listenable.merge([
    _presentation,
    _presentation.session,
    _presentation.activeSlideIndex,
    _presentation.blackout,
    _presentation.scale,
    _presentation.align,
  ]);
  bool _captureScheduled = false;
  bool _captureRunning = false;
  bool _captureDirty = false;

  late final _shortcuts = _buildShortcuts();

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    final shortcuts = Map<ShortcutActivator, Intent>.of(presentorShortcuts)
      ..remove(const SingleActivator(LogicalKeyboardKey.arrowLeft))
      ..remove(const SingleActivator(LogicalKeyboardKey.arrowRight));
    shortcuts[const SingleActivator(LogicalKeyboardKey.arrowLeft)] =
        const PreviousIntent();
    shortcuts[const SingleActivator(LogicalKeyboardKey.arrowRight)] =
        const NextIntent();
    return shortcuts;
  }

  @override
  void initState() {
    super.initState();
    _presentation.session.addListener(_refocus);
    _frameChanges.addListener(_queuePreviewFrame);
    _refocus();
    _queuePreviewFrame();
  }

  @override
  void dispose() {
    _presentation.session.removeListener(_refocus);
    _frameChanges.removeListener(_queuePreviewFrame);
    _frameCapture.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _refocus() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _focusNode.requestFocus();
  });

  void _queuePreviewFrame() {
    if (!_presentation.needsAudienceFrameStream) return;
    _captureDirty = true;
    if (_captureScheduled || _captureRunning) return;
    _captureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureScheduled = false;
      if (mounted) _capturePreview();
    });
  }

  Future<void> _capturePreview() async {
    _captureRunning = true;
    do {
      _captureDirty = false;
      await _sendPreviewFrame();
    } while (_captureDirty && mounted);
    _captureRunning = false;
  }

  Future<void> _sendPreviewFrame() async {
    await _frameCapture.capture();
  }

  void _jumpToLabel(String label, {bool last = false}) {
    final labels = _presentation.session.value?.labels ?? const <String>[];
    final target = last ? labels.length - 1 : labels.indexOf(label);
    if (target >= 0) _presentation.select(target);
  }

  Map<Type, Action<Intent>> get _actions => {
    NextIntent: CallbackAction<NextIntent>(
      onInvoke: (_) =>
          _presentation.select(_presentation.activeSlideIndex.value + 1),
    ),
    PreviousIntent: CallbackAction<PreviousIntent>(
      onInvoke: (_) =>
          _presentation.select(_presentation.activeSlideIndex.value - 1),
    ),
    SmallerFontIntent: CallbackAction<SmallerFontIntent>(
      onInvoke: (_) => _presentation.resize(-0.1),
    ),
    BiggerFontIntent: CallbackAction<BiggerFontIntent>(
      onInvoke: (_) => _presentation.resize(0.1),
    ),
    SlideNumberIntent: CallbackAction<SlideNumberIntent>(
      onInvoke: (intent) => _jumpToLabel('${intent.slideNumber}'),
    ),
    SlideLetterIntent: CallbackAction<SlideLetterIntent>(
      onInvoke: (intent) =>
          _jumpToLabel(intent.letter, last: intent.letter == 'L'),
    ),
    CloseIntent: CallbackAction<CloseIntent>(
      onInvoke: (_) => _presentation.stop(byUser: true),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final size = _presentation.previewSize;
    final theme = AppTheme.presentationTheme();
    final l10n = AppLocalizations.of(context)!;
    const line = BorderSide(color: Colors.white24);
    return Theme(
      data: theme,
      child: Listener(
        onPointerDown: (_) => _focusNode.requestFocus(),
        child: Focus(
          focusNode: _focusNode,
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
                        l10n.presentationPreview,
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
                            child: RepaintBoundary(
                              key: _frameCapture.boundaryKey,
                              child: const AudienceCanvas(),
                            ),
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
                        listenable: Listenable.merge([
                          _presentation.session,
                          _presentation.activeSlideIndex,
                        ]),
                        builder: (context, _) {
                          final session = _presentation.session.value;
                          if (session == null) return const SizedBox.shrink();
                          return SessionGrid(
                            session: session,
                            active: _presentation.activeSlideIndex.value,
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
