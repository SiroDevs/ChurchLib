// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../settings/settings_screen.dart';

Future<void> showSettingsWindow(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _SettingsWindow(),
  );
}

class _SettingsWindow extends StatelessWidget {
  const _SettingsWindow();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 720),
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.only(left: 14, right: 4),
              color: scheme.secondaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.settings, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Expanded(child: SettingsScreen(embedded: true)),
          ],
        ),
      ),
    );
  }
}
