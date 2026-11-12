// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:multiview_desktop/multiview_desktop.dart';

class AppWindow {
  AppWindow._();

  static MultiViewDesktop? get _current {
    try {
      return MultiViewDesktop.main;
    } catch (_) {
      return null;
    }
  }

  static final ValueNotifier<bool> fullScreen = ValueNotifier<bool>(false);

  static void showMaximized() {
    final window = _current;
    if (window == null) return;
    window.show();
    window.maximize();
  }

  static Future<void> show() async {
    final window = _current;
    if (window == null) return;
    window.show();
  }

  static Future<void> setFullScreen(bool value) async {
    final window = _current;
    if (window == null) return;
    window.setFullScreen(value);
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

  static Future<void> toggleFullScreen() async {
    final window = _current;
    if (window == null) return;
    final value = !window.isFullScreen();
    window.setFullScreen(value);
    _publish(value);
  }
}
