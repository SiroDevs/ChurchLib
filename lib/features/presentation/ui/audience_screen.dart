import 'package:flutter/material.dart';

import '../../../core/theme/theme_data.dart';
import '../controller/presentation_controller.dart';

class AudienceWindow extends StatelessWidget {
  const AudienceWindow({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.presentationTheme(),
    home: const AudienceCanvas(),
  );
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
