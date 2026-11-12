import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../../common/utils/reader/reader_prefs_utils.dart';
import '../../../../../../common/widgets/state/skeleton_block.dart';
import '../../../../../../common/widgets/state/skeleton_part.dart';
import '../../../../../../core/di/injectable.dart';
import '../../../../../../domain/repos/pref_repo.dart';
import '../../../../main/shell/app_module.dart';
import '../../../../main/shell/shell_skeleton.dart';
import '../../../utils/bible_reader_loading_sizes.dart';

part 'bible_reader_loading_title_bar.dart';
part 'bible_reader_loading_body.dart';

// Skeleton of the biblelib home: top bar, sidebar, verses and bottom bar.
class BibleReaderLoading extends StatelessWidget {
  const BibleReaderLoading({super.key});

  static const _sidebarLabelWidths = [62.0, 73.0, 94.0, 52.0, 104.0];

  @override
  Widget build(BuildContext context) => const ShellSkeleton(
    module: AppModule.biblelib,
    moduleChipWidth: BibleSkeletonSizes.moduleChipWidth,
    topBarHeight: BibleSkeletonSizes.topBarHeight,
    titleBar: _BibleTitleBarSkeleton(),
    sidebarLabelWidths: _sidebarLabelWidths,
    presentLabelWidth: BibleSkeletonSizes.presentLabelWidth,
    body: _BibleBodySkeleton(),
  );
}