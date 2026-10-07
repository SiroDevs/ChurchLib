// Dart imports:
import 'dart:async';
import 'dart:math';

sealed class DownloadFailure implements Exception {
  final String message;
  final Object? cause;

  const DownloadFailure(this.message, [this.cause]);

  bool get isPermanent => this is NotFoundFailure || this is UnauthorizedFailure;

  @override
  String toString() => 'DownloadFailure: $message'
      '${cause != null ? ' (cause: $cause)' : ''}';
}

class ServerErrorFailure extends DownloadFailure {
  final int code;
  ServerErrorFailure(this.code, [Object? cause])
      : super('Server error $code', cause);
}

class NetworkFailure extends DownloadFailure {
  NetworkFailure([Object? cause]) : super('Network error', cause);
}

class RateLimitedFailure extends DownloadFailure {
  final int retryAfterMillis;
  RateLimitedFailure(this.retryAfterMillis, [Object? cause])
      : super('Rate limited', cause);
}

class NotFoundFailure extends DownloadFailure {
  NotFoundFailure([Object? cause]) : super('Not found', cause);
}

class UnauthorizedFailure extends DownloadFailure {
  UnauthorizedFailure([Object? cause]) : super('Unauthorized', cause);
}

class UnknownFailure extends DownloadFailure {
  UnknownFailure([Object? cause]) : super('Unknown error', cause);
}

DownloadFailure classifyHttpFailure(int statusCode, {int? retryAfterSeconds}) {
  switch (statusCode) {
    case 404:
      return NotFoundFailure();
    case 401:
    case 403:
      return UnauthorizedFailure();
    case 429:
      return RateLimitedFailure(
        (retryAfterSeconds ?? _defaultRateLimitWaitSeconds) * 1000,
      );
    default:
      if (statusCode >= 500 && statusCode < 600) {
        return ServerErrorFailure(statusCode);
      }
      return UnknownFailure();
  }
}

const _defaultMaxAttempts = 4;
const _defaultInitialDelayMs = 1000;
const _defaultMaxDelayMs = 20000;
const _defaultRateLimitWaitSeconds = 5;

Future<T> retrying<T>(
  Future<T> Function() block, {
  int maxAttempts = _defaultMaxAttempts,
  int initialDelayMillis = _defaultInitialDelayMs,
  int maxDelayMillis = _defaultMaxDelayMs,
}) async {
  var attempt = 0;
  var backoffMs = initialDelayMillis;

  while (true) {
    attempt++;
    try {
      return await block();
    } catch (t) {
      final failure = t is DownloadFailure ? t : NetworkFailure(t);

      if (failure.isPermanent || attempt >= maxAttempts) throw failure;

      final waitMs = switch (failure) {
        RateLimitedFailure(:final retryAfterMillis) => retryAfterMillis,
        _ => backoffMs,
      };
      if (failure is! RateLimitedFailure) {
        backoffMs = min(backoffMs * 2, maxDelayMillis);
      }
      await Future.delayed(Duration(milliseconds: waitMs));
    }
  }
}
