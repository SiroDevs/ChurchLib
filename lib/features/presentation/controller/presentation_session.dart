import 'package:flutter/material.dart';

class PresentationStyle {
  const PresentationStyle(this.scale, this.align);

  final double scale;
  final TextAlign align;
}

enum PresentationKind { song, bible }

class PresentationSession {
  const PresentationSession({
    required this.kind,
    required this.title,
    required this.labels,
    required this.items,
    required this.slide,
  });

  final PresentationKind kind;
  final String title;
  final List<String> labels;
  final List<String> items;
  final Widget Function(
    int slideIndex,
    double screenHeight,
    PresentationStyle style,
  )
  slide;
}
