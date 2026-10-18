import 'package:flutter/material.dart';

import '../../bible/reader/ui/widgets/toolbars/bible_bottom_bar.dart';
import '../controller/presentation_controller.dart';

/// Previous / next, font size, alignment, blackout and stop controls.
class PresentationToolbar extends StatelessWidget {
  const PresentationToolbar({super.key});

  static IconData _alignIcon(TextAlign align) => switch (align) {
    TextAlign.center => Icons.format_align_center,
    TextAlign.right => Icons.format_align_right,
    _ => Icons.format_align_left,
  };

  static String _alignLabel(TextAlign align) => switch (align) {
    TextAlign.center => 'Center',
    TextAlign.right => 'Right',
    _ => 'Left',
  };

  @override
  Widget build(BuildContext context) {
    final p = PresentationController.instance;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge([p.blackout, p.align]),
      builder: (context, _) => Material(
        color: scheme.secondaryContainer,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            BarButton(
              icon: Icons.arrow_upward,
              label: 'Previous',
              tooltip: 'Previous (Up)',
              onTap: () => p.select(p.index.value - 1),
            ),
            BarButton(
              icon: Icons.arrow_downward,
              label: 'Next',
              tooltip: 'Next (Down)',
              onTap: () => p.select(p.index.value + 1),
            ),
            BarButton(
              icon: Icons.text_decrease,
              label: 'Smaller',
              tooltip: 'Smaller text (-)',
              onTap: () => p.resize(-0.1),
            ),
            BarButton(
              icon: Icons.text_increase,
              label: 'Bigger',
              tooltip: 'Bigger text (=)',
              onTap: () => p.resize(0.1),
            ),
            BarButton(
              icon: _alignIcon(p.align.value),
              label: _alignLabel(p.align.value),
              tooltip: 'Text alignment',
              onTap: p.cycleAlign,
            ),
            BarButton(
              icon: p.blackout.value ? Icons.visibility : Icons.visibility_off,
              label: p.blackout.value ? 'Show' : 'Blackout',
              tooltip: 'Blackout the screen',
              onTap: p.toggleBlackout,
              highlighted: p.blackout.value,
            ),
            BarButton(
              icon: Icons.cancel_presentation,
              label: 'Stop',
              tooltip: 'Stop presenting (Esc)',
              onTap: () => p.stop(byUser: true),
            ),
          ],
        ),
      ),
    );
  }
}
