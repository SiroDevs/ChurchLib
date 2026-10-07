// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../../../common/navigator/route_names.dart';
import '../../../../../../common/utils/reader_utils.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../cubit/bible_reader_cubit.dart';
import '../dialogs/export.dart';

class BibleTitleBar extends StatelessWidget {
  final BibleReaderState state;
  const BibleTitleBar({super.key, required this.state});

  Future<void> _pickBible(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final result = await showBiblePicker(
      context,
      bibles: state.savedBibles,
      activeAbbr: state.activeBibleAbbr,
    );
    if (result == null || !context.mounted) return;
    if (result == bibleManageResult) {
      context.pushNamed(RouteNames.bibles);
    } else {
      cubit.setPrimaryBible(result);
    }
  }

  Future<void> _pickChapter(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final chapter = await showChapterPicker(
      context,
      bookName: state.activeBook?.name ?? '',
      chapters: state.chapters,
      activeChapterId: state.activeChapter?.id,
    );
    if (chapter != null) cubit.selectChapter(chapter);
  }

  Future<void> _chooseBook(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final book = await showBookPicker(
      context,
      books: state.books,
      activeBookId: state.activeBook?.id,
    );
    if (book != null) cubit.selectBook(book);
  }

  Future<void> _openScripture(BuildContext context) async {
    final cubit = context.read<BibleReaderCubit>();
    final target = await context.pushNamed<ReaderTarget>(
      RouteNames.scriptureOpener,
      extra: (bibleAbbr: state.activeBibleAbbr, bibleName: state.activeBible),
    );
    if (target != null) await cubit.openTarget(target);
  }

  Future<void> _openOptions(BuildContext context) async {
    final action = await showReaderOptionsSheet(context);
    if (action == null || !context.mounted) return;
    switch (action) {
      case ReaderSheetAction.chooseBook:
        await _chooseBook(context);
      case ReaderSheetAction.manageBibles:
        context.pushNamed(RouteNames.bibles);
      case ReaderSheetAction.openScripture:
        await _openScripture(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BibleReaderCubit>();
    final abbr = state.activeBibleAbbr.toUpperCase();
    final bibleLabel = state.activeBible.isEmpty
        ? '…'
        : (abbr.isEmpty ? state.activeBible : '$abbr: ${state.activeBible}');
    final chapterLabel = state.activeChapter?.reference ?? '';

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PickerButton(
                label: bibleLabel,
                tooltip: 'Switch Bible',
                onTap: state.savedBibles.isEmpty
                    ? null
                    : () => _pickBible(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PickerButton(
                label: chapterLabel,
                tooltip: 'Pick chapter',
                icon: Icons.menu_book_outlined,
                bold: true,
                onTap: state.chapters.isEmpty
                    ? null
                    : () => _pickChapter(context),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Smaller text',
            onPressed: state.fontSize <= readerMinFontSize
                ? null
                : () => cubit.setFontSize(state.fontSize - 2),
            icon: const _AaIcon(plus: false),
          ),
          IconButton(
            tooltip: 'Larger text',
            onPressed: state.fontSize >= readerMaxFontSize
                ? null
                : () => cubit.setFontSize(state.fontSize + 2),
            icon: const _AaIcon(plus: true),
          ),
          IconButton(
            tooltip: 'Options',
            onPressed: () => _openOptions(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.icon,
    this.bold = false,
  });

  final String label;
  final String tooltip;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        );
    return Tooltip(
      message: label.isEmpty ? tooltip : '$tooltip · $label',
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class _AaIcon extends StatelessWidget {
  const _AaIcon({required this.plus});
  final bool plus;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Aa',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          plus ? '+' : '-',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
