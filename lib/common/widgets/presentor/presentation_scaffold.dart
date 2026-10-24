// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/theme/theme_data.dart';

class PresentationScaffold extends StatelessWidget {
  const PresentationScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.endPanel,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final List<Widget> actions;
  final Widget body;
  final Widget? endPanel;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.presentationTheme(),
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  _Header(
                    title: title,
                    subtitle: subtitle,
                    onBack: onBack,
                    actions: actions,
                  ),
                  Divider(height: 1, color: scheme.outlineVariant),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: body),
                        ?endPanel,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.actions,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final titleSize = (MediaQuery.sizeOf(context).height * 0.05).clamp(
      28.0,
      64.0,
    );
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return IconButtonTheme(
      data: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: Colors.white),
      ),
      child: SizedBox(
        height: titleSize * (hasSubtitle ? 2.2 : 1.5) + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Side padding keeps the title clear of the buttons.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 240),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (hasSubtitle)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize * 0.62,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  tooltip: 'Back (Esc)',
                  iconSize: 30,
                  onPressed: onBack,
                  icon: const Icon(Icons.fullscreen_exit),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
