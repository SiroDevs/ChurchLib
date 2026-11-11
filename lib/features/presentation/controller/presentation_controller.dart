// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/_window.dart' as fw;
import 'package:nativeapi_flutter/nativeapi_flutter.dart';
import 'package:nativeapi_flutter/windowing.dart';

import 'audience_stream.dart';
import 'presentation_platform.dart';
import 'presentation_session.dart';

export 'presentation_session.dart';

class _CloseDelegate with fw.RegularWindowControllerDelegate {
  _CloseDelegate(this.onClose);

  final VoidCallback onClose;

  @override
  void onWindowCloseRequested(fw.RegularWindowController controller) =>
      onClose();
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
  AudienceStream? _audienceStream;
  bool _active = false;
  bool _autoStart = true;
  bool _initialized = false;
  String? _windowTitle;
  int _audienceLaunchId = 0;
  bool _audienceOpening = false;

  bool get active => _active;

  bool get needsAudienceFrameStream => usesLinuxAudienceProcess;

  fw.RegularWindowController? get windowController => _window;

  bool get _supportsDisplays => supportsPresentationDisplays;

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
      if (_window == null && _audienceStream == null && !_audienceOpening) {
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
    if (usesLinuxAudienceProcess) {
      if (_audienceStream != null || _audienceOpening) return;
      _openLinuxAudience(displays.first.position);
      return;
    }
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

  Future<void> _openLinuxAudience(Offset position) async {
    final launchId = ++_audienceLaunchId;
    _audienceOpening = true;
    try {
      final stream = await AudienceStream.open(position: position);
      if (launchId != _audienceLaunchId || !_active) {
        stream.close();
        return;
      }
      _audienceStream = stream;
      notifyListeners();
    } catch (error) {
      debugPrint('Could not open the Linux audience window: $error');
    } finally {
      if (launchId == _audienceLaunchId) _audienceOpening = false;
    }
  }

  void sendAudienceFrame(Uint8List frame) => _audienceStream?.send(frame);

  void _closeWindow() {
    _audienceLaunchId++;
    _audienceOpening = false;
    _audienceStream?.close();
    _audienceStream = null;
    final controller = _window;
    if (controller == null) {
      notifyListeners();
      return;
    }
    _window = null;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.destroy());
  }
}
