import 'dart:async';
import 'dart:collection';

/// Bounds how many `withPermit` blocks run concurrently, mirroring
/// Kotlin's `kotlinx.coroutines.sync.Semaphore` usage in Android's
/// `BibleRepo.downloadBible` (`Semaphore(MAX_CONCURRENT_BOOK_BATCHES)`).
/// No external package needed — Dart has no built-in equivalent, but the
/// pattern is simple: a counter of free permits and a FIFO queue of
/// waiters.
class AsyncSemaphore {
  int _available;
  final Queue<Completer<void>> _waiters = Queue();

  AsyncSemaphore(this._available);

  Future<T> withPermit<T>(Future<T> Function() action) async {
    await _acquire();
    try {
      return await action();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() {
    if (_available > 0) {
      _available--;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  void _release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    } else {
      _available++;
    }
  }
}
