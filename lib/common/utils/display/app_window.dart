// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:nativeapi_flutter/nativeapi_flutter.dart';

class AppWindow {
  AppWindow._();

  static Window? get _current => WindowManager.instance.getCurrent();

  /// Whether the main window is full screen right now. BibleLib's sidebar
  /// listens to this to collapse, and the full screen buttons swap their icon.
  static final ValueNotifier<bool> fullScreen = ValueNotifier<bool>(false);

  static Future<void> showMaximized() async {
    final window = _current;
    if (window == null) return;
    window.titleBarStyle = TitleBarStyle.normal;
    window.maximize();
    window.show();
  }

  static Future<void> show() async {
    final window = _current;
    if (window == null) return;
    window.titleBarStyle = TitleBarStyle.normal;
    window.show();
  }

  static Future<void> setFullScreen(bool value) async {
    final window = _current;
    if (window == null) return;
    window.isFullScreen = value;
    _publish(value);
  }

  /// Callers such as a screen's initState or dispose run while the framework
  /// is building, and listeners must not be notified then (setState during
  /// build). Outside a frame it updates at once; inside one, right after it.
  static void _publish(bool value) {
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.idle) {
      fullScreen.value = value;
    } else {
      binding.addPostFrameCallback((_) => fullScreen.value = value);
    }
  }

  /// F11 and the full screen buttons. Starts from what the window says, so it
  /// stays right when the system left full screen by itself.
  static Future<void> toggleFullScreen() async {
    final window = _current;
    if (window == null) return;
    await setFullScreen(!window.isFullScreen);
  }
}
