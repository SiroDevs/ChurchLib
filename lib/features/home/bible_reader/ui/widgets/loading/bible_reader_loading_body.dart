part of 'bible_reader_loading.dart';

// Reader area: verses on the reader background, bottom bar underneath.
class _BibleBodySkeleton extends StatelessWidget {
  const _BibleBodySkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Expanded(
          child: ColoredBox(
            color: isDark ? Colors.black : Colors.white,
            child: const SkeletonShimmer(child: _VersesSkeleton()),
          ),
        ),
        const _BottomBarSkeleton(),
      ],
    );
  }
}

// Chapter title followed by verse rows, sized from the saved font size.
class _VersesSkeleton extends StatelessWidget {
  const _VersesSkeleton();

  static const _versePatterns = [
    [1.0, .92, .55],
    [1.0, .7],
    [1.0, .95, .88, .4],
    [.8],
    [1.0, .9, .35],
  ];

  @override
  Widget build(BuildContext context) {
    final fontSize = readerStoredFontSize(getIt<PrefRepo>()).toDouble();
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        _ChapterTitleSkeleton(fontSize: fontSize),
        for (var verseIndex = 0; verseIndex < 30; verseIndex++)
          _VerseSkeleton(
            fontSize: fontSize,
            lineWidthFactors: _versePatterns[verseIndex % _versePatterns.length],
          ),
      ],
    );
  }
}

// Chapter reference heading above the verses.
class _ChapterTitleSkeleton extends StatelessWidget {
  const _ChapterTitleSkeleton({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: BibleSkeletonSizes.chapterTitleLineHeight(fontSize),
    child: Align(
      alignment: Alignment.centerLeft,
      child: SkeletonBlock(
        width: fontSize * 6,
        height: fontSize * .75,
        radius: 3,
      ),
    ),
  ).padding(bottom: 12, left: 8);
}

// Verse row: number slot, text lines and the reserved actions slot.
class _VerseSkeleton extends StatelessWidget {
  const _VerseSkeleton({
    required this.fontSize,
    required this.lineWidthFactors,
  });

  final double fontSize;
  final List<double> lineWidthFactors;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: BibleSkeletonSizes.verseNumberSlotWidth,
        height: BibleSkeletonSizes.verseNumberLineHeight(fontSize),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBlock(
            width: fontSize * 1.1,
            height: fontSize * .85,
            radius: 3,
          ),
        ),
      ).padding(top: 3),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final widthFactor in lineWidthFactors)
              SkeletonTextLine(
                lineHeight: BibleSkeletonSizes.verseTextLineHeight(fontSize),
                blockHeight: fontSize * .62,
                widthFactor: widthFactor,
              ),
          ],
        ),
      ),
      const SizedBox(width: BibleSkeletonSizes.verseActionsSlotWidth),
    ],
  ).padding(left: 8, top: 6, right: 4, bottom: 6).padding(vertical: 2);
}

// Bottom bar: auto scroll, previous / chapter / next, quick options.
class _BottomBarSkeleton extends StatelessWidget {
  const _BottomBarSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: BibleSkeletonSizes.bottomBarHeight,
      color: scheme.secondaryContainer,
      foregroundDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: const SkeletonShimmer(
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 8),
                    _BarButtonSkeleton(labelWidth: 60),
                  ],
                ),
              ),
            ),
            _BarButtonSkeleton(labelWidth: 48),
            SizedBox(width: 4),
            _BarButtonSkeleton(labelWidth: 58),
            SizedBox(width: 4),
            _BarButtonSkeleton(labelWidth: 28),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _BarButtonSkeleton(labelWidth: 78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom bar button: icon above a short label.
class _BarButtonSkeleton extends StatelessWidget {
  const _BarButtonSkeleton({required this.labelWidth});

  final double labelWidth;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SkeletonBlock(width: 24, height: 24, radius: 4),
      const SizedBox(height: 2),
      SizedBox(
        height: BibleSkeletonSizes.barButtonLabelLineHeight,
        child: Center(
          child: SkeletonBlock(width: labelWidth, height: 10, radius: 3),
        ),
      ),
    ],
  ).padding(horizontal: 14, vertical: 6);
}
