import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../controller/presentation_controller.dart';

class PresentationHost extends StatelessWidget {
  const PresentationHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    PresentationController.instance.setWindowTitle(
      AppLocalizations.of(context)!.presentationWindowTitle,
    );
    return child;
  }
}
