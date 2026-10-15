// Dart imports:
import 'dart:math';

int getSlideByNumber(int verseNumber, bool hasChorus, int totalWidgets) {
  if (verseNumber < 1) return 0;

  if (!hasChorus) {
    return min(verseNumber - 1, totalWidgets - 1);
  }

  int slideIndex = (verseNumber - 1) * 2;

  return min(slideIndex, totalWidgets - 1);
}

int getSlideByLetter(String letter, bool hasChorus, int totalWidgets) {
  if (totalWidgets <= 0) return 0;

  switch (letter.toUpperCase()) {
    case 'C':
      return hasChorus ? 1 : 0;

    case 'S':
      if (hasChorus) {
        return max(0, totalWidgets - 2);
      }
      return max(0, totalWidgets - 2);

    case 'L':
      if (hasChorus) {
        return max(0, totalWidgets - 1);
      }
      return max(0, totalWidgets - 1);

    default:
      return 0;
  }
}

/// Index, in the song's verses (content split on "##"), of the verse shown on
/// [slide]. With a chorus the slides alternate verse, chorus, verse, chorus...
int rawVerseForSlide(int slide, bool hasChorus) {
  if (!hasChorus) return slide;
  if (slide.isOdd) return 1;
  return slide == 0 ? 0 : slide ~/ 2 + 1;
}
