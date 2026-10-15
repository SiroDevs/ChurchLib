// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_title, style: const TextStyle(fontSize: 18))
            .padding(bottom: 16),
        _children,
      ],
    )
        .padding(all: 16)
        .card()
        .width(double.infinity)
        .padding(left: 8, right: 8, top: 8);
  }
}
