import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

Widget elasticIndicator({
  required Animation<double> animation,
  required Color color,
  double? width,
  double? left,
  double? right,
  EdgeInsetsGeometry? margin,
}) {
  return ScaleTransition(
    scale: Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animation, curve: Curves.elasticOut),
    ),
    child: Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    ),
  )
      .positioned(
        top: 2,
        bottom: 2,
        width: width,
        left: left,
        right: right,
      );
}
