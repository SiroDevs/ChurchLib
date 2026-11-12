import 'package:churchlib/domain/repos/bible/bible_download_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateCachedChapterCoverage', () {
    test('accepts a download with every chapter cached', () {
      expect(
        () => validateCachedChapterCoverage({'GEN1', 'GEN2'}, {'GEN1', 'GEN2'}),
        returnsNormally,
      );
    });

    test('rejects a download with missing chapters', () {
      expect(
        () => validateCachedChapterCoverage({'GEN1', 'GEN2'}, {'GEN1'}),
        throwsA(isA<StateError>()),
      );
    });
  });
}
