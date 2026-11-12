import 'package:flutter/material.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

import '../../../core/theme/theme_data.dart';
import '../controller/presentation_controller.dart';

class AudienceWindow extends StatefulWidget {
  const AudienceWindow({super.key});

  @override
  State<AudienceWindow> createState() => _AudienceWindowState();
}

class _AudienceWindowState extends State<AudienceWindow> with WindowListener {
  @override
  Future<bool> onWindowClose() async {
    final viewId = currentId;
    if (viewId != null) {
      PresentationController.instance.onAudienceWindowClosed(viewId);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) =>
      Theme(data: AppTheme.presentationTheme(), child: const AudienceCanvas());
}

class AudienceCanvas extends StatelessWidget {
  const AudienceCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    return Material(
      color: Colors.black,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          presentation.session,
          presentation.activeSlideIndex,
          presentation.blackout,
          presentation.scale,
          presentation.align,
        ]),
        builder: (context, _) {
          final session = presentation.session.value;
          if (presentation.blackout.value || session == null) {
            return const ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) => session.slide(
              presentation.activeSlideIndex.value,
              constraints.maxHeight,
              PresentationStyle(
                presentation.scale.value,
                presentation.align.value,
              ),
            ),
          );
        },
      ),
    );
  }
}
