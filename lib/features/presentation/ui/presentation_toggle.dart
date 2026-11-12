import 'dart:async';

import 'package:flutter/material.dart';

import '../../home/main/shell/app_module.dart';
import '../../home/main/shell/shell_nav_item.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../controller/presentation_controller.dart';

class PresentationToggle extends StatelessWidget {
  const PresentationToggle({
    super.key,
    required this.module,
    this.onPresent,
    this.iconOnly = false,
    this.enabled = true,
  });

  final AppModule module;
  final FutureOr<void> Function()? onPresent;
  final bool iconOnly;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    final l10n = AppLocalizations.of(context)!;
    final kind = module == AppModule.biblelib
        ? PresentationKind.bible
        : PresentationKind.song;
    return ListenableBuilder(
      listenable: presentation,
      builder: (context, _) {
        final isCurrentSource =
            presentation.active &&
            presentation.hasExtendedDisplay &&
            presentation.session.value?.kind == kind;
        final label = isCurrentSource
            ? l10n.presentationStop
            : kind == PresentationKind.bible
            ? l10n.presentationPresentBible
            : l10n.presentationStart;
        final onPressed = enabled || isCurrentSource
            ? () async {
                if (isCurrentSource) {
                  presentation.stop();
                  return;
                }
                await onPresent?.call();
              }
            : null;
        if (iconOnly) {
          return IconButton(
            tooltip: label,
            onPressed: onPressed,
            icon: Icon(isCurrentSource ? Icons.close : Icons.present_to_all),
          );
        }
        return ShellNavItem(
          isCurrentSource ? Icons.cancel_presentation : Icons.present_to_all,
          label,
          onPressed: onPressed,
        );
      },
    );
  }
}
