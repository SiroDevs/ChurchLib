// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../data/models/shared/history_entry.dart';
import '../../../../data/models/shared/search_entry.dart';
import '../../../../domain/repos/bible/bible_tracking_repo.dart';

part 'bible_history_state.dart';

class BibleHistoryCubit extends Cubit<BibleHistoryState> {
  final _tracking = getIt<BibleTrackingRepo>();

  BibleHistoryCubit() : super(const BibleHistoryState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final reading = await _tracking.getReadingHistory();
    final searches = await _tracking.getSearchHistory();
    emit(state.copyWith(
      isLoading: false,
      reading: _groupByDate(reading),
      searches: searches,
    ));
  }

  List<HistoryGroup> _groupByDate(List<HistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final fmt = DateFormat('MMMM d, yyyy');

    final groups = <String, List<HistoryEntry>>{};
    for (final e in entries) {
      final d = DateTime.fromMillisecondsSinceEpoch(e.occurredAt);
      final day = DateTime(d.year, d.month, d.day);
      final label = day == today
          ? 'Today'
          : (day == yesterday ? 'Yesterday' : fmt.format(d));
      (groups[label] ??= []).add(e);
    }
    return [for (final e in groups.entries) HistoryGroup(e.key, e.value)];
  }

  Future<void> clearReading() async {
    await _tracking.clearHistory();
    await load();
  }

  Future<void> clearSearches() async {
    await _tracking.clearSearchHistory();
    await load();
  }
}
