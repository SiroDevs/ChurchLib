import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../home/main/shell/app_module.dart';
import '../controller/presentation_controller.dart';
import 'presentation_panel.dart';

class PresentationLayout extends StatelessWidget {
  const PresentationLayout({
    super.key,
    required this.child,
    required this.module,
    this.onPresent,
  });

  final Widget child;
  final AppModule module;
  final FutureOr<void> Function()? onPresent;

  Future<void> _present() async {
    final presentation = PresentationController.instance;
    final kind = module == AppModule.biblelib
        ? PresentationKind.bible
        : PresentationKind.song;
    if (presentation.active && presentation.session.value?.kind == kind) {
      return;
    }
    await onPresent?.call();
  }

  bool _isSourceForSession(PresentationSession? session) =>
      session != null &&
      session.kind ==
          (module == AppModule.biblelib
              ? PresentationKind.bible
              : PresentationKind.song);

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {const SingleActivator(LogicalKeyboardKey.f5): _present},
    child: ListenableBuilder(
      listenable: PresentationController.instance,
      child: child,
      builder: (context, content) {
        final presentation = PresentationController.instance;
        return Row(
          children: [
            content!.expanded(flex: 6),
            if (presentation.active &&
                _isSourceForSession(presentation.session.value)) ...[
              VerticalDivider(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const PresentationPanel().expanded(flex: 4),
            ],
          ],
        );
      },
    ),
  );
}
