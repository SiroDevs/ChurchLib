// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

CustomTransitionPage<T> centerRevealPage<T>({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 900),
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondary, child) {
      final reveal = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return AnimatedBuilder(
        animation: reveal,
        child: child,
        builder: (context, child) {
          final t = reveal.value;
          return ClipPath(
            clipper: _CircleRevealClipper(t),
            child: Opacity(
              opacity: Curves.easeOut.transform(t.clamp(0.0, 1.0)),
              child: Transform.scale(
                scale: 0.92 + 0.08 * t,
                alignment: Alignment.center,
                child: child,
              ),
            ),
          );
        },
      );
    },
  );
}

class _CircleRevealClipper extends CustomClipper<Path> {
  const _CircleRevealClipper(this.fraction);
  final double fraction;

  @override
  Path getClip(Size size) {
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    return Path()
      ..addOval(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: maxRadius * fraction,
        ),
      );
  }

  @override
  bool shouldReclip(_CircleRevealClipper old) => old.fraction != fraction;
}
