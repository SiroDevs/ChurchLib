// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../data/models/bible/bible_version.dart';
import '../../../../../../l10n/gen/app_localizations.dart';

Future<bool> confirmDeleteBible(
  BuildContext context,
  BibleVersion bible,
) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.removeBibleQuestion(bible.name)),
      content: Text(l10n.deleteBibleMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.okay),
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
  final l10n = AppLocalizations.of(context)!;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.choosePrimaryBible),
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
          child: Text(l10n.closeAction),
        ),
      ],
    ),
  );
}

Future<void> showBiblesInfo(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.managingBibles),
      content: SingleChildScrollView(child: Text(l10n.bibleManagementInfo)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.okay),
        ),
      ],
    ),
  );
}

Future<void> showFirstOpenPrompt(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final show = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.bibleManagementQuestion),
      content: Text(l10n.bibleManagementPrompt),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.noThanks),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.showMe),
        ),
      ],
    ),
  );
  if (show == true && context.mounted) await showBiblesInfo(context);
}
