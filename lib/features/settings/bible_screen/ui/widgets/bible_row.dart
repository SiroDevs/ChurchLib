// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../data/models/bible/bible_version.dart';

class BibleRow extends StatelessWidget {
  final BibleVersion bible;
  final bool isPrimary;
  final double? progress;
  final VoidCallback onSetPrimary;
  final VoidCallback onRetry;
  final VoidCallback onRestart;
  final VoidCallback onDelete;

  const BibleRow({super.key, 
    required this.bible,
    required this.isPrimary,
    required this.progress,
    required this.onSetPrimary,
    required this.onRetry,
    required this.onRestart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final downloading = progress != null;
    final failed = !bible.isDownloaded && !downloading && bible.downloadFailed;
    final pending = !bible.isDownloaded && !downloading && !failed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isPrimary ? ThemeColors.primary : ThemeColors.lightGrey,
            width: isPrimary ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          bible.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ThemeColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    switch (v) {
                      case 'primary':
                        onSetPrimary();
                      case 'retry':
                        onRetry();
                      case 'restart':
                        onRestart();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (bible.isDownloaded && !isPrimary)
                      const PopupMenuItem(
                        value: 'primary',
                        child: Text('Make primary'),
                      ),
                    if (failed || pending)
                      const PopupMenuItem(
                        value: 'retry',
                        child: Text('Download'),
                      ),
                    if (failed)
                      const PopupMenuItem(
                        value: 'restart',
                        child: Text('Restart download'),
                      ),
                    const PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
                ),
              ],
            ),
            Text(
              '${bible.abbreviation} · ${bible.languageName}',
              style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
            ),
            const SizedBox(height: 8),
            if (downloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress! > 0 ? progress : null,
                  minHeight: 6,
                  color: ThemeColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress! * 100).round()}% downloaded',
                style: const TextStyle(fontSize: 11, color: ThemeColors.grey),
              ),
            ] else if (failed) ...[
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: ThemeColors.error),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Download failed',
                      style: TextStyle(fontSize: 12, color: ThemeColors.error),
                    ),
                  ),
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
            ] else if (pending) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
