import 'dart:math';

import 'package:flutter/material.dart';

import '../../../common/utils/display/font_utils.dart';
import '../controller/presentation_controller.dart';

class PresentationSlide extends StatelessWidget {
  const PresentationSlide({
    super.key,
    required this.title,
    required this.text,
    required this.fontSize,
    required this.style,
    this.marker,
    this.fitTexts = const [],
  });

  final String title;
  final String text;
  final String? marker;
  final double fontSize;
  final List<String> fitTexts;
  final PresentationStyle style;

  String get _measuredText => marker == null ? text : '$marker  $text';

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final slideHeight = constraints.maxHeight;
      final horizontalPadding = constraints.maxWidth * 0.06;
      final verticalPadding = slideHeight * 0.05;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalPadding,
          horizontalPadding,
          verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: slideHeight * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: slideHeight * 0.02),
            Container(height: 2, color: Colors.white),
            Expanded(child: _body(slideHeight)),
          ],
        ),
      );
    },
  );

  Widget _body(double slideHeight) => LayoutBuilder(
    builder: (context, constraints) {
      final horizontalPadding = constraints.maxWidth * 0.05;
      final verticalPadding = slideHeight * 0.02;
      final availableWidth = max(
        0.0,
        constraints.maxWidth - 2 * horizontalPadding,
      );
      final availableHeight = max(
        0.0,
        constraints.maxHeight - 2 * verticalPadding,
      );
      const baseStyle = TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
      final fittedFontSize = fitFontSize(
        texts: fitTexts.isEmpty ? [_measuredText] : fitTexts,
        style: baseStyle,
        maxFontSize: fontSize,
        maxWidth: availableWidth,
        maxHeight: availableHeight,
        textScaler: TextScaler.noScaling,
      );
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: availableWidth,
              child: Text.rich(
                TextSpan(
                  children: [
                    if (marker != null)
                      TextSpan(
                        text: '$marker  ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white70,
                        ),
                      ),
                    TextSpan(text: text),
                  ],
                ),
                textAlign: style.align,
                style: baseStyle.copyWith(fontSize: fittedFontSize),
              ),
            ),
          ),
        ),
      );
    },
  );
}
