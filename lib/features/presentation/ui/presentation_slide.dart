import 'dart:math';

import 'package:flutter/material.dart';

import '../../../common/utils/display/font_utils.dart';
import '../controller/presentation_controller.dart';

/// One audience slide, shared by songs and Bible chapters: a centered title
/// with a line under it, then the text, always white on black.
class PresentationSlide extends StatelessWidget {
  const PresentationSlide({
    super.key,
    required this.title,
    required this.text,
    required this.fontSize,
    required this.style,
    this.marker,
    this.fitWith = const [],
  });

  final String title;
  final String text;

  /// Shown in front of [text], e.g. the verse number.
  final String? marker;

  /// The size the text would like to be; it shrinks only if it can't fit.
  final double fontSize;

  /// Every text of the session, so all slides get the same size.
  final List<String> fitWith;
  final PresentationStyle style;

  String get _measured => marker == null ? text : '$marker  $text';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        final padX = box.maxWidth * 0.06;
        final padY = h * 0.05;
        return Padding(
          padding: EdgeInsets.fromLTRB(padX, padY, padX, padY),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: h * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: h * 0.02),
              Container(height: 2, color: Colors.white),
              Expanded(child: _body(h)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(double slideHeight) {
    return LayoutBuilder(
      builder: (context, box) {
        // Horizontal padding keeps left / right aligned text off the edges.
        final hPad = box.maxWidth * 0.05;
        final vPad = slideHeight * 0.02;
        final width = max(0.0, box.maxWidth - 2 * hPad);
        final height = max(0.0, box.maxHeight - 2 * vPad);
        const base = TextStyle(fontWeight: FontWeight.w600, color: Colors.white);
        final size = fitFontSize(
          texts: fitWith.isEmpty ? [_measured] : fitWith,
          style: base,
          maxFontSize: fontSize,
          maxWidth: width,
          maxHeight: height,
          textScaler: TextScaler.noScaling,
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Center(
            // Safety net: the size above fits, but if a font measures a bit
            // differently the text shrinks instead of spilling.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: width,
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
                  style: base.copyWith(fontSize: size),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
