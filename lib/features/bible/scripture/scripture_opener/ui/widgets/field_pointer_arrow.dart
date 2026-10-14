import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

const fieldWeights = [13, 10, 10];
const fieldIndexBook = 0;
const fieldIndexChapter = 1;
const fieldIndexVerse = 2;

class FieldPointerArrow extends StatelessWidget {
  const FieldPointerArrow({super.key, required this.fieldIndex});

  final int fieldIndex;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        for (var i = 0; i < fieldWeights.length; i++)
          Center(
            child: i == fieldIndex
                ? Icon(Icons.arrow_drop_up, color: color)
                : const SizedBox(height: 24),
          )
              .expanded(flex: fieldWeights[i]),
      ],
    );
  }
}
