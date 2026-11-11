// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/_window.dart' as fw;
import 'package:nativeapi_flutter/nativeapi_flutter.dart';
import 'package:nativeapi_flutter/windowing.dart';

import '../../../l10n/gen/app_localizations.dart';
import 'presentation_platform.dart';
import '../ui/audience_screen.dart';

class _CloseDelegate with fw.RegularWindowControllerDelegate {
  _CloseDelegate(this.onClose);

  final VoidCallback onClose;

  @override
  void onWindowCloseRequested(fw.RegularWindowController controller) =>
      onClose();
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
  final Widget Function(
    int slideIndex,
    double screenHeight,
    PresentationStyle style,
  )
  slide;
}

class PresentationController extends ChangeNotifier {
  PresentationController._();

  static final instance = PresentationController._();

  final session = ValueNotifier<PresentationSession?>(null);
  final activeSlideIndex = ValueNotifier<int>(0);
  final blackout = ValueNotifier<bool>(false);
  final scale = ValueNotifier<double>(1);
  final align = ValueNotifier<TextAlign>(TextAlign.left);
  fw.RegularWindowController? _window;
  bool _active = false;
  bool _autoStart = true;
  bool _initialized = false;
  String? _windowTitle;

  bool get active => _active;

  bool get _supportsDisplays => supportsPresentationWindows;

  bool get _hasSecondDisplay => _secondaryDisplays.isNotEmpty;

  Iterable<dynamic> get _secondaryDisplays => _supportsDisplays
      ? DisplayManager.instance
            .getAll()
            .where((display) => !display.isPrimary)
            .toList()
      : const [];

  void init() {
    if (_initialized || !_supportsDisplays) return;
    _initialized = true;
    DisplayManager.instance.addListener(_onDisplayEvent);
    if (_hasSecondDisplay) start();
  }

  void _onDisplayEvent(DisplayEvent event) {
    if (event is DisplayAddedEvent && _autoStart) start();
    if (event is DisplayRemovedEvent && !_hasSecondDisplay) {
      if (_window == null) {
        notifyListeners();
      } else {
        _closeWindow();
      }
    }
    if (event is DisplayChangedEvent) notifyListeners();
  }

  Size get previewSize {
    final displays = _secondaryDisplays;
    if (displays.isEmpty) return const Size(1920, 1080);
    return Size(displays.first.size.width, displays.first.size.height);
  }

  void setWindowTitle(String value) {
    if (_windowTitle == value) return;
    _windowTitle = value;
    final nativeWindow = _window == null ? null : nativeWindowOf(_window!);
    nativeWindow?.title = value;
  }

  void present(PresentationSession next, {int at = 0}) {
    session.value = next;
    activeSlideIndex.value = at;
    blackout.value = false;
    start();
  }

  void select(int slideIndex) {
    final slideCount = session.value?.items.length ?? 0;
    if (slideIndex >= 0 && slideIndex < slideCount) {
      activeSlideIndex.value = slideIndex;
    }
  }

  void toggleBlackout() => blackout.value = !blackout.value;

  void resize(double delta) =>
      scale.value = (scale.value + delta).clamp(0.5, 2.0).toDouble();

  void cycleAlign() => align.value = switch (align.value) {
    TextAlign.left => TextAlign.center,
    TextAlign.center => TextAlign.right,
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
    final displays = _secondaryDisplays;
    if (_window != null || displays.isEmpty) return;
    if (defaultTargetPlatform == TargetPlatform.macOS) return;

    final controller = fw.RegularWindowController(
      size: const Size(960, 540),
      title: _windowTitle,
      delegate: _CloseDelegate(() => stop(byUser: true)),
    );
    _window = controller;
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      final audienceWindow = nativeWindowOf(controller);
      if (audienceWindow == null) return;
      audienceWindow.position = displays.first.position;
      audienceWindow.isFullScreen = true;
    });
  }

  void _closeWindow() {
    final controller = _window;
    if (controller == null) return;
    _window = null;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.destroy());
  }
}

class PresentationHost extends StatelessWidget {
  const PresentationHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    presentation.setWindowTitle(
      AppLocalizations.of(context)!.presentationWindowTitle,
    );
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
