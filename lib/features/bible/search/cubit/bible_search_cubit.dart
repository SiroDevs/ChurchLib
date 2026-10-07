// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/constants/pref_constants.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../data/models/shared/search_entry.dart';
import '../../../../domain/entities/bible/verse_display.dart';
import '../../../../domain/repos/bible/bible_repo.dart';
import '../../../../domain/repos/bible/bible_tracking_repo.dart';
import '../../../../domain/repos/pref_repo.dart';

part 'bible_search_state.dart';

class BibleSearchCubit extends Cubit<BibleSearchState> {
  final _bibleRepo = getIt<BibleRepo>();
  final _tracking = getIt<BibleTrackingRepo>();
  final _prefs = getIt<PrefRepo>();

  Timer? _debounce;
  int _searchToken = 0;

  BibleSearchCubit() : super(const BibleSearchState()) {
    _loadBibles();
    _loadHistory();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> _loadBibles() async {
    final downloaded =
        (await _bibleRepo.getBibles()).where((b) => b.isDownloaded).toList();
    final primary = _prefs.getPrefString(PrefConstants.biblePrimaryKey);
    final abbr = downloaded.any((b) => b.abbreviation == primary)
        ? primary
        : (downloaded.isEmpty ? '' : downloaded.first.abbreviation);
    emit(state.copyWith(bibles: downloaded, selectedAbbr: abbr));
    await _loadBookNames(abbr);
  }

  Future<void> _loadBookNames(String abbr) async {
    final names = abbr.isEmpty
        ? <String, String>{}
        : {for (final b in await _bibleRepo.getLocalBooks(abbr)) b.id: b.name};
    emit(state.copyWith(bookNames: names));
  }

  Future<void> _loadHistory() async {
    final history = await _tracking.getSearchHistory();
    emit(state.copyWith(history: history));
  }

  void onQueryChanged(String qry) {
    emit(state.copyWith(query: qry));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (qry.length >= 3) {
        _performSearch(qry);
      } else {
        emit(state.copyWith(results: []));
      }
    });
  }

  Future<void> _performSearch(String qry) async {
    final token = ++_searchToken;
    final abbr = state.selectedAbbr.isEmpty
        ? _prefs.getPrefString(PrefConstants.biblePrimaryKey)
        : state.selectedAbbr;
    emit(state.copyWith(isSearching: true));
    try {
      final results = await _bibleRepo.searchVerses(abbr, qry);
      if (isClosed || token != _searchToken) return;
      emit(state.copyWith(results: results));
      if (results.isNotEmpty) {
        await _tracking.recordSearch(qry);
        await _loadHistory();
      }
    } catch (e) {
      logger('Bible search failed: $e');
      if (!isClosed && token == _searchToken) emit(state.copyWith(results: []));
    } finally {
      if (!isClosed && token == _searchToken) {
        emit(state.copyWith(isSearching: false));
      }
    }
  }

  void selectBible(String abbr) {
    if (abbr == state.selectedAbbr) return;
    emit(state.copyWith(selectedAbbr: abbr));
    _loadBookNames(abbr);
    if (state.query.length >= 3) _performSearch(state.query);
  }

  void searchFromHistory(String qry) {
    emit(state.copyWith(query: qry));
    _performSearch(qry);
  }

  Future<void> clearHistory() async {
    await _tracking.clearSearchHistory();
    emit(state.copyWith(history: []));
  }

  void clearQuery() {
    _debounce?.cancel();
    emit(state.copyWith(query: '', results: []));
  }
}
