// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/widgets/state/skeleton_block.dart';
import '../../../../common/widgets/state/skeleton_part.dart';
import 'app_module.dart';
import 'app_shell.dart';

const double _sidebarTopPadding = 6;
const double _sidebarBottomPadding = 8;
const double _navItemHeight = 46;
const double _navIconSize = 22;
const double _moduleChipHeight = 34;
const double _otherModuleSlotSize = 44;
const double _otherModuleGlyphSize = 28;
const List<double> _fixedBottomLabelWidths = [125, 95];
const double _settingsLabelWidth = 84;

class ShellSkeleton extends StatelessWidget {
  const ShellSkeleton({
    super.key,
    required this.module,
    required this.moduleChipWidth,
    required this.topBarHeight,
    required this.titleBar,
    required this.sidebarLabelWidths,
    required this.presentLabelWidth,
    required this.body,
  });

  final AppModule module;
  final double moduleChipWidth;
  final double topBarHeight;
  final Widget titleBar;
  final List<double> sidebarLabelWidths;
  final double presentLabelWidth;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rightDivider = Border(
      right: BorderSide(color: scheme.outlineVariant),
    );
    return Container(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: topBarHeight,
              width: double.infinity,
              color: scheme.secondaryContainer,
              child: SkeletonShimmer(
                child: Row(
                  children: [
                    SkeletonAppSwitcher(
                      module: module,
                      chipWidth: moduleChipWidth,
                    ),
                    Expanded(child: titleBar),
                  ],
                ),
              ),
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
                    child: SkeletonShimmer(
                      child: _SkeletonSidebar(
                        labelWidths: sidebarLabelWidths,
                        presentLabelWidth: presentLabelWidth,
                      ),
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Module switcher: chip for the current module, icons for the other enabled ones.
class SkeletonAppSwitcher extends StatelessWidget {
  const SkeletonAppSwitcher({
    super.key,
    required this.module,
    required this.chipWidth,
  });

  final AppModule module;
  final double chipWidth;

  @override
  Widget build(BuildContext context) {
    final enabledModules =
        HomeModuleScope.maybeOf(context)?.enabled ?? const <AppModule>[];
    final shownModules = AppModule.values.where(
      (candidate) => candidate == module || enabledModules.contains(candidate),
    );

    return SizedBox(
      width: kShellSidebarWidth,
      child: Row(
        children: [
          for (final shownModule in shownModules)
            if (shownModule == module)
              SkeletonBlock(
                width: chipWidth,
                height: _moduleChipHeight,
                radius: 8,
              )
            else
              const SkeletonIconSlot(
                slotSize: _otherModuleSlotSize,
                glyphSize: _otherModuleGlyphSize,
              ),
        ],
      ).padding(horizontal: 10),
    );
  }
}

// One sidebar row: icon and label with the same insets as ShellNavItem.
class SkeletonNavItem extends StatelessWidget {
  const SkeletonNavItem({super.key, required this.labelWidth});

  final double labelWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _navItemHeight,
    child: Row(
      children: [
        const SizedBox(width: 12),
        const SkeletonBlock(width: _navIconSize, height: _navIconSize, radius: 4),
        const SizedBox(width: 18),
        SkeletonBlock(width: labelWidth, height: 14, radius: 3),
      ],
    ),
  ).padding(horizontal: 8, vertical: 2);
}

// Sidebar: module items on top, present / help / theme / settings below.
class _SkeletonSidebar extends StatelessWidget {
  const _SkeletonSidebar({
    required this.labelWidths,
    required this.presentLabelWidth,
  });

  final List<double> labelWidths;
  final double presentLabelWidth;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: _sidebarTopPadding),
      for (final labelWidth in labelWidths)
        SkeletonNavItem(labelWidth: labelWidth),
      const Spacer(),
      const SkeletonBlock(width: double.infinity, height: 1),
      SkeletonNavItem(labelWidth: presentLabelWidth),
      const SkeletonBlock(width: double.infinity, height: 1),
      for (final labelWidth in _fixedBottomLabelWidths)
        SkeletonNavItem(labelWidth: labelWidth),
      const SkeletonBlock(width: double.infinity, height: 1),
      const SkeletonNavItem(labelWidth: _settingsLabelWidth),
      const SizedBox(height: _sidebarBottomPadding),
    ],
  );
}
