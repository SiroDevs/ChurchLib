// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../../core/di/injectable.dart';
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../data/models/bible/scripture_item.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../../../bible/scripture/scripture_queue/cubit/scripture_queue_cubit.dart';
import '../../../cubit/bible_reader_cubit.dart';

class ScriptureQueueBar extends StatelessWidget {
  final ScriptureQueueState queueState;
  const ScriptureQueueBar({super.key, required this.queueState});

  void _open(BuildContext context, ScriptureItem item) {
    getIt<ScriptureQueueCubit>().setActiveItem(item.id!);
    context.read<BibleReaderCubit>().openTarget(
          ReaderTarget(
            bibleAbbr: item.bibleAbbr,
            bookId: item.bookId,
            chapterId: item.chapterId,
            verseId: item.verseId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final items = queueState.items;
    final index = queueState.activeIndex;
    final hasPrev = index > 0;
    final hasNext = index >= 0 && index < items.length - 1;
    final current = queueState.activeItem;

    return Material(
      color: ThemeColors.primary.withValues(alpha: 0.12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Close queue',
              onPressed: () => getIt<ScriptureQueueCubit>().dismiss(),
              icon: const Icon(Icons.close),
            ),
            IconButton(
              tooltip: 'Previous',
              onPressed: hasPrev ? () => _open(context, items[index - 1]) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current?.reference ?? queueState.listName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (index >= 0)
                    Text(
                      '${index + 1} of ${items.length} · ${queueState.listName}',
                      style: const TextStyle(fontSize: 11, color: ThemeColors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Next',
              onPressed: hasNext ? () => _open(context, items[index + 1]) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
