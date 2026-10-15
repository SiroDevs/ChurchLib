// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

mixin ReaderAutoScrollMixin<T extends StatefulWidget> on State<T> {
  ScrollController get scrollController;

  static const autoTick = Duration(milliseconds: 16);
  static const autoPixelsPerTick = 2.5;
  static const autoMinSpeed = 0.25;
  static const autoMaxSpeed = 4.0;
  static const autoSpeedStep = 0.25;
  Timer? autoScrollTimer;
  bool autoScrolling = false;
  double autoSpeed = autoMinSpeed;

  void toggleAutoScroll() =>
      autoScrolling ? stopAutoScroll() : startAutoScroll();

  void startAutoScroll() {
    autoScrollTimer?.cancel();
    setState(() => autoScrolling = true);
    autoScrollTimer = Timer.periodic(autoTick, (_) {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent) {
        stopAutoScroll();
        return;
      }
      scrollController.jumpTo(
        math.min(
          pos.maxScrollExtent,
          pos.pixels + autoPixelsPerTick * autoSpeed,
        ),
      );
    });
  }

  void stopAutoScroll() {
    autoScrollTimer?.cancel();
    autoScrollTimer = null;
    if (mounted && autoScrolling) setState(() => autoScrolling = false);
  }

  void changeSpeed(double delta) => setState(
    () => autoSpeed = (autoSpeed + delta).clamp(autoMinSpeed, autoMaxSpeed),
  );

  void disposeAutoScroll() => autoScrollTimer?.cancel();
}
