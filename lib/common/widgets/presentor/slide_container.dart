import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../../core/theme/theme_colors.dart';
import '../../utils/app_util.dart';
import '../../utils/indicator_utils.dart';
import 'indicators.dart';

class SlideContainer extends StatelessWidget {
  final List<Tab>? tabs;
  final int? selectedIndex;
  final TextDirection? direction;
  final IndicatorSide? indicatorSide;
  final double? indicatorWidth;
  final List<AnimationController?>? animationControllers;
  final ValueChanged<int>? onTabSelected;

  const SlideContainer({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.direction,
    required this.indicatorSide,
    required this.indicatorWidth,
    required this.animationControllers,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: tabs!.length,
        itemBuilder: (context, index) {
          Alignment alignment = (direction == TextDirection.rtl)
              ? Alignment.centerRight
              : Alignment.centerLeft;

          double? left = (direction == TextDirection.rtl)
              ? (indicatorSide == IndicatorSide.end ? 0 : null)
              : (indicatorSide == IndicatorSide.start ? 0 : null);
          double? right = (direction == TextDirection.rtl)
              ? (indicatorSide == IndicatorSide.start ? 0 : null)
              : (indicatorSide == IndicatorSide.end ? 0 : null);

          return Stack(
            children: <Widget>[
              TabIndicator(
                width: indicatorWidth!,
                left: left,
                right: right,
                animation: animationControllers![index]!,
              ),
              IndicatorItem(
                width: indicatorWidth,
                alignment: alignment,
                isSelected: selectedIndex == index,
                onTap: () => onTabSelected!(index),
                child: tabs![index].child,
              ),
            ],
          );
        },
      ).height(60),
    );
  }
}

class TabIndicator extends StatelessWidget {
  final double width;
  final double? left, right;
  final AnimationController animation;

  const TabIndicator({
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
      color: ThemeColors.primary2,
      width: width * 1.1,
      left: left,
      right: right,
    );
  }
}
