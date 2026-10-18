// Flutter imports:
import 'package:flutter/material.dart';

/// Light sweep that runs across a pill while it is downloading.
class PillShimmer extends StatelessWidget {
  const PillShimmer({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Align(
        alignment: Alignment(-2.4 + 4.8 * animation.value, 0),
        child: FractionallySizedBox(
          widthFactor: 0.4,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
