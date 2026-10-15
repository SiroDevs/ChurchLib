// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

class SliderContent extends StatelessWidget {
  final String lyrics;
  final double fontSize;
  final Function()? onDoubleTap;
  final Function()? onLongPress;

  const SliderContent({
    super.key,
    required this.lyrics,
    required this.fontSize,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) { 
    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      child: Text(
        lyrics.replaceAll("#", "\n"),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      )
          .padding(horizontal: 20, vertical: 10)
          .center(),
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
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      )
          .center(),
    );
  }
}
