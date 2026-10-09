// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../data/models/bible/bible_version.dart';

class PrimaryBibleCard extends StatelessWidget {
  const PrimaryBibleCard({super.key, required this.primary, required this.onTap});

  final BibleVersion? primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bible = primary;
    if (bible == null) return const Text('No primary Bible set yet.');

    final scheme = Theme.of(context).colorScheme;
    final abbr = bible.abbreviation.toUpperCase();
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.primary),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  abbr.length > 3 ? abbr.substring(0, 3) : abbr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bible.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${bible.languageName.toUpperCase()} BIBLE • PRIMARY',
                      style: TextStyle(fontSize: 11, color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
