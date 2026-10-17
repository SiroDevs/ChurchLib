// Flutter imports:
import 'package:flutter/foundation.dart';

class BibleDownloadCancelled implements Exception {
  const BibleDownloadCancelled();
}

class BibleDownloadTracker extends ChangeNotifier {
  final Map<String, double> _progress = {};
  final Set<String> _cancelled = {};

  Map<String, double> get progress => Map.unmodifiable(_progress);

  bool isActive(String abbr) => _progress.containsKey(abbr);

  bool isCancelled(String abbr) => _cancelled.contains(abbr);

  void start(String abbr) {
    _cancelled.remove(abbr);
    _progress[abbr] = _progress[abbr] ?? 0;
    notifyListeners();
  }

  void update(String abbr, double value) {
    if (!_progress.containsKey(abbr)) return;
    _progress[abbr] = value;
    notifyListeners();
  }

  void cancel(String abbr) {
    if (isActive(abbr)) _cancelled.add(abbr);
  }

  void throwIfCancelled(String abbr) {
    if (isCancelled(abbr)) throw const BibleDownloadCancelled();
  }

  void finish(String abbr) {
    _progress.remove(abbr);
    _cancelled.remove(abbr);
    notifyListeners();
  }
}

final bibleDownloads = BibleDownloadTracker();
