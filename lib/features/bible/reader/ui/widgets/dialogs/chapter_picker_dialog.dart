// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../common/utils/display/picker_utils.dart';
import '../../../../../../data/models/bible/bible_chapter.dart';

Future<BibleChapter?> showChapterPicker(
  BuildContext context, {
  required String bookName,
  required List<BibleChapter> chapters,
  required String? activeChapterId,
}) {
  return showGridPickerDialog<BibleChapter>(
    context,
    title: bookName,
    items: chapters,
    labelOf: (chapter) => chapter.number,
    isActive: (chapter) => chapter.id == activeChapterId,
  );
}
