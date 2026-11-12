import 'package:flutter/material.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../../common/widgets/state/skeleton_block.dart';
import '../../../main/shell/app_module.dart';
import '../../../main/shell/app_shell.dart';
import '../../utils/song_search_loading_sizes.dart';

part 'song_search_loading_chrome.dart';
part 'song_search_loading_content.dart';

// Skeleton of the songlib home: top bar, sidebar, song list and song view.
class SongSearchLoading extends StatelessWidget {
  const SongSearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rightDivider = Border(right: BorderSide(color: scheme.outlineVariant));
    return Container(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: SongSkeletonSizes.topBarHeight,
              width: double.infinity,
              color: scheme.secondaryContainer,
              child: _shimmer(context, const _TitleBarSkeleton()),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: kShellSidebarWidth,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      border: rightDivider,
                    ),
                    child: _shimmer(context, const _SidebarSkeleton()),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(border: rightDivider),
                            child: _shimmer(context, const _SongListSkeleton()),
                          ),
                        ),
                        Expanded(
                          child: _shimmer(context, const _SongViewSkeleton()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer sized to its parent so each panel animates on its own.
  Widget _shimmer(BuildContext context, Widget child) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SkeletonLoader(
        items: 1,
        builder: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: child,
        ),
        baseColor: scheme.surfaceContainerHighest,
        highlightColor: scheme.primary,
        period: const Duration(milliseconds: 1600),
      ),
    );
  }
}
