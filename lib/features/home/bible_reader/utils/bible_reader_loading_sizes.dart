// Measurements copied from the real biblelib widgets so the skeleton lines up.
abstract final class BibleSkeletonSizes {
  static const double topBarHeight = 56;
  static const double moduleChipWidth = 140;
  static const double presentLabelWidth = 135;

  static const double pickerHeight = 48;
  static const double iconSlotSize = 48;
  static const double iconGlyphSize = 24;

  static const double bottomBarHeight = 64;
  static const double barButtonLabelLineHeight = 17;

  static const double verseNumberSlotWidth = 55;
  static const double verseActionsSlotWidth = 84;

  static double chapterTitleLineHeight(double fontSize) =>
      fontSize * 1.1 * 1.43;

  static double verseNumberLineHeight(double fontSize) =>
      fontSize * 1.2 * 1.43;

  static double verseTextLineHeight(double fontSize) => fontSize * 1.5;
}