// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../../../common/navigator/route_names.dart';
import '../../../../main/shell/shell_nav_item.dart';
import '../../../../../../domain/entities/bible/bible_reader.dart';
import '../../../cubit/bible_reader_cubit.dart';

List<Widget> bibleSidebarItems(BuildContext context) {
  final cubit = context.read<BibleReaderCubit>();

  Future<void> open(String route, {Object? extra}) async {
    final target = await context.pushNamed<ReaderTarget>(route, extra: extra);
    if (target != null) await cubit.openTarget(target);
  }

  return [
    ShellNavItem(
      Icons.search,
      'Search',
      onPressed: () => open(RouteNames.bibleSearch),
    ),
    ShellNavItem(
      Icons.history,
      'History',
      onPressed: () => open(RouteNames.bibleHistory),
    ),
    ShellNavItem(
      Icons.bookmarks_outlined,
      'Bookmarks',
      onPressed: () => open(RouteNames.bibleBookmarksNotes, extra: 0),
    ),
    ShellNavItem(
      Icons.edit_note,
      'Notes',
      onPressed: () => open(RouteNames.bibleBookmarksNotes, extra: 1),
    ),
    ShellNavItem(
      Icons.list_alt,
      'Scriptures',
      onPressed: () => open(RouteNames.scriptureLists),
    ),
  ];
}
