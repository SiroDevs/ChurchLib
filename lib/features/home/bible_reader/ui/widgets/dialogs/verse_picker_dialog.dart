import 'package:flutter/material.dart';

import '../../../../../../common/utils/picker_utils.dart';

Future<int?> showVersePicker(
  BuildContext context, {
  required String title,
  required List<int> verseNumbers,
  required int? activeVerseNumber,
}) {
  return showGridPickerDialog<int>(
    context,
    title: title,
    items: verseNumbers,
    labelOf: (verse) => '$verse',
    isActive: (verse) => verse == activeVerseNumber,
  );
}
