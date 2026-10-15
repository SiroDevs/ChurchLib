// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../core/theme/theme_colors.dart';

Color inputForeColor(bool? isLight) =>
    isLight == true ? Colors.white : ThemeColors.primary;

TextStyle inputTextStyle(Color color) =>
    TextStyle(fontSize: 18, color: color);

OutlineInputBorder inputOutline(double radius, Color color) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color),
    );

InputDecoration outlinedInputDecoration({
  required Color color,
  required double radius,
  String? label,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool isDense = false,
  EdgeInsetsGeometry? contentPadding,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelStyle: TextStyle(fontSize: 16, color: color),
    isDense: isDense,
    contentPadding: contentPadding,
    enabledBorder: inputOutline(radius, color),
    focusedBorder: inputOutline(radius, color),
  );
}

RoundedRectangleBorder outlinedShape(ColorScheme scheme, BorderRadius radius) {
  return RoundedRectangleBorder(
    borderRadius: radius,
    side: BorderSide(color: scheme.outlineVariant),
  );
}

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
