import 'dart:async';

import 'package:flutter/material.dart';

import '../../home/main/shell/shell_nav_item.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controller/presentation_controller.dart';

class PresentationToggle extends StatelessWidget {
  const PresentationToggle({super.key, this.onPresent});

  final FutureOr<void> Function()? onPresent;

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: presentation,
      builder: (context, _) => ShellNavItem(
        presentation.active ? Icons.cancel_presentation : Icons.present_to_all,
        presentation.active ? l10n.presentationStop : l10n.presentationStart,
        onPressed: () async {
          if (presentation.active) {
            presentation.stop(byUser: true);
            return;
          }
          await onPresent?.call();
          if (!presentation.active) presentation.start();
        },
      ),
    );
  }
}
