// Flutter imports:
import 'package:flutter/material.dart';

List<TextSpan> highlightSpans(
  String text,
  TextStyle base,
  TextStyle hit,
  String? query,
) {
  final q = query?.trim() ?? '';
  if (q.isEmpty) return [TextSpan(text: text, style: base)];
  final lower = text.toLowerCase();
  final lq = q.toLowerCase();
  final spans = <TextSpan>[];
  var start = 0;
  while (true) {
    final i = lower.indexOf(lq, start);
    if (i < 0) break;
    if (i > start) {
      spans.add(TextSpan(text: text.substring(start, i), style: base));
    }
    spans.add(TextSpan(text: text.substring(i, i + lq.length), style: hit));
    start = i + lq.length;
  }
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start), style: base));
  }
  return spans;
}
