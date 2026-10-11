import 'package:flutter/material.dart';

import '../../core/theme/theme_colors.dart';

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
