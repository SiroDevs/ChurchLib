import 'package:flutter/material.dart';

import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_data.dart';
import '../../../domain/repos/pref_repo.dart';
import '../controller/presentation_controller.dart';

class AudienceWindow extends StatelessWidget {
  const AudienceWindow({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme(),
    darkTheme: AppTheme.darkTheme(),
    themeMode: getIt<PrefRepo>().getThemeMode(),
    home: const AudienceCanvas(),
  );
}

class AudienceCanvas extends StatelessWidget {
  const AudienceCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final p = PresentationController.instance;
    return Material(
      color: Colors.black,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          p.session,
          p.index,
          p.blackout,
          p.scale,
          p.align,
        ]),
        builder: (context, _) {
          final session = p.session.value;
          if (p.blackout.value) {
            return const ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(),
            );
          }
          if (session == null) return const SizedBox.expand();
          return LayoutBuilder(
            builder: (context, box) => session.slide(
              p.index.value,
              box.maxHeight,
              PresentationStyle(p.scale.value, p.align.value),
            ),
          );
        },
      ),
    );
  }
}
