// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

/// Number of text lines in [text]; stanzas use '#' as a line break, slide
/// items use '\n'.
int lineCountOf(String text) => RegExp(r'[#\n]').allMatches(text).length + 1;

/// Biggest comfortable font size for [lines] lines on a screen [height] tall.
/// Fewer lines get a bigger size, so a short chorus fills the screen.
double calcLinesFontSize({
  required double height,
  required int lines,
  double lineHeightMultiplier = 1.2,
}) {
  final availableHeight = height - 275;
  final heightPerLine = availableHeight / max(1, lines);
  return heightPerLine / lineHeightMultiplier;
}

double calcFontSize({
  required double height,
  required String content,
  double lineHeightMultiplier = 1.2,
}) => calcLinesFontSize(
  height: height,
  lines: lineCountOf(content.split("##")[0]),
  lineHeightMultiplier: lineHeightMultiplier,
);

double getFontSize(int characters, double height, double width) {
  return sqrt((height * width) / characters);
}

// Verses and the chorus are fitted separately, so one slot is not enough.
final Map<int, double> _fitCache = {};

/// Largest font size, never above [maxFontSize], at which every entry of
/// [texts] fits inside [maxWidth] x [maxHeight] when wrapped like a [Text].
///
/// [style] must be the style the text is really drawn with (line height
/// included). Passing every stanza of a song makes the size the same on all
/// slides. Never goes below [minFontSize] unless [maxFontSize] is smaller.
double fitFontSize({
  required Iterable<String> texts,
  required TextStyle style,
  required double maxFontSize,
  required double maxWidth,
  required double maxHeight,
  required TextScaler textScaler,
  TextDirection textDirection = TextDirection.ltr,
  double minFontSize = 10,
}) {
  if (maxFontSize <= minFontSize) return maxFontSize;
  if (!maxWidth.isFinite || !maxHeight.isFinite) return maxFontSize;
  if (maxWidth <= 0 || maxHeight <= 0) return minFontSize;

  final unique = texts.toSet().toList();
  final key = Object.hash(
    Object.hashAll(unique),
    style,
    maxFontSize,
    maxWidth,
    maxHeight,
    textScaler,
    textDirection,
    minFontSize,
  );
  final cached = _fitCache[key];
  if (cached != null) return cached;

  bool fits(double size) {
    for (final text in unique) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style.copyWith(fontSize: size)),
        textDirection: textDirection,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);
      final ok = painter.height <= maxHeight;
      painter.dispose();
      if (!ok) return false;
    }
    return true;
  }

  double result;
  if (fits(maxFontSize)) {
    result = maxFontSize;
  } else if (!fits(minFontSize)) {
    result = minFontSize;
  } else {
    var low = minFontSize, high = maxFontSize;
    while (high - low > 0.5) {
      final mid = (low + high) / 2;
      if (fits(mid)) {
        low = mid;
      } else {
        high = mid;
      }
    }
    result = low;
  }

  if (_fitCache.length > 32) _fitCache.clear();
  _fitCache[key] = result;
  return result;
}
