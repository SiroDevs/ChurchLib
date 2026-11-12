// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:skeleton_loader/skeleton_loader.dart';

// Project imports:
import 'skeleton_block.dart';

// Shimmer sized to its parent so each panel animates on its own.
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SkeletonLoader(
        items: 1,
        builder: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: child,
        ),
        baseColor: scheme.surfaceContainerHighest,
        highlightColor: scheme.primary,
        period: const Duration(milliseconds: 1600),
      ),
    );
  }
}

// Centered glyph placeholder inside a fixed-size slot (icon buttons, icons).
class SkeletonIconSlot extends StatelessWidget {
  const SkeletonIconSlot({
    super.key,
    required this.slotSize,
    required this.glyphSize,
  });

  final double slotSize;
  final double glyphSize;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: slotSize,
    height: slotSize,
    child: Center(
      child: SkeletonBlock(width: glyphSize, height: glyphSize, radius: 4),
    ),
  );
}

// One line of text: a block centered in the real line height.
class SkeletonTextLine extends StatelessWidget {
  const SkeletonTextLine({
    super.key,
    required this.lineHeight,
    required this.blockHeight,
    this.widthFactor = 1,
  });

  final double lineHeight;
  final double blockHeight;
  final double widthFactor;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: lineHeight,
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: SkeletonBlock(
          width: double.infinity,
          height: blockHeight,
          radius: 3,
        ),
      ),
    ),
  );
}
