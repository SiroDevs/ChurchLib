// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../bloc/scripture_opener_cubit.dart';

class LockedScriptureRow extends StatelessWidget {
  const LockedScriptureRow({super.key, required this.row});

  final ScriptureSearchRowState row;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.onSecondaryContainer;
    return Row(
      children: [
        Icon(Icons.check_circle, color: color),
        const SizedBox(width: 10),
        Text(
          row.reference,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        )
            .flexible(),
        const SizedBox(width: 6),
        Text(
          'Added to queue',
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.75)),
        ),
      ],
    )
        .padding(horizontal: 14, vertical: 12)
        .decorated(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10),
        )
        .padding(vertical: 4);
  }
}
