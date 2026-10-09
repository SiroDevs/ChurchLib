// Project imports:
import '../../domain/repos/pref_repo.dart';
import 'constants/pref_constants.dart';

const readerDefaultFontSize = 26;
const readerMinFontSize = 14;
const readerMaxFontSize = 56;

int clampReaderFontSize(int size) =>
    size.clamp(readerMinFontSize, readerMaxFontSize);

String readerLastBibleAbbr(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastBibleAbbrKey);

String readerLastBookId(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastBookIdKey);

String readerLastChapterId(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastChapterIdKey);

String readerLastVerseId(PrefRepo prefs) =>
    prefs.getPrefString(PrefConstants.bibleLastVerseIdKey);

bool readerMultiBibleEnabled(PrefRepo prefs) => prefs.getPrefBool(
      PrefConstants.bibleMultiBibleEnabledKey,
      defaultValue: true,
    );

int readerStoredFontSize(PrefRepo prefs) {
  final stored = prefs.getPrefInt(PrefConstants.bibleFontSizeKey);
  return stored > 0 ? stored : readerDefaultFontSize;
}

List<String> readerSecondaryBibles(PrefRepo prefs) {
  final csv = prefs.getPrefString(PrefConstants.bibleSecondaryKey);
  return csv.isEmpty ? [] : csv.split(',').where((e) => e.isNotEmpty).toList();
}

void saveReaderFontSize(PrefRepo prefs, int size) =>
    prefs.setPrefInt(PrefConstants.bibleFontSizeKey, size);

void saveReaderMultiBibleEnabled(PrefRepo prefs, bool enabled) =>
    prefs.setPrefBool(PrefConstants.bibleMultiBibleEnabledKey, enabled);

void saveReaderLastVerseId(PrefRepo prefs, String verseId) =>
    prefs.setPrefString(PrefConstants.bibleLastVerseIdKey, verseId);

void saveReaderPosition(
  PrefRepo prefs, {
  required String bibleAbbr,
  required String bookId,
  required String chapterId,
}) {
  prefs.setPrefString(PrefConstants.bibleLastBibleAbbrKey, bibleAbbr);
  prefs.setPrefString(PrefConstants.bibleLastBookIdKey, bookId);
  prefs.setPrefString(PrefConstants.bibleLastChapterIdKey, chapterId);
}

void saveReaderPrimaryBible(
  PrefRepo prefs, {
  required String abbr,
  required String name,
}) {
  prefs.setPrefString(PrefConstants.biblePrimaryKey, abbr);
  prefs.setPrefString(PrefConstants.bibleLastBibleKey, name);
  prefs.setPrefString(
    PrefConstants.bibleSecondaryKey,
    readerSecondaryBibles(prefs).where((a) => a != abbr).join(','),
  );
}
