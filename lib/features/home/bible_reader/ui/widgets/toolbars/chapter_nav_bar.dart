// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../cubit/bible_reader_cubit.dart';

class ChapterNavBar extends StatelessWidget {
  final BibleReaderState state;
  const ChapterNavBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BibleReaderCubit>();
    final idx = state.chapters.indexWhere((c) => c.id == state.activeChapter!.id);
    final hasPrev = idx > 0;
    final hasNext = idx >= 0 && idx < state.chapters.length - 1;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: hasPrev ? () => cubit.navigateChapter(-1) : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
            Text(
              state.activeChapter!.reference,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: hasNext ? () => cubit.navigateChapter(1) : null,
              icon: const Icon(Icons.chevron_right),
              iconAlignment: IconAlignment.end,
              label: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
