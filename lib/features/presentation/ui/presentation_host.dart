// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/_window.dart' as fw;

import '../../../l10n/gen/app_localizations.dart';
import '../controller/presentation_controller.dart';
import 'audience_screen.dart';

class PresentationHost extends StatelessWidget {
  const PresentationHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final presentation = PresentationController.instance;
    presentation.setWindowTitle(
      AppLocalizations.of(context)!.presentationWindowTitle,
    );
    return ListenableBuilder(
      listenable: presentation,
      child: child,
      builder: (context, child) {
        final window = presentation.windowController;
        return ViewAnchor(
          view: window == null
              ? null
              : fw.RegularWindow(
                  controller: window,
                  child: const AudienceWindow(),
                ),
          child: child!,
        );
      },
    );
  }
}
