import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../controller/presentation_controller.dart';

class PresentationToolbar extends StatelessWidget {
  const PresentationToolbar({super.key});

  static IconData _alignIcon(TextAlign align) => switch (align) {
    TextAlign.center => Icons.format_align_center,
    TextAlign.right => Icons.format_align_right,
    _ => Icons.format_align_left,
  };

  static String _alignLabel(AppLocalizations l10n, TextAlign align) =>
      switch (align) {
        TextAlign.center => l10n.presentationCenter,
        TextAlign.right => l10n.presentationRight,
        _ => l10n.presentationLeft,
      };

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge([presentation.blackout, presentation.align]),
      builder: (context, _) => Material(
        color: scheme.secondaryContainer,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            _PresentationButton(
              icon: Icons.arrow_upward,
              label: l10n.presentationPrevious,
              tooltip: l10n.presentationPreviousTooltip,
              onPressed: () =>
                  presentation.select(presentation.activeSlideIndex.value - 1),
            ),
            _PresentationButton(
              icon: Icons.arrow_downward,
              label: l10n.presentationNext,
              tooltip: l10n.presentationNextTooltip,
              onPressed: () =>
                  presentation.select(presentation.activeSlideIndex.value + 1),
            ),
            _PresentationButton(
              icon: Icons.text_decrease,
              label: l10n.presentationSmaller,
              tooltip: l10n.presentationSmallerTooltip,
              onPressed: () => presentation.resize(-0.1),
            ),
            _PresentationButton(
              icon: Icons.text_increase,
              label: l10n.presentationLarger,
              tooltip: l10n.presentationLargerTooltip,
              onPressed: () => presentation.resize(0.1),
            ),
            _PresentationButton(
              icon: _alignIcon(presentation.align.value),
              label: _alignLabel(l10n, presentation.align.value),
              tooltip: l10n.presentationAlign,
              onPressed: presentation.cycleAlign,
            ),
            _PresentationButton(
              icon: presentation.blackout.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              label: presentation.blackout.value
                  ? l10n.presentationShow
                  : l10n.presentationBlackout,
              tooltip: l10n.presentationBlackoutTooltip,
              onPressed: presentation.toggleBlackout,
              selected: presentation.blackout.value,
            ),
            _PresentationButton(
              icon: Icons.cancel_presentation,
              label: l10n.presentationStopAction,
              tooltip: l10n.presentationStopTooltip,
              onPressed: () => presentation.stop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresentationButton extends StatelessWidget {
  const _PresentationButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.white : null,
      ),
    ),
  );
}
