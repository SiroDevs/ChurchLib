// Dart imports:
import 'dart:async';
import 'dart:collection';

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
