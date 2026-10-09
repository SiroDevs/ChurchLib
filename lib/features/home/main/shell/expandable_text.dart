// Flutter imports:
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text, {super.key, this.style, this.tooltip});

  final String text;
  final TextStyle? style;
  final String? tooltip;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  bool _overflows(BuildContext context, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: widget.style ?? DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final overflow = painter.didExceedMaxLines;
    painter.dispose();
    return overflow;
  }

  @override
  void didUpdateWidget(ExpandableText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final overflows = _overflows(context, box.maxWidth - 24);
        final text = Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : 1,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          softWrap: _expanded,
        );
        if (!overflows) return text;
        return Tooltip(
          message: widget.tooltip ?? (_expanded ? 'Collapse' : 'Expand'),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: text),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                ],
              ),
          ),
        );
      },
    );
  }
}
