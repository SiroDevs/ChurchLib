// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../common/utils/reader/reader_utils.dart';
import '../../../cubit/bible_reader_cubit.dart';
import 'reader_actions.dart';

class BibleTitleBar extends StatelessWidget {
  final BibleReaderState state;
  const BibleTitleBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BibleReaderCubit>();
    final language = state.activeBibleLanguageLabel;
    final bibleLabel = state.activeBible.isEmpty
        ? '…'
        : (language.isEmpty
              ? state.activeBible
              : '$language: ${state.activeBible}');
    final chapterLabel = state.activeChapter?.reference ?? '';

    return Row(
      children: [
        _PickerButton(
          label: bibleLabel,
          tooltip: 'Switch Your Primary Bible',
          onTap: state.savedBibles.isEmpty
              ? null
              : () => pickBibleAction(context, state),
        ),
        const SizedBox(width: 8),
        _PickerButton(
          label: chapterLabel,
          tooltip: 'Pick a Bible Boook',
          icon: Icons.menu_book_outlined,
          bold: true,
          onTap: state.chapters.isEmpty
              ? null
              : () => chooseBookAction(context, state),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: state.activeChapter == null
              ? null
              : () => openScriptureAction(context, state),
          icon: const Icon(Icons.auto_stories_outlined, size: 20),
          label: const Text('Scripture Opener'),
        ),
        IconButton(
          tooltip: 'Smaller text (-)',
          onPressed: state.fontSize <= readerMinFontSize
              ? null
              : () => cubit.setFontSize(state.fontSize - 2),
          icon: const AaIcon(plus: false),
        ),
        IconButton(
          tooltip: 'Larger text (=)',
          onPressed: state.fontSize >= readerMaxFontSize
              ? null
              : () => cubit.setFontSize(state.fontSize + 2),
          icon: const AaIcon(plus: true),
        ),
      ],
    ).padding(left: 12, right: 6);
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
    final style = Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: bold ? FontWeight.w700 : FontWeight.w600);
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
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ).flexible(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class AaIcon extends StatelessWidget {
  const AaIcon({super.key, required this.plus});
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
