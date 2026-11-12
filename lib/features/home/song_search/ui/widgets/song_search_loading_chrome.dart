part of 'song_search_loading.dart';

// Centered glyph placeholder inside a fixed-size slot (icon buttons, icons).
class _IconSlot extends StatelessWidget {
  const _IconSlot({required this.slotSize, required this.glyphSize});

  final double slotSize;
  final double glyphSize;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: slotSize,
    height: slotSize,
    child: Center(
      child: SkeletonBlock(width: glyphSize, height: glyphSize, radius: 4),
    ),
  );
}

// Top bar: module switcher, search field and selected song header.
class _TitleBarSkeleton extends StatelessWidget {
  const _TitleBarSkeleton();

  @override
  Widget build(BuildContext context) {
    final enabledModules =
        HomeModuleScope.maybeOf(context)?.enabled ?? const <AppModule>[];
    final otherModuleCount = enabledModules
        .where((module) => module != AppModule.songlib)
        .length;

    return Row(
      children: [
        SizedBox(
          width: kShellSidebarWidth,
          child: Row(
            children: [
              const SkeletonBlock(
                width: SongSkeletonSizes.moduleChipWidth,
                height: SongSkeletonSizes.moduleChipHeight,
                radius: 8,
              ),
              ...List.generate(
                otherModuleCount,
                (_) => const _IconSlot(
                  slotSize: SongSkeletonSizes.moduleIconSlotSize,
                  glyphSize: SongSkeletonSizes.moduleIconGlyphSize,
                ),
              ),
            ],
          ).padding(horizontal: 10),
        ),
        const Expanded(child: _SearchFieldSkeleton()),
        const Expanded(child: _SongHeaderSkeleton()),
      ],
    );
  }
}

// Search field: prefix icon, hint text and clear button.
class _SearchFieldSkeleton extends StatelessWidget {
  const _SearchFieldSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsGeometry.symmetric(
      horizontal: 10,
      vertical: SongSkeletonSizes.searchFieldVerticalPadding,
    ),
    child: Container(
      height: SongSkeletonSizes.searchFieldHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          _IconSlot(
            slotSize: SongSkeletonSizes.iconSlotSize,
            glyphSize: SongSkeletonSizes.iconGlyphSize,
          ),
          Expanded(
            child: FractionallySizedBox(
              widthFactor: .55,
              alignment: Alignment.centerLeft,
              child: SkeletonBlock(
                width: double.infinity,
                height: 14,
                radius: 3,
              ),
            ),
          ),
          _IconSlot(
            slotSize: SongSkeletonSizes.iconSlotSize,
            glyphSize: SongSkeletonSizes.iconGlyphSize,
          ),
        ],
      ),
    ),
  );
}

// Song title plus the present and copy icon buttons.
class _SongHeaderSkeleton extends StatelessWidget {
  const _SongHeaderSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: FractionallySizedBox(
            widthFactor: .6,
            alignment: Alignment.centerLeft,
            child: SkeletonBlock(width: double.infinity, height: 20, radius: 3),
          ),
        ),
      ),
      _IconSlot(
        slotSize: SongSkeletonSizes.iconSlotSize,
        glyphSize: SongSkeletonSizes.iconGlyphSize,
      ),
      _IconSlot(
        slotSize: SongSkeletonSizes.iconSlotSize,
        glyphSize: SongSkeletonSizes.iconGlyphSize,
      ),
    ],
  );
}

// Sidebar nav rows, mirroring the real item order and label lengths.
class _SidebarSkeleton extends StatelessWidget {
  const _SidebarSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      SizedBox(height: SongSkeletonSizes.sidebarTopPadding),
      _NavItemSkeleton(labelWidth: 125),
      _NavItemSkeleton(labelWidth: 115),
      Spacer(),
      SkeletonBlock(width: double.infinity, height: 1),
      _NavItemSkeleton(labelWidth: 166),
      SkeletonBlock(width: double.infinity, height: 1),
      _NavItemSkeleton(labelWidth: 125),
      _NavItemSkeleton(labelWidth: 95),
      SkeletonBlock(width: double.infinity, height: 1),
      _NavItemSkeleton(labelWidth: 84),
      SizedBox(height: SongSkeletonSizes.sidebarBottomPadding),
    ],
  );
}

// One sidebar row: icon and label with the same insets as ShellNavItem.
class _NavItemSkeleton extends StatelessWidget {
  const _NavItemSkeleton({required this.labelWidth});

  final double labelWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: SongSkeletonSizes.navItemHeight,
    child: Row(
      children: [
        const SizedBox(width: 12),
        const SkeletonBlock(
          width: SongSkeletonSizes.navIconSize,
          height: SongSkeletonSizes.navIconSize,
          radius: 4,
        ),
        const SizedBox(width: 18),
        SkeletonBlock(width: labelWidth, height: 14, radius: 3),
      ],
    ),
  ).padding(horizontal: 8, vertical: 2);
}
