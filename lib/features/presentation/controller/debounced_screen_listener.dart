import 'dart:async';

import 'package:multiview_desktop/multiview_desktop.dart';

mixin DebouncedScreenListener on ScreenListener {
  static const _settleDelay = Duration(milliseconds: 400);

  Timer? _settleTimer;

  void onScreenChanged();

  @override
  void onScreenEvent(String eventName) {
    _settleTimer?.cancel();
    _settleTimer = Timer(_settleDelay, onScreenChanged);
  }
}
