// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';

Future<int?> showVersePicker(
  BuildContext context, {
  required String title,
  required List<int> verseNumbers,
  required int? activeVerseNumber,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 56,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: verseNumbers.length,
                  itemBuilder: (context, i) {
                    final n = verseNumbers[i];
                    final active = n == activeVerseNumber;
                    return Material(
                      color: active
                          ? ThemeColors.primary
                          : ThemeColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.pop(context, n),
                        child: Center(
                          child: Text(
                            '$n',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : ThemeColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
 