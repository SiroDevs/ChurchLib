// Flutter imports:
import 'package:flutter/material.dart';

class SectionHeaderRow extends StatelessWidget {
  const SectionHeaderRow({
    super.key,
    required this.left,
    required this.right,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
  });

  final Widget left;
  final Widget right;
  final EdgeInsets padding;

  static Widget label(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [left, right],
      ),
    );
  }
}
