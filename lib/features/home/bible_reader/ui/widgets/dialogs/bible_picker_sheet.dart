// Flutter imports:
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../../../common/utils/app_util.dart';
import '../../../../../../data/models/bible/bible_version.dart';

const bibleManageResult = '__manage__';

Future<String?> showBiblePicker(
  BuildContext context, {
  required List<BibleVersion> bibles,
  required String activeAbbr,
}) {
  final downloaded = bibles.where((b) => b.isDownloaded).toList();
  return showModalBottomSheet<String>(
    context: context,
    sheetAnimationStyle: AnimationStyle.noAnimation,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: [
                Text(
                  'Switch Your Primary Bible',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ).expanded(),

                TextButton.icon(
                  onPressed: () => Navigator.pop(ctx, bibleManageResult),
                  icon: const Icon(Icons.library_books_outlined),
                  label: Text(
                    'Manage Bibles',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ).expanded(),
              ].toRow(),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final b in downloaded)
                    ListTile(
                      selected: b.abbreviation == activeAbbr,
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(ctx).colorScheme.primary
                            .withValues(alpha: .14),
                        child: Text(
                          short(b.abbreviation),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(ctx).colorScheme.primary,
                          ),
                        ),
                      ),
                      title: Text(b.name, maxLines: 2),
                      subtitle: Text('${b.languageName.toUpperCase()} ~ ${b.description}', maxLines: 2),
                      trailing: b.abbreviation == activeAbbr
                          ? const Icon(Icons.check_circle)
                          : null,
                      onTap: () => Navigator.pop(ctx, b.abbreviation),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
