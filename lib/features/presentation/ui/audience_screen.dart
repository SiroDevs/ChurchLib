import 'package:flutter/material.dart';

import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_colors.dart';
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
      color: Theme.of(context).scaffoldBackgroundColor,
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

class VerseSlide extends StatelessWidget {
  const VerseSlide({
    super.key,
    required this.header,
    required this.text,
    required this.height,
    required this.style,
  });

  final String header;
  final String text;
  final double height;
  final PresentationStyle style;

  @override
  Widget build(BuildContext context) {
    final gap = height * 0.06;
    final centered = style.align == TextAlign.center;
    final alignment = centered ? Alignment.center : Alignment.centerLeft;
    return Padding(
      padding: EdgeInsets.all(gap),
      child: Column(
        children: [
          Align(
            alignment: alignment,
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
              builder: (context, box) => Center(
                child: SizedBox(
                  width: box.maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: alignment,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: style.align == TextAlign.justify
                            ? box.maxWidth
                            : 0,
                        maxWidth: box.maxWidth,
                      ),
                      child: Text(
                        text,
                        textAlign: style.align,
                        style: TextStyle(
                          fontSize: height * 0.08 * style.scale,
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
      ),
    );
  }
}
