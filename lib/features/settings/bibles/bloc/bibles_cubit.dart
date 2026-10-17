// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/constants/pref_constants.dart';
import '../../../../common/utils/formatting/app_util.dart';
import '../../../../common/utils/reader/bible_settings_signal.dart';
import '../../../../common/utils/reader/reader_prefs_utils.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../domain/repos/bible/bible_download_tracker.dart';
import '../../../../domain/repos/bible/bible_repo.dart';
import '../../../../domain/repos/bible/bible_selection_repo.dart';
import '../../../../domain/repos/pref_repo.dart';

part 'bibles_state.dart';

class BiblesCubit extends Cubit<BiblesState> {
  BiblesCubit()
    : super(BiblesState(downloadProgress: bibleDownloads.progress)) {
    bibleDownloads.addListener(_onDownloadsChanged);
    load();
  }

  final _bibleRepo = getIt<BibleRepo>();
  final _prefs = getIt<PrefRepo>();

  void _onDownloadsChanged() {
    if (isClosed) return;
    final previous = state.downloadProgress.keys.toSet();
    final current = bibleDownloads.progress;
    emit(state.copyWith(downloadProgress: current));
    if (previous.any((abbr) => !current.containsKey(abbr))) {
      load(silent: true);
    }
  }

  @override
  Future<void> close() {
    bibleDownloads.removeListener(_onDownloadsChanged);
    return super.close();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(isLoading: true));
    final bibles = await _bibleRepo.getBibles();
    bibles.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final primary = _prefs.getPrefString(PrefConstants.biblePrimaryKey);
    final owned = bibles.map((b) => b.abbreviation).toSet();

    var secondary = _splitCsv(_prefs.getPrefString(PrefConstants.bibleSecondaryKey))
        .where((a) => owned.contains(a) && a != primary)
        .toList();
    if (secondary.isEmpty) {
      secondary = bibles
          .where((b) => b.abbreviation != primary)
          .take(2)
          .map((b) => b.abbreviation)
          .toList();
    }
    _prefs.setPrefString(PrefConstants.bibleSecondaryKey, secondary.join(','));

    emit(state.copyWith(
      bibles: bibles,
      primaryAbbr: primary,
      isLoading: false,
      multiBibleEnabled: readerMultiBibleEnabled(_prefs),
      secondaryBibles: secondary,
    ));
  }

  bool takeFirstOpenTip() {
    final seen = _prefs.getPrefBool(PrefConstants.bibleManagementTipSeenKey);
    if (!seen) _prefs.setPrefBool(PrefConstants.bibleManagementTipSeenKey, true);
    return !seen;
  }

  List<String> _splitCsv(String csv) =>
      csv.isEmpty ? [] : csv.split(',').where((e) => e.isNotEmpty).toList();

  Future<void> _download(String abbr) async {
    if (bibleDownloads.isActive(abbr)) return;
    try {
      await _bibleRepo.downloadBible(abbr);
    } on BibleDownloadCancelled {
      logger('Bibles screen: download stopped for $abbr');
    } catch (e) {
      logger('Bibles screen: download failed for $abbr: $e');
    }
  }

  void retryDownload(String abbr) => _download(abbr);

  void stopDownload(String abbr) => bibleDownloads.cancel(abbr);

  Future<void> restartDownload(String abbr) async {
    if (bibleDownloads.isActive(abbr)) return;
    await _bibleRepo.clearBibleContent(abbr);
    await load(silent: true);
    await _download(abbr);
  }

  void setPrimaryBible(String abbr) {
    final bible = state.bibles.where((b) => b.abbreviation == abbr).firstOrNull;
    if (bible == null || !bible.isDownloaded) return;

    _prefs.setPrefString(PrefConstants.biblePrimaryKey, abbr);
    _prefs.setPrefString(PrefConstants.bibleLastBibleAbbrKey, abbr);
    _prefs.setPrefString(PrefConstants.bibleLastBibleKey, bible.name);
    _prefs.setPrefString(PrefConstants.bibleLastBookIdKey, '');
    _prefs.setPrefString(PrefConstants.bibleLastChapterIdKey, '');

    final updatedSecondary =
        state.secondaryBibles.where((a) => a != abbr).toList();
    _prefs.setPrefString(
      PrefConstants.bibleSecondaryKey,
      updatedSecondary.join(','),
    );

    emit(state.copyWith(
      primaryAbbr: abbr,
      secondaryBibles: updatedSecondary,
    ));
  }

  Future<void> deleteBible(String abbr) async {
    await _bibleRepo.deleteBible(abbr);

    final selection = BibleSelectionRepo();
    final remaining = selection.selectedAbbrs.where((a) => a != abbr).toList();
    _prefs.setPrefString(PrefConstants.bibleSelectedBiblesKey, remaining.join(','));
    _prefs.setPrefString(
      PrefConstants.bibleSecondaryKey,
      state.secondaryBibles.where((a) => a != abbr).join(','),
    );
    if (state.primaryAbbr == abbr) {
      _prefs.setPrefString(
        PrefConstants.biblePrimaryKey,
        remaining.isEmpty ? '' : remaining.first,
      );
    }
    await load();
  }

  void setMultiBibleEnabled(bool enabled) {
    saveReaderMultiBibleEnabled(_prefs, enabled);
    emit(state.copyWith(multiBibleEnabled: enabled));
    notifyBibleSettingsChanged();
  }

  void toggleSecondaryBible(String abbr) {
    final current = [...state.secondaryBibles];
    if (current.contains(abbr)) {
      current.remove(abbr);
    } else {
      if (current.length >= bibleMaxSecondaryBibles) return;
      current.add(abbr);
    }
    emit(state.copyWith(secondaryBibles: current));
    _prefs.setPrefString(PrefConstants.bibleSecondaryKey, current.join(','));
    notifyBibleSettingsChanged();
  }

  void moveSecondaryBible(String abbr, int direction) {
    final list = [...state.secondaryBibles];
    final idx = list.indexOf(abbr);
    final newIdx = idx + direction;
    if (idx < 0 || newIdx < 0 || newIdx >= list.length) return;
    final item = list.removeAt(idx);
    list.insert(newIdx, item);
    emit(state.copyWith(secondaryBibles: list));
    _prefs.setPrefString(PrefConstants.bibleSecondaryKey, list.join(','));
    notifyBibleSettingsChanged();
  }
}
