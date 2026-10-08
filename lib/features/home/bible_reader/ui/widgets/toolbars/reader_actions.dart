// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../../common/windows/open_windows.dart';
import '../../../cubit/bible_reader_cubit.dart';
import '../dialogs/export.dart';

Future<void> pickBibleAction(
  BuildContext context,
  BibleReaderState state,
) async {
  final cubit = context.read<BibleReaderCubit>();
  final result = await showBiblePicker(
    context,
    bibles: state.savedBibles,
    activeAbbr: state.activeBibleAbbr,
  );
  if (result == null || !context.mounted) return;
  if (result == bibleManageResult) {
    await openBibles(context);
  } else {
    cubit.setPrimaryBible(result);
  }
}

Future<void> pickChapterAction(
  BuildContext context,
  BibleReaderState state,
) async {
  final cubit = context.read<BibleReaderCubit>();
  final chapter = await showChapterPicker(
    context,
    bookName: state.activeBook?.name ?? '',
    chapters: state.chapters,
    activeChapterId: state.activeChapter?.id,
  );
  if (chapter != null) cubit.selectChapter(chapter);
}

Future<void> chooseBookAction(
  BuildContext context,
  BibleReaderState state,
) async {
  final cubit = context.read<BibleReaderCubit>();
  final book = await showBookPicker(
    context,
    books: state.books,
    activeBookId: state.activeBook?.id,
  );
  if (book != null) cubit.selectBook(book);
}

Future<void> openScriptureAction(
  BuildContext context,
  BibleReaderState state,
) async {
  final cubit = context.read<BibleReaderCubit>();
  final target = await openScriptureOpener(
    context,
    bibleAbbr: state.activeBibleAbbr,
    bibleName: state.activeBible,
  );
  if (target != null) await cubit.openTarget(target);
}
