import 'dart:async';

import 'package:flutter/material.dart';

import '../../home/ui/shell/shell_nav_item.dart';
import '../controller/presentation_controller.dart';

/// Sidebar item that starts or stops presenting.
class PresentationToggle extends StatelessWidget {
  const PresentationToggle({super.key, this.onPresent});

  final FutureOr<void> Function()? onPresent;

  @override
  Widget build(BuildContext context) {
    final p = PresentationController.instance;
    return ListenableBuilder(
      listenable: p,
      builder: (context, _) => ShellNavItem(
        p.active ? Icons.cancel_presentation : Icons.present_to_all,
        p.active ? 'Stop presenting' : 'Start Presenting',
        onPressed: () async {
          if (p.active) {
            p.stop(byUser: true);
            return;
          }
          await onPresent?.call();
          if (!p.active) p.start();
        },
      ),
    );
  }
}
