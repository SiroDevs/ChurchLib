import 'package:nativeapi_flutter/nativeapi_flutter.dart';

/// Desktop window setup/control, backed by `nativeapi_flutter`.
///
/// `maximize()` and `setFullScreen()` aren't in nativeapi's documented
/// quick-start (only `show()`, `center()`, `titleBarStyle` and
/// `isAlwaysOnTop` are confirmed there) — the package is pre-1.0 and
/// still changing, so check these two first if the app fails to build.
class AppWindow {
  AppWindow._();

  static Window? get _current => WindowManager.instance.getCurrent();

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
    // await _current?.setFullScreen(value);
  }
}
