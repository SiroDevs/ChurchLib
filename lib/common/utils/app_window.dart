import 'package:nativeapi_flutter/nativeapi_flutter.dart';

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
  }
}
