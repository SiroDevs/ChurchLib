import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../home/main/shell/shell_nav_item.dart';
import 'audience_screen.dart';
import 'presentation_controller.dart';

class PresentationToggle extends StatelessWidget {
  const PresentationToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    return ListenableBuilder(
      listenable: presentation,
      builder: (context, _) => ShellNavItem(
        presentation.active ? Icons.cancel_presentation : Icons.present_to_all,
        presentation.active ? 'Stop presenting' : 'Start Presenting',
        onPressed: presentation.toggle,
      ),
    );
  }
}

class PresentationPanel extends StatelessWidget {
  const PresentationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final p = PresentationController.instance;
    final size = p.previewSize;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: scheme.secondaryContainer,
          elevation: 0,
          child: Text(
            'PRESENTATION PREVIEW',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ).constrained(minHeight: 25).center().padding(all: 20),
        ),
        AspectRatio(
          aspectRatio: size.width / size.height,
          child: FittedBox(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: const AudienceCanvas(),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous',
                onPressed: () => p.select(p.index.value - 1),
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                tooltip: 'Next',
                onPressed: () => p.select(p.index.value + 1),
                icon: const Icon(Icons.arrow_downward),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: p.blackout,
                builder: (context, dark, _) => IconButton(
                  tooltip: dark ? 'Show screen' : 'Blackout',
                  onPressed: p.toggleBlackout,
                  icon: Icon(dark ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              IconButton(
                tooltip: 'Stop presenting',
                onPressed: p.toggle,
                icon: const Icon(Icons.cancel_presentation),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([p.session, p.index]),
            builder: (context, _) {
              final session = p.session.value;
              if (session == null) return const SizedBox.shrink();
              return _SessionList(session: session, active: p.index.value);
            },
          ),
        ),
      ],
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.session, required this.active});

  final PresentationSession session;
  final int active;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final gray = Colors.grey.withValues(alpha: 0.45);
    BoxDecoration box(bool on, double radius) => BoxDecoration(
      color: on ? gray : null,
      border: Border.all(color: outline),
      borderRadius: BorderRadius.circular(radius),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            itemCount: session.labels.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, i) => InkWell(
              onTap: () => PresentationController.instance.select(i),
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(minWidth: 32),
                decoration: box(i == active, 6),
                child: Text(session.labels[i]),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            itemCount: session.items.length,
            itemBuilder: (context, i) => InkWell(
              onTap: () => PresentationController.instance.select(i),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.all(8),
                decoration: box(i == active, 10),
                child: Text(
                  session.items[i],
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
