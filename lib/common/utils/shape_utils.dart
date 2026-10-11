import 'package:flutter/material.dart';

RoundedRectangleBorder outlinedShape(ColorScheme scheme, BorderRadius radius) {
  return RoundedRectangleBorder(
    borderRadius: radius,
    side: BorderSide(color: scheme.outlineVariant),
  );
}
