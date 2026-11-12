part of 'song_search_loading.dart';

// One line of text: a block centered in the real line height.
class _TextLineSkeleton extends StatelessWidget {
  const _TextLineSkeleton({
    required this.lineHeight,
    required this.blockHeight,
    this.widthFactor = 1,
  });

  final double lineHeight;
  final double blockHeight;
  final double widthFactor;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: lineHeight,
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: SkeletonBlock(
          width: double.infinity,
          height: blockHeight,
          radius: 3,
        ),
      ),
    ),
  );
}

// Songbook chips row above a list of song rows.
class _SongListSkeleton extends StatelessWidget {
  const _SongListSkeleton();

  static const _chipWidths = [100.0, 124.0, 88.0, 112.0];
  static const _titleWidthFactors = [.62, .48, .75, .55, .68, .4];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: SongSkeletonSizes.bookListHeight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(5),
          children: [
            for (final chipWidth in _chipWidths)
              SkeletonBlock(
                width: chipWidth,
                height: SongSkeletonSizes.bookChipHeight,
                radius: 5,
              ).padding(right: 5),
          ],
        ),
      ),
      Expanded(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 5, right: 10),
          itemCount: 25,
          separatorBuilder: (_, _) =>
              const SizedBox(height: SongSkeletonSizes.songListSeparatorHeight),
          itemBuilder: (_, index) => _SongRowSkeleton(
            hasChorus: index.isEven,
            titleWidthFactor: _titleWidthFactors[index % _titleWidthFactors.length],
          ),
        ),
      ),
    ],
  );
}

// Song row: title, verse and chorus tags, heart, divider and two preview lines.
class _SongRowSkeleton extends StatelessWidget {
  const _SongRowSkeleton({
    required this.hasChorus,
    required this.titleWidthFactor,
  });

  final bool hasChorus;
  final double titleWidthFactor;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: SongSkeletonSizes.songRowTitleLineHeight,
        child: Row(
          children: [
            Expanded(
              child: FractionallySizedBox(
                widthFactor: titleWidthFactor,
                alignment: Alignment.centerLeft,
                child: const SkeletonBlock(
                  width: double.infinity,
                  height: 16,
                  radius: 3,
                ),
              ),
            ),
            const SkeletonBlock(
              width: 52,
              height: SongSkeletonSizes.songTagHeight,
              radius: 5,
            ).padding(right: 5),
            if (hasChorus)
              const SkeletonBlock(
                width: 68,
                height: SongSkeletonSizes.songTagHeight,
                radius: 5,
              ).padding(right: 5),
            const _IconSlot(
              slotSize: SongSkeletonSizes.iconGlyphSize,
              glyphSize: 20,
            ),
          ],
        ),
      ),
      const SizedBox(height: 3),
      const SkeletonBlock(width: double.infinity, height: 1),
      const _TextLineSkeleton(
        lineHeight: SongSkeletonSizes.songRowBodyLineHeight,
        blockHeight: 12,
      ),
      const _TextLineSkeleton(
        lineHeight: SongSkeletonSizes.songRowBodyLineHeight,
        blockHeight: 12,
        widthFactor: .7,
      ),
    ],
  ).padding(all: 5);
}

// Song view: outlined verse cards with text lines.
class _SongViewSkeleton extends StatelessWidget {
  const _SongViewSkeleton();

  static const _verseLineWidthFactors = [
    [1.0, .82, .94, .74, .9, .63, .52],
    [1.0, .91, .8, .96, .68, .53],
    [1.0, .77, .62],
    [1.0, .89, .94, .74, .83, .64, .58],
    [1.0, .82, .97, .79, .9, .67, .48],
    [1.0, .82, .94, .74, .9, .63, .52],
    [1.0, .91, .8, .96, .68, .53],
    [1.0, .77, .62],
  ];

  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (final verse in _verseLineWidthFactors)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(
              SongSkeletonSizes.verseCardRadius,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final widthFactor in verse)
                _TextLineSkeleton(
                  lineHeight: SongSkeletonSizes.verseLineHeight,
                  blockHeight: SongSkeletonSizes.verseTextBlockHeight,
                  widthFactor: widthFactor,
                ),
            ],
          ),
        ),
    ],
  );
}
