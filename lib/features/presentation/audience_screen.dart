import 'package:flutter/material.dart';

import '../../core/di/injectable.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/theme/theme_data.dart';
import '../../domain/repos/pref_repo.dart';
import 'presentation_controller.dart';

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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListenableBuilder(
        listenable: Listenable.merge([p.session, p.index, p.blackout]),
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
            builder: (context, box) =>
                session.slide(p.index.value, box.maxHeight),
          );
        },
      ),
    );
  }
}

class VerseSlide extends StatelessWidget {
  const VerseSlide({
    super.key,
    required this.header,
    required this.text,
    required this.height,
  });

  final String header;
  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    final gap = height * 0.06;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: gap),
          child: Text(
            header,
            style: TextStyle(
              fontSize: height * 0.05,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primary,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Padding(
              padding: EdgeInsets.all(gap),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: box.maxWidth - 2 * gap,
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: height * 0.08,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
