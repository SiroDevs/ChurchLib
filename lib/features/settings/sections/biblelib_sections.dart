// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../settings/bible_screen/ui/bibles_screen.dart';
import '../settings_actions.dart';
import '../settings_card.dart';

class BiblesSection extends StatelessWidget {
  const BiblesSection({super.key});

  @override
  Widget build(BuildContext context) => const BiblesScreen(embedded: true);
}

class BibleDataSection extends StatelessWidget {
  const BibleDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingCard(
      title: 'BibleLib',
      widgets: [
        ListTile(
          leading: const Icon(Icons.restart_alt),
          title: const Text('Start over with BibleLib'),
          subtitle: const Text(
            'Delete all downloaded Bibles and choose translations again',
          ),
          onTap: SettingsActions(context).resetBibleLib,
        ),
      ],
    );
  }
}
