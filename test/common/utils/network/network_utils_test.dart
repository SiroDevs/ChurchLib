import 'package:churchlib/common/utils/network/network_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkUtil.hasNetworkConnection', () {
    test('returns false when there is no connection', () {
      expect(
        NetworkUtil.hasNetworkConnection(const [ConnectivityResult.none]),
        isFalse,
      );
      expect(NetworkUtil.hasNetworkConnection(const []), isFalse);
    });

    test('returns true for an available network transport', () {
      expect(
        NetworkUtil.hasNetworkConnection(const [ConnectivityResult.wifi]),
        isTrue,
      );
      expect(
        NetworkUtil.hasNetworkConnection(const [ConnectivityResult.mobile]),
        isTrue,
      );
    });
  });
}
