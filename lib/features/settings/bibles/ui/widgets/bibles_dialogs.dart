// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../data/models/bible/bible_version.dart';

const biblesManagementInfo =
    'You can add a Bible to the Multi-Bible Reader by hovering over it in '
    '"Other Bibles" and choosing "Set as secondary" — hover over it again '
    'and choose "Remove from secondary" to take it out.\n\n'
    'To delete a Bible from your device entirely, hover over it, choose '
    '"Delete" and confirm.\n\n'
    'Want more Bibles than what\'s shown here? Click "Change Selection" '
    'below to go back to the Bible picker and add (or remove) translations '
    'from your library.';

Future<bool> confirmDeleteBible(BuildContext context, BibleVersion bible) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Remove ${bible.name}?'),
      content: const Text(
        "This deletes all downloaded content for this Bible from your device. "
        "This can't be undone.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('OKAY'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

Future<String?> pickPrimaryBible(
  BuildContext context, {
  required List<BibleVersion> bibles,
  required String current,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Choose primary Bible'),
      content: SizedBox(
        width: 380,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final bible in bibles.where((b) => b.isDownloaded))
              ListTile(
                dense: true,
                leading: Icon(
                  bible.abbreviation == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(bible.name),
                onTap: () => Navigator.pop(context, bible.abbreviation),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> showBiblesInfo(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Managing your Bibles'),
      content: const SingleChildScrollView(child: Text(biblesManagementInfo)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OKAY'),
        ),
      ],
    ),
  );
}

Future<void> showFirstOpenPrompt(BuildContext context) async {
  final show = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Would you like to know how to manage your bibles?'),
      content: const Text(
        'Learn how to add or remove Bibles from the Multi-Bible Reader, and '
        'how to add more translations to your library.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No thanks'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Show me'),
        ),
      ],
    ),
  );
  if (show == true && context.mounted) await showBiblesInfo(context);
}
