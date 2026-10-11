import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_util.dart';

const _requestTimeout = Duration(seconds: 60);

http.Response _timeoutResponse() {
  logger('Timeout occurred. Please try again later.');
  return http.Response('Timeout occurred', 504);
}

Future<http.Response> _dispatch(
  String method,
  Uri uri,
  Map<String, String> headers,
  String? body,
) {
  return switch (method) {
    'GET' => http.get(uri, headers: headers),
    'POST' => http.post(uri, headers: headers, body: body),
    'PUT' => http.put(uri, headers: headers, body: body),
    'PATCH' => http.patch(uri, headers: headers, body: body),
    'DELETE' => http.delete(uri, headers: headers),
    _ => throw ArgumentError.value(method, 'method', 'Unsupported HTTP method'),
  };
}

Future<http.Response> sendHttpRequest(
  String method,
  String url,
  Map<String, String> headers, {
  dynamic body,
}) async {
  try {
    final uri = Uri.parse(url);
    final encodedBody = body == null ? null : json.encode(body);
    final bodyLog = encodedBody == null ? '' : ' \nJsonData: $encodedBody';
    logger(
      'Api Request [$method]: $url \nHeaders: ${json.encode(headers)}$bodyLog',
    );

    final response = await _dispatch(method, uri, headers, encodedBody)
        .timeout(_requestTimeout, onTimeout: _timeoutResponse);

    logger('Api Response: [${response.statusCode}] ${response.body}');
    return response;
  } on TimeoutException {
    return _timeoutResponse();
  } catch (e) {
    logger('An error occurred during the HTTP request: $e');
    return http.Response('Internal server error', 500);
  }
}
