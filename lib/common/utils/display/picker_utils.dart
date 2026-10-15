// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../core/theme/theme_colors.dart';

Future<T?> showGridPickerDialog<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T item) labelOf,
  required bool Function(T item) isActive,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 56,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final active = isActive(item);
              return Material(
                color: active
                    ? ThemeColors.primary
                    : ThemeColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pop(context, item),
                  child: Text(
                    labelOf(item),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : ThemeColors.primary,
                    ),
                  )
                      .center(),
                ),
              );
            },
          )
              .expanded(),
        ],
      )
          .padding(all: 16)
          .constrained(maxWidth: 420, maxHeight: 520),
    ),
  );
}
