// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../utils/display/font_utils.dart';

class SliderContent extends StatelessWidget {
  final String lyrics;

  /// The size the text would like to be; it shrinks only if it can't fit.
  final double fontSize;

  /// Every stanza of the song. The size is worked out so the longest of them
  /// fits, which keeps the text the same size from slide to slide.
  final List<String> fitWith;

  /// Told the size the text is actually drawn at.
  final ValueChanged<double>? onFontFit;
  final Function()? onDoubleTap;
  final Function()? onLongPress;

  const SliderContent({
    super.key,
    required this.lyrics,
    required this.fontSize,
    this.fitWith = const [],
    this.onFontFit,
    this.onDoubleTap,
    this.onLongPress,
  });

  static const double _hPad = 20, _vPad = 10;

  static String _display(String text) => text.replaceAll("#", "\n");

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      child: LayoutBuilder(
        builder: (context, box) {
          final style = DefaultTextStyle.of(
            context,
          ).style.copyWith(fontWeight: FontWeight.bold);
          final width = max(0.0, box.maxWidth - 2 * _hPad);
          final height = max(0.0, box.maxHeight - 2 * _vPad);
          final size = fitFontSize(
            texts: (fitWith.isEmpty ? [lyrics] : fitWith).map(_display),
            style: style,
            maxFontSize: fontSize,
            maxWidth: width,
            maxHeight: height,
            textScaler: MediaQuery.textScalerOf(context),
          );
          if (onFontFit != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => onFontFit!(size),
            );
          }

          // FittedBox is a safety net: the size above already fits, but if a
          // font measures slightly differently the text shrinks, never spills.
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: Text(
                _display(lyrics),
                style: style.copyWith(fontSize: size),
              ),
            ),
          ).padding(horizontal: _hPad, vertical: _vPad).center();
        },
      ),
    )
        .padding(all: 10)
        .gestures(
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
        );
  }
}

class SliderNumbers extends StatelessWidget {
  final String label;
  final double fontSize;

  const SliderNumbers({
    super.key,
    required this.label,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 25,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      )
          .center(),
    );
  }
}
