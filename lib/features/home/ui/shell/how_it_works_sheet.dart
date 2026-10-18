// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import 'app_module.dart';
import 'how_it_works_content.dart';

Future<void> showHowItWorks(BuildContext context, AppModule module) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: AnimationStyle.noAnimation,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 760),
    builder: (_) => _HowItWorksSheet(module: module),
  );
}

class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet({required this.module});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final entries = howItWorksFor(module);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .8,
      minChildSize: .4,
      maxChildSize: .95,
      builder: (context, controller) => Column(
        children: [
          Row(
            children: [
              Image.asset(module.icon, width: 28, height: 28),
              const SizedBox(width: 12),
              Text(
                'How ${module.label} works',
                style: text.titleLarge,
              )
                  .expanded(),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          )
              .padding(left: 20, top: 16, right: 8, bottom: 4),
          const Divider(height: 1),
          ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (var i = 0; i < entries.length; i++)
                ExpansionTile(
                  initiallyExpanded: i == 0,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    entries[i].title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(entries[i].body, style: text.bodyLarge)],
                ),
            ],
          )
              .expanded(),
        ],
      ),
    );
  }
}
