// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import '../logging/app_logger.dart';

const _requestTimeout = Duration(seconds: 60);
final http.Client _defaultClient = http.Client();

enum HttpRequestFailureKind { timeout, transport }

class HttpRequestFailure implements Exception {
  const HttpRequestFailure(this.kind, this.cause);

  final HttpRequestFailureKind kind;
  final Object cause;

  @override
  String toString() => 'HTTP request failed: $kind';
}

Future<http.Response> _dispatch(
  http.Client client,
  String method,
  Uri uri,
  Map<String, String> headers,
  String? body,
) {
  return switch (method) {
    'GET' => client.get(uri, headers: headers),
    'POST' => client.post(uri, headers: headers, body: body),
    'PUT' => client.put(uri, headers: headers, body: body),
    'PATCH' => client.patch(uri, headers: headers, body: body),
    'DELETE' => client.delete(uri, headers: headers),
    _ => throw ArgumentError.value(method, 'method', 'Unsupported HTTP method'),
  };
}

Future<http.Response> sendHttpRequest(
  String method,
  String url,
  Map<String, String> headers, {
  dynamic body,
  http.Client? client,
}) async {
  final uri = Uri.parse(url);
  final encodedBody = body == null ? null : json.encode(body);
  logger('HTTP request [$method] ${uri.origin}');

  try {
    final response = await _dispatch(
      client ?? _defaultClient,
      method,
      uri,
      headers,
      encodedBody,
    ).timeout(_requestTimeout);
    logger('HTTP response [${response.statusCode}] ${uri.origin}');
    return response;
  } on TimeoutException catch (error) {
    logger('HTTP request timed out: ${uri.origin}');
    throw HttpRequestFailure(HttpRequestFailureKind.timeout, error);
  } on SocketException catch (error) {
    logger('HTTP transport failed: ${uri.origin}');
    throw HttpRequestFailure(HttpRequestFailureKind.transport, error);
  } on HandshakeException catch (error) {
    logger('HTTP transport failed: ${uri.origin}');
    throw HttpRequestFailure(HttpRequestFailureKind.transport, error);
  } on http.ClientException catch (error) {
    logger('HTTP transport failed: ${uri.origin}');
    throw HttpRequestFailure(HttpRequestFailureKind.transport, error);
  }
}
