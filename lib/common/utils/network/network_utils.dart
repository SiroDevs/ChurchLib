// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtil {
  static final Connectivity _connectivity = Connectivity();

  static bool hasNetworkConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  static Future<bool> hasNetworkConnectionNow() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return hasNetworkConnection(connectivityResult);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasNetworkConnectionWithRetry({
    int retryCount = 2,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < retryCount; i++) {
      if (await hasNetworkConnectionNow()) {
        return true;
      }
      if (i < retryCount - 1) {
        await Future.delayed(delay);
      }
    }
    return false;
  }

  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      hasNetworkConnection,
    );
  }
}
