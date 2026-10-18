// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../controller/presentation_controller.dart';

/// Grid of clickable slide cards for the running presentation.
class SessionGrid extends StatelessWidget {
  const SessionGrid({required this.session, required this.active});

  final PresentationSession session;
  final int active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ).padding(horizontal: 14, top: 10),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 96,
          ),
          padding: const EdgeInsets.all(8),
          itemCount: session.items.length,
          itemBuilder: (context, i) => InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => PresentationController.instance.select(i),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: i == active ? Colors.grey.withValues(alpha: 0.45) : null,
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.labels[i],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    session.items[i].split('\n').take(2).join('\n'),
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ).expanded(),
      ],
    );
  }
}
