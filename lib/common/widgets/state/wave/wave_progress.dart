// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'wave.dart';

class WaveProgressIndicator extends ProgressIndicator {
  final double? borderWidth;

  final Color? borderColor;

  final Widget? center;

  final Axis direction;

  WaveProgressIndicator({
    Key? key,
    double value = 0.5,
    Color? backgroundColor,
    Animation<Color>? valueColor,
    this.borderWidth,
    this.borderColor,
    this.center,
    this.direction = Axis.vertical,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
        ) {
    if (borderWidth != null && borderColor == null ||
        borderColor != null && borderWidth == null) {
      throw ArgumentError("borderWidth and borderColor should both be set.");
    }
  }

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).colorScheme.secondary;

  @override
  State<StatefulWidget> createState() =>
      _LiquidCircularProgressIndicatorState();
}

class _LiquidCircularProgressIndicatorState
    extends State<WaveProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Wave(
          value: widget.value,
          color: widget._getValueColor(context),
          direction: widget.direction,
        ),
        if (widget.center != null) Center(child: widget.center),
      ],
    );
  }
}
