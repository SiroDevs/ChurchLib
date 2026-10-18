import 'package:flutter/material.dart';

import '../controller/presentation_controller.dart';

/// Grid of clickable slide cards for the running presentation. Each card
/// shows its marker (verse number, 1, C ...) and the text on the same line.
class SessionGrid extends StatelessWidget {
  const SessionGrid({super.key, required this.session, required this.active});

  final PresentationSession session;
  final int active;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 84,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: session.items.length,
      itemBuilder: (context, i) => _Card(
        marker: session.labels[i],
        text: session.items[i],
        selected: i == active,
        onTap: () => PresentationController.instance.select(i),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.marker,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String marker;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(10),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.16) : null,
          border: Border.all(
            color: selected ? Colors.white : Colors.white38,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$marker  ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: text.replaceAll('\n', ' '),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
