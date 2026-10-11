import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

class ScriptureActionButtons extends StatelessWidget {
  const ScriptureActionButtons({
    super.key,
    required this.reference,
    required this.onOpenScripture,
    required this.onAddToQueue,
    required this.onAddToQueueAndClose,
    required this.onAddToQueueAndFinish,
  });

  final String reference;
  final VoidCallback onOpenScripture;
  final VoidCallback onAddToQueue;
  final VoidCallback onAddToQueueAndClose;
  final VoidCallback onAddToQueueAndFinish;

  @override
  Widget build(BuildContext context) {
    Widget outlined(IconData icon, String label, VoidCallback onTap) =>
        OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        )
            .expanded();

    return Column(
      children: [
        FilledButton.icon(
          onPressed: onOpenScripture,
          icon: const Icon(Icons.menu_book),
          label: Text(
            'Open Scripture · $reference',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
            .width(double.infinity),
        const SizedBox(height: 8),
        Row(children: [outlined(Icons.playlist_add, 'Add to Queue', onAddToQueue)]),
        const SizedBox(height: 8),
        Row(
          children: [
            outlined(Icons.close, 'Queue & Close', onAddToQueueAndClose),
            const SizedBox(width: 8),
            outlined(Icons.done, 'Queue & Finish', onAddToQueueAndFinish),
          ],
        ),
      ],
    )
        .padding(top: 10);
  }
}
