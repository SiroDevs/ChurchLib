// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../l10n/gen/app_localizations.dart';

// Project imports:
import '../../../cubit/bible_reader_cubit.dart';
import 'bible_title_bar.dart' show AaIcon;

class BibleBottomBar extends StatelessWidget {
  final BibleReaderState state;
  final bool autoScrolling;
  final double autoScrollSpeed;
  final VoidCallback onToggleAutoScroll;
  final VoidCallback onSpeedUp;
  final VoidCallback onSpeedDown;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickChapter;
  final VoidCallback onQuickOptions;

  final bool presenting;
  final VoidCallback? onSmallerFont, onBiggerFont;

  const BibleBottomBar({
    super.key,
    required this.state,
    required this.autoScrolling,
    required this.autoScrollSpeed,
    required this.onToggleAutoScroll,
    required this.onSpeedUp,
    required this.onSpeedDown,
    required this.onPrevious,
    required this.onNext,
    required this.onPickChapter,
    required this.onQuickOptions,
    this.presenting = false,
    this.onSmallerFont,
    this.onBiggerFont,
  });

  @override
  Widget build(BuildContext context) {
    final chapter = state.activeChapter!;
    final idx = state.chapters.indexWhere((c) => c.id == chapter.id);
    final hasPrev = idx > 0;
    final hasNext = idx >= 0 && idx < state.chapters.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: scheme.secondaryContainer,
      child:
          Row(
                children: [
                  _autoScrollControls(l10n)
                      .alignment(Alignment.centerLeft)
                      .expanded(),
                  _BarButton(
                    icon: Icons.chevron_left,
                    label: l10n.previousAction,
                    tooltip: l10n.previousChapterTooltip,
                    onTap: hasPrev ? onPrevious : null,
                  ),
                  const SizedBox(width: 4),
                  _BarButton(
                    icon: Icons.menu_book_outlined,
                    label: l10n.chapterNumberLabel(int.parse(chapter.number)),
                    tooltip: l10n.pickChapter,
                    onTap: state.chapters.isEmpty ? null : onPickChapter,
                    highlighted: true,
                  ),
                  const SizedBox(width: 4),
                  _BarButton(
                    icon: Icons.chevron_right,
                    label: l10n.nextAction,
                    tooltip: l10n.nextChapterTooltip,
                    onTap: hasNext ? onNext : null,
                  ),
                  if (presenting)
                    _fontControls(l10n)
                        .alignment(Alignment.centerRight)
                        .expanded()
                  else
                    _BarButton(
                      icon: Icons.tune,
                      label: l10n.quickOptions,
                      tooltip: l10n.quickOptions,
                      onTap: onQuickOptions,
                    ).alignment(Alignment.centerRight).expanded(),
                ],
              )
              .height(64)
              .decorated(
                border: Border(
                  top: BorderSide(
                    color: presenting ? Colors.white : scheme.outlineVariant,
                  ),
                ),
              ),
    );
  }

  Widget _fontControls(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.smallerTextTooltip,
          onPressed: onSmallerFont,
          icon: const AaIcon(plus: false),
        ),
        IconButton(
          tooltip: l10n.largerTextTooltip,
          onPressed: onBiggerFont,
          icon: const AaIcon(plus: true),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _autoScrollControls(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        _BarButton(
          icon: autoScrolling
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
          label: autoScrolling ? l10n.stopScrollAction : l10n.autoScrollAction,
          tooltip: autoScrolling ? l10n.stopAutoScroll : l10n.startAutoScroll,
          onTap: onToggleAutoScroll,
          highlighted: autoScrolling,
        ),
        if (autoScrolling) ...[
          IconButton(
            tooltip: l10n.slower,
            visualDensity: VisualDensity.compact,
            onPressed: onSpeedDown,
            icon: const Icon(Icons.remove, size: 18),
          ),
          Text('${autoScrollSpeed.toStringAsFixed(2)}x'),
          IconButton(
            tooltip: l10n.faster,
            visualDensity: VisualDensity.compact,
            onPressed: onSpeedUp,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ],
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final color = !enabled
        ? scheme.onSurface.withValues(alpha: .35)
        : highlighted
        ? scheme.primary
        : scheme.onSurface;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ).padding(horizontal: 14, vertical: 6),
      ),
    );
  }
}
