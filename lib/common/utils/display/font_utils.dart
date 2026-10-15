// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../formatting/app_util.dart';

double calcFontSize({
  required double height,
  required String content,
  double lineHeightMultiplier = 1.2,
}) {
  var verses = content.split("##");
  final lineBreakCount = '#'.allMatches(verses[0]).length + 1;
  final availableHeight = height - 275;

  final heightPerLine = availableHeight / lineBreakCount;

  double calculatedFontSize = heightPerLine / lineHeightMultiplier;

  logger('Height: $height');
  logger('Height Per Line: $heightPerLine');
  logger('Line break count: $lineBreakCount');
  logger('Final font size: $calculatedFontSize');

  return calculatedFontSize;
}

double getFontSize(int characters, double height, double width) {
  return sqrt((height * width) / characters);
}

int? _fitKey;
double _fitValue = 0;

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
  if (key == _fitKey) return _fitValue;

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

  _fitKey = key;
  _fitValue = result;
  return result;
}
