import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:churchlib/common/utils/network/http_utils.dart';

void main() {
  test('returns HTTP responses from the injected client', () async {
    final client = MockClient((_) async => http.Response('ok', 200));

    final response = await sendHttpRequest(
      'GET',
      'https://example.test/songs',
      const {},
      client: client,
    );

    expect(response.statusCode, 200);
    expect(response.body, 'ok');
    client.close();
  });

  test('throws a typed error for transport failures', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('offline'),
    );

    await expectLater(
      sendHttpRequest(
        'GET',
        'https://example.test/songs',
        const {},
        client: client,
      ),
      throwsA(
        isA<HttpRequestFailure>().having(
          (failure) => failure.kind,
          'kind',
          HttpRequestFailureKind.transport,
        ),
      ),
    );
    client.close();
  });
}
