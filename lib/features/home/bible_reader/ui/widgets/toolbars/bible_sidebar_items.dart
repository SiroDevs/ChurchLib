// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../../common/windows/open_windows.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../../main/shell/shell_nav_item.dart';
import '../../../cubit/bible_reader_cubit.dart';

List<Widget> bibleSidebarItems(BuildContext context) {
  final cubit = context.read<BibleReaderCubit>();

  Future<void> open(Future<ReaderTarget?> Function() opener) async {
    final target = await opener();
    if (target != null) await cubit.openTarget(target);
  }

  return [
    ShellNavItem(
      Icons.search,
      'Search',
      onPressed: () => open(() => openBibleSearch(context)),
    ),
    ShellNavItem(
      Icons.history,
      'History',
      onPressed: () => open(() => openBibleHistory(context)),
    ),
    ShellNavItem(
      Icons.bookmarks_outlined,
      'Bookmarks',
      onPressed: () => open(() => openBookmarksNotes(context)),
    ),
    ShellNavItem(
      Icons.edit_note,
      'Notes',
      onPressed: () => open(() => openBookmarksNotes(context, tab: 1)),
    ),
    ShellNavItem(
      Icons.list_alt,
      'Scriptures',
      onPressed: () => open(() => openScriptureLists(context)),
    ),
  ];
}
