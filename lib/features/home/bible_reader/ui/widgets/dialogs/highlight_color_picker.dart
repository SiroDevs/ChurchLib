// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../verses/verse_row.dart';

Future<String?> showHighlightColorPicker(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Choose a highlight color'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final hex in readerHighlightColors)
            Tooltip(
              message: hex,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.pop(context, hex),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: parseHexColor(hex),
                    shape: BoxShape.circle,
                    border: Border.all(color: ThemeColors.lightGrey),
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
