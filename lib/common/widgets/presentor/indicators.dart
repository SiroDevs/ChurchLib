// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../core/theme/theme_colors.dart';
import '../../utils/theme/shape_utils.dart';

class PresentorIndicator extends StatelessWidget {
  final double? width;
  final double? left;
  final double? right;
  final Animation<double> animation;

  const PresentorIndicator({
    super.key,
    required this.width,
    required this.left,
    required this.right,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return elasticIndicator(
      animation: animation,
      color: ThemeColors.bgColorAccent(context),
      width: width,
      left: left,
      right: right,
      margin: const EdgeInsets.all(2),
    );
  }
}

class IndicatorItem extends StatelessWidget {
  final double? width;
  final Widget? child;
  final AlignmentGeometry alignment;
  final Function()? onTap;
  final bool? isSelected;

  const IndicatorItem({
    super.key,
    required this.width,
    required this.child,
    required this.alignment,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isSelected!
              ? Colors.transparent
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
          width: 1.5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      alignment: alignment,
      child: child,
    )
        .gestures(onTap: onTap);
  }
}
