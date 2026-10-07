// Project imports:
import '../../../common/utils/app_util.dart';
import '../../../common/utils/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../data/models/bible/bible_version.dart';
import '../../../data/sources/remote/bible/bible_dtos.dart';
import '../pref_repo.dart';
import 'bible_repo.dart';

const bibleFirstInstallMax = 7;
const bibleAdditionalAllowed = 5;

const _defaultSecondaryBibles = 2;
const bibleMaxSecondaryBibles = 5;

class BibleSelectionRepo {
  final BibleRepo _bibleRepo = getIt<BibleRepo>();
  final PrefRepo _prefRepo = getIt<PrefRepo>();

  List<String> get selectedAbbrs => _split(
        _prefRepo.getPrefString(PrefConstants.bibleSelectedBiblesKey),
      );

  bool get isFirstInstall =>
      !_prefRepo.getPrefBool(PrefConstants.biblelibDataSelectedKey);

  List<String> _split(String csv) =>
      csv.isEmpty ? [] : csv.split(',').where((e) => e.isNotEmpty).toList();

  Future<List<BibleInfoDto>> fetchAvailable() =>
      _bibleRepo.fetchAvailableBibles();

  Future<void> persistSelection(List<BibleInfoDto> selected) async {
    final primary = selected.first;
    final newAbbrs = selected.map((e) => e.abbreviation).toSet();

    for (final abbr in selectedAbbrs.where((a) => !newAbbrs.contains(a))) {
      await _bibleRepo.deleteBible(abbr);
    }

    _prefRepo.setPrefString(
      PrefConstants.bibleSelectedBiblesKey,
      selected.map((e) => e.abbreviation).join(','),
    );
    _prefRepo.setPrefString(PrefConstants.biblePrimaryKey, primary.abbreviation);
    _prefRepo.setPrefBool(PrefConstants.biblelibDataSelectedKey, true);

    _prefRepo.setPrefString(PrefConstants.bibleLastBibleKey, primary.name);
    _prefRepo.setPrefString(
      PrefConstants.bibleLastBibleAbbrKey,
      primary.abbreviation,
    );
    _prefRepo.setPrefString(PrefConstants.bibleLastBookIdKey, '');
    _prefRepo.setPrefString(PrefConstants.bibleLastChapterIdKey, '');

    final keptSecondary = _split(
      _prefRepo.getPrefString(PrefConstants.bibleSecondaryKey),
    ).where((a) => newAbbrs.contains(a) && a != primary.abbreviation).toList();
    final secondary = keptSecondary.isNotEmpty
        ? keptSecondary
        : selected
            .skip(1)
            .take(_defaultSecondaryBibles)
            .map((e) => e.abbreviation)
            .toList();
    _prefRepo.setPrefString(PrefConstants.bibleSecondaryKey, secondary.join(','));

    await _bibleRepo.saveBibles([
      for (var i = 0; i < selected.length; i++)
        BibleVersion(
          abbreviation: selected[i].abbreviation,
          name: selected[i].name,
          description: selected[i].description,
          languageName: selected[i].language.name,
          scriptDirection: selected[i].language.scriptDirection,
          sortOrder: i,
          addedAt: DateTime.now().millisecondsSinceEpoch,
          countryName: selected[i].primaryCountryName,
          path: selected[i].path,
        ),
    ]);
  }

  Future<void> downloadPrimaryAndQueueSecondaries(
    List<BibleInfoDto> selected, {
    required Future<void> Function(String step, double progress) onProgress,
  }) async {
    final primary = selected.first;
    final existing = await _bibleRepo.getBibles();
    if (!existing.any((b) => b.abbreviation == primary.abbreviation)) {
      await persistSelection(selected);
    }

    await _bibleRepo.downloadBible(primary.abbreviation, onProgress: onProgress);
    _prefRepo.setPrefBool(PrefConstants.biblelibDataLoadedKey, true);

    _downloadSecondariesInBackground(
      selected.skip(1).map((e) => e.abbreviation).toList(),
    );
  }

  Future<double> savedProgress(String abbr) async {
    final all = await _bibleRepo.getBibles();
    for (final b in all) {
      if (b.abbreviation == abbr) return b.downloadProgress;
    }
    return 0;
  }

  Future<void> restart(String abbr) => _bibleRepo.clearBibleContent(abbr);

  void _downloadSecondariesInBackground(List<String> abbrs) {
    Future(() async {
      for (final abbr in abbrs) {
        try {
          await _bibleRepo.downloadBible(abbr);
        } catch (e) {
          logger('⚠️ Background download failed for $abbr: $e');
        }
      }
    });
  }
}
