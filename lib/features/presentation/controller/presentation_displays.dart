import 'dart:ui';

import 'package:multiview_desktop/multiview_desktop.dart';

import 'presentation_platform.dart';

class PresentationDisplays {
  PresentationDisplays._();

  static List<Display> get extended {
    if (!supportsMultiViewPresentation) return const [];
    try {
      final primary = MultiViewDesktop.screen.primary();
      return MultiViewDesktop.screen
          .all()
          .where(
            (display) =>
                display.id != primary.id &&
                _isExtendedDisplay(primary, display),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Size get previewSize {
    final displays = extended;
    if (displays.isEmpty) return const Size(1920, 1080);
    return displays.first.size;
  }

  static bool _isExtendedDisplay(Display primary, Display display) {
    final usePhysicalBounds =
        primary.physicalBounds != null && display.physicalBounds != null;
    final primaryBounds = usePhysicalBounds
        ? primary.physicalBounds!
        : primary.logicalBounds;
    final displayBounds = usePhysicalBounds
        ? display.physicalBounds!
        : display.logicalBounds;
    if (primaryBounds.isEmpty || displayBounds.isEmpty) return false;

    final overlap = primaryBounds.intersect(displayBounds);
    if (overlap.isEmpty) return true;

    final overlapArea = overlap.width * overlap.height;
    final primaryArea = primaryBounds.width * primaryBounds.height;
    final displayArea = displayBounds.width * displayBounds.height;
    final smallerArea = primaryArea < displayArea ? primaryArea : displayArea;
    return overlapArea < smallerArea * 0.95;
  }
}
