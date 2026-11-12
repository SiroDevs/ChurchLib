part of 'bible_reader_loading.dart';

// Title bar: Bible and chapter pickers, scripture opener and icon buttons.
class _BibleTitleBarSkeleton extends StatelessWidget {
  const _BibleTitleBarSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      _PickerSkeleton(labelWidth: 96),
      SizedBox(width: 8),
      _PickerSkeleton(labelWidth: 88, hasIcon: true),
      Spacer(),
      _ScriptureOpenerSkeleton(),
      SkeletonIconSlot(
        slotSize: BibleSkeletonSizes.iconSlotSize,
        glyphSize: BibleSkeletonSizes.iconGlyphSize,
      ),
      SkeletonIconSlot(
        slotSize: BibleSkeletonSizes.iconSlotSize,
        glyphSize: BibleSkeletonSizes.iconGlyphSize,
      ),
      SkeletonIconSlot(
        slotSize: BibleSkeletonSizes.iconSlotSize,
        glyphSize: BibleSkeletonSizes.iconGlyphSize,
      ),
    ],
  ).padding(left: 12, right: 6);
}

// Picker button: optional icon, label and drop-down arrow.
class _PickerSkeleton extends StatelessWidget {
  const _PickerSkeleton({required this.labelWidth, this.hasIcon = false});

  final double labelWidth;
  final bool hasIcon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: BibleSkeletonSizes.pickerHeight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 12),
        if (hasIcon) ...[
          const SkeletonBlock(width: 20, height: 20, radius: 4),
          const SizedBox(width: 8),
        ],
        SkeletonBlock(width: labelWidth, height: 14, radius: 3),
        const SkeletonIconSlot(slotSize: 24, glyphSize: 12),
        const SizedBox(width: 12),
      ],
    ),
  );
}

// Scripture Opener button: icon and label.
class _ScriptureOpenerSkeleton extends StatelessWidget {
  const _ScriptureOpenerSkeleton();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: BibleSkeletonSizes.pickerHeight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 12),
        SkeletonBlock(width: 20, height: 20, radius: 4),
        SizedBox(width: 8),
        SkeletonBlock(width: 105, height: 14, radius: 3),
        SizedBox(width: 16),
      ],
    ),
  );
}