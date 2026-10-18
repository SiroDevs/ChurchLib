// ignore_for_file: invalid_use_of_internal_member, implementation_imports

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/_window.dart' as fw;

// Package imports:
import 'package:nativeapi_flutter/nativeapi_flutter.dart';
import 'package:nativeapi_flutter/windowing.dart';

// Project imports:
import '../ui/audience_screen.dart';

class _CloseDelegate with fw.RegularWindowControllerDelegate {
  _CloseDelegate(this.onClose);
  final VoidCallback onClose;

  @override
  void onWindowCloseRequested(fw.RegularWindowController c) => onClose();
}

class PresentationStyle {
  const PresentationStyle(this.scale, this.align);

  final double scale;
  final TextAlign align;
}

class PresentationSession {
  const PresentationSession({
    required this.title,
    required this.labels,
    required this.items,
    required this.slide,
  });

  final String title;
  final List<String> labels;
  final List<String> items;
  final Widget Function(int index, double height, PresentationStyle style)
  slide;
}

class PresentationController extends ChangeNotifier {
  PresentationController._();
  static final instance = PresentationController._();

  final session = ValueNotifier<PresentationSession?>(null);
  final index = ValueNotifier<int>(0);
  final blackout = ValueNotifier<bool>(false);
  final scale = ValueNotifier<double>(1);
  final align = ValueNotifier<TextAlign>(TextAlign.left);
  fw.RegularWindowController? _window;
  bool _active = false;
  bool _autoStart = true;

  bool get active => _active;

  bool get _hasSecondDisplay =>
      DisplayManager.instance.getAll().any((d) => !d.isPrimary);

  void init() {
    DisplayManager.instance.addListener((event) {
      if (event is DisplayAddedEvent && _autoStart) start();
      if (event is DisplayRemovedEvent && !_hasSecondDisplay) _closeWindow();
    });
    if (_hasSecondDisplay) start();
  }

  Size get previewSize {
    final targets = DisplayManager.instance.getAll().where((d) => !d.isPrimary);
    if (targets.isEmpty) return const Size(1920, 1080);
    return Size(targets.first.size.width, targets.first.size.height);
  }

  void present(PresentationSession next, {int at = 0}) {
    session.value = next;
    index.value = at;
    blackout.value = false;
    start();
  }

  void select(int i) {
    final count = session.value?.items.length ?? 0;
    if (i >= 0 && i < count) index.value = i;
  }

  void toggleBlackout() => blackout.value = !blackout.value;

  void resize(double delta) =>
      scale.value = (scale.value + delta).clamp(0.5, 2.0).toDouble();

  void cycleAlign() => align.value = switch (align.value) {
    TextAlign.left => TextAlign.center,
    TextAlign.center => TextAlign.justify,
    _ => TextAlign.left,
  };

  void toggle() => _active ? stop(byUser: true) : start();

  void start() {
    _autoStart = true;
    _active = true;
    _openWindow();
    notifyListeners();
  }

  void stop({bool byUser = false}) {
    if (byUser) _autoStart = false;
    _active = false;
    _closeWindow();
    notifyListeners();
  }

  void _openWindow() {
    final targets = DisplayManager.instance.getAll().where((d) => !d.isPrimary);
    if (_window != null || targets.isEmpty) return;
    if (Platform.isMacOS) {
      debugPrint('Audience window skipped: the macOS runner has no multi-window support yet.');
      return;
    }
    _window = fw.RegularWindowController(
      size: const Size(960, 540),
      title: 'ChurchLib · Audience',
      delegate: _CloseDelegate(_closeWindow),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      final controller = _window;
      final window = controller == null ? null : nativeWindowOf(controller);
      if (window == null) return;
      window.position = targets.first.position;
      window.isFullScreen = true;
    });
  }

  void _closeWindow() {
    final window = _window;
    if (window == null) return;
    _window = null;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => window.destroy());
  }
}

class PresentationHost extends StatelessWidget {
  const PresentationHost({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    return ListenableBuilder(
      listenable: presentation,
      child: child,
      builder: (context, child) {
        final window = presentation._window;
        return ViewAnchor(
          view: window == null
              ? null
              : fw.RegularWindow(
                  controller: window,
                  child: const AudienceWindow(),
                ),
          child: child!,
        );
      },
    );
  }
}
