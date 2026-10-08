// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../cubit/bible_reader_cubit.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final chapter = state.activeChapter!;
    final idx = state.chapters.indexWhere((c) => c.id == chapter.id);
    final hasPrev = idx > 0;
    final hasNext = idx >= 0 && idx < state.chapters.length - 1;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.secondaryContainer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _autoScrollControls(),
                ),
              ),
              _BarButton(
                icon: Icons.chevron_left,
                label: 'Previous',
                tooltip: 'Previous chapter (Alt + ←)',
                onTap: hasPrev ? onPrevious : null,
              ),
              const SizedBox(width: 4),
              _BarButton(
                icon: Icons.menu_book_outlined,
                label: 'Chapter ${chapter.number}',
                tooltip: 'Pick chapter',
                onTap: state.chapters.isEmpty ? null : onPickChapter,
                highlighted: true,
              ),
              const SizedBox(width: 4),
              _BarButton(
                icon: Icons.chevron_right,
                label: 'Next',
                tooltip: 'Next chapter (Alt + →)',
                onTap: hasNext ? onNext : null,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _BarButton(
                    icon: Icons.tune,
                    label: 'Quick Options',
                    tooltip: 'Quick Options',
                    onTap: onQuickOptions,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _autoScrollControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        _BarButton(
          icon: autoScrolling
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
          label: autoScrolling ? 'Stop scroll' : 'Auto scroll',
          tooltip: autoScrolling ? 'Stop auto scroll' : 'Start auto scroll',
          onTap: onToggleAutoScroll,
          highlighted: autoScrolling,
        ),
        if (autoScrolling) ...[
          IconButton(
            tooltip: 'Slower',
            visualDensity: VisualDensity.compact,
            onPressed: onSpeedDown,
            icon: const Icon(Icons.remove, size: 18),
          ),
          Text('${autoScrollSpeed.toStringAsFixed(2)}x'),
          IconButton(
            tooltip: 'Faster',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          ),
        ),
      ),
    );
  }
}
