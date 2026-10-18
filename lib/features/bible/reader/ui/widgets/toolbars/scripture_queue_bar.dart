// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../core/di/injectable.dart';
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../data/models/bible/scripture_item.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../../scripture/queue/bloc/scripture_queue_cubit.dart';
import '../../../bloc/bible_reader_cubit.dart';

class ScriptureQueueBar extends StatefulWidget {
  final ScriptureQueueState queueState;
  const ScriptureQueueBar({super.key, required this.queueState});

  @override
  State<ScriptureQueueBar> createState() => _ScriptureQueueBarState();
}

class _ScriptureQueueBarState extends State<ScriptureQueueBar> {
  final GlobalKey _activeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollToActive();
  }

  @override
  void didUpdateWidget(covariant ScriptureQueueBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.queueState.activeIndex != widget.queueState.activeIndex) {
      _scrollToActive();
    }
  }

  void _scrollToActive() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _activeKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

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
    final items = widget.queueState.items;
    final index = widget.queueState.activeIndex;
    final hasPrev = index > 0;
    final hasNext = index >= 0 && index < items.length - 1;

    return Material(
      color: ThemeColors.primary.withValues(alpha: 0.12),
      elevation: 2,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Close Scripture Queue',
            onPressed: () => getIt<ScriptureQueueCubit>().dismiss(),
            icon: const Icon(Icons.close),
          ),
          IconButton(
            tooltip: 'Previous Scripture',
            onPressed: hasPrev ? () => _open(context, items[index - 1]) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Center(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(5),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 5),
                itemBuilder: (context, i) {
                  final item = items[i];
                  final isActive = i == index;
                  return Center(
                    child: _QueueItem(
                      key: isActive ? _activeKey : ValueKey(item.id ?? i),
                      text: item.reference,
                      isActive: isActive,
                      onPressed: () => _open(context, item),
                    ),
                  );
                },
              ),
            ),
          ).expanded(),
          IconButton(
            tooltip: 'Next Scripture',
            onPressed: hasNext ? () => _open(context, items[index + 1]) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ).padding(horizontal: 8, vertical: 4),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const _QueueItem({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: isActive ? ThemeColors.primary : ThemeColors.accent,
      highlightColor: Colors.white.withValues(alpha: .1),
      hoverColor: isActive ? ThemeColors.primary : ThemeColors.accent1,
      focusElevation: 0,
      hoverElevation: 1,
      highlightElevation: 0,
      elevation: 3,
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 18 : 10,
        vertical: isActive ? 10 : 5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
          fontSize: isActive ? 18 : 14,
          color: isActive ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
