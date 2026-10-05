import 'dart:async';

import 'package:flutter/foundation.dart';

/// Standard go_router adapter: turns a [Stream] into a [ChangeNotifier] so
/// `GoRouter(refreshListenable: ...)` re-runs `redirect` every time the
/// stream emits — here, every time [AuthBloc] emits a new [AuthState].
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
