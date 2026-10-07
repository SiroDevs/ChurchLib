// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/constants/pref_constants.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../domain/repos/bible/bible_repo.dart';
import '../../../../domain/repos/bible/bible_selection_repo.dart';
import '../../../../domain/repos/pref_repo.dart';

class BiblesState {
  final List<BibleVersion> bibles;
  final String primaryAbbr;

  /// abbr -> 0.0-1.0, only for bibles currently downloading in this
  /// session (desktop has no background worker to observe, so this only
  /// reflects downloads started from this screen).
  final Map<String, double> downloadProgress;
  final Set<String> retrying;
  final bool isLoading;
  final bool multiBibleEnabled;
  final List<String> secondaryBibles;

  const BiblesState({
    this.bibles = const [],
    this.primaryAbbr = '',
    this.downloadProgress = const {},
    this.retrying = const {},
    this.isLoading = true,
    this.multiBibleEnabled = true,
    this.secondaryBibles = const [],
  });

  BiblesState copyWith({
    List<BibleVersion>? bibles,
    String? primaryAbbr,
    Map<String, double>? downloadProgress,
    Set<String>? retrying,
    bool? isLoading,
    bool? multiBibleEnabled,
    List<String>? secondaryBibles,
  }) =>
      BiblesState(
        bibles: bibles ?? this.bibles,
        primaryAbbr: primaryAbbr ?? this.primaryAbbr,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        retrying: retrying ?? this.retrying,
        isLoading: isLoading ?? this.isLoading,
        multiBibleEnabled: multiBibleEnabled ?? this.multiBibleEnabled,
        secondaryBibles: secondaryBibles ?? this.secondaryBibles,
      );
}

/// Ported from biblelib-android's `BiblesViewModel`. Android observes a
/// WorkManager queue for background download progress; there's no such
/// queue here, so retry/restart download directly in this cubit and
/// stream their own progress, same as `SelectionBloc` does for the
/// primary during setup.
class BiblesCubit extends Cubit<BiblesState> {
  BiblesCubit() : super(const BiblesState()) {
    load();
  }

  final _bibleRepo = getIt<BibleRepo>();
  final _prefs = getIt<PrefRepo>();

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
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
      multiBibleEnabled: _prefs.getPrefBool(
        PrefConstants.bibleMultiBibleEnabledKey,
        defaultValue: true,
      ),
      secondaryBibles: secondary,
    ));
  }

  List<String> _splitCsv(String csv) =>
      csv.isEmpty ? [] : csv.split(',').where((e) => e.isNotEmpty).toList();

  Future<void> _download(String abbr) async {
    emit(state.copyWith(
      downloadProgress: {...state.downloadProgress, abbr: 0},
      retrying: {...state.retrying}..remove(abbr),
    ));
    try {
      await _bibleRepo.downloadBible(
        abbr,
        onProgress: (step, progress) async {
          if (!isClosed) {
            emit(state.copyWith(
              downloadProgress: {...state.downloadProgress, abbr: progress},
            ));
          }
        },
      );
    } catch (e) {
      logger('Bibles screen: download failed for $abbr: $e');
    } finally {
      if (!isClosed) {
        final progress = {...state.downloadProgress}..remove(abbr);
        emit(state.copyWith(downloadProgress: progress));
        await load();
      }
    }
  }

  /// Retry a translation that failed or was never downloaded.
  void retryDownload(String abbr) => _download(abbr);

  /// Clear a translation's partial content and download it again.
  Future<void> restartDownload(String abbr) async {
    emit(state.copyWith(retrying: {...state.retrying, abbr}));
    await _bibleRepo.clearBibleContent(abbr);
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
    _prefs.setPrefBool(PrefConstants.bibleMultiBibleEnabledKey, enabled);
    emit(state.copyWith(multiBibleEnabled: enabled));
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
  }
}
