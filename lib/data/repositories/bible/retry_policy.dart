import 'dart:async';
import 'dart:math';

/// Classified outcome of a failed BibleLib network call, so callers
/// (download orchestration, UI) can decide whether to retry or surface a
/// permanent failure, without re-checking HTTP codes everywhere. Ported
/// from biblelib-android's `DownloadFailure` sealed class.
sealed class DownloadFailure implements Exception {
  final String message;
  final Object? cause;

  const DownloadFailure(this.message, [this.cause]);

  /// True for failures where retrying is pointless — ported from
  /// Android's `DownloadFailure.isPermanent`.
  bool get isPermanent => this is NotFoundFailure || this is UnauthorizedFailure;

  @override
  String toString() => 'DownloadFailure: $message'
      '${cause != null ? ' (cause: $cause)' : ''}';
}

/// 500 / 502 / 503 / other 5xx. Transient — safe to retry with backoff.
class ServerErrorFailure extends DownloadFailure {
  final int code;
  ServerErrorFailure(this.code, [Object? cause])
      : super('Server error $code', cause);
}

/// Connect/read timeouts, DNS failures, dropped connections. Safe to retry.
class NetworkFailure extends DownloadFailure {
  NetworkFailure([Object? cause]) : super('Network error', cause);
}

/// 429 — must back off for at least [retryAfterMillis] before retrying.
class RateLimitedFailure extends DownloadFailure {
  final int retryAfterMillis;
  RateLimitedFailure(this.retryAfterMillis, [Object? cause])
      : super('Rate limited', cause);
}

/// 404 — the resource doesn't exist. Retrying won't help; fail fast.
class NotFoundFailure extends DownloadFailure {
  NotFoundFailure([Object? cause]) : super('Not found', cause);
}

/// 401 / 403 — needs re-authentication. Not retryable on its own.
class UnauthorizedFailure extends DownloadFailure {
  UnauthorizedFailure([Object? cause]) : super('Unauthorized', cause);
}

/// Anything else — treated conservatively as retryable a limited number
/// of times.
class UnknownFailure extends DownloadFailure {
  UnknownFailure([Object? cause]) : super('Unknown error', cause);
}

/// Classifies an HTTP status code into a [DownloadFailure], mirroring
/// Android's `RetryPolicy.classify` for the `HttpException` branch.
/// [retryAfterSeconds] comes from a 429 response's `Retry-After` header,
/// when present.
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

/// Runs [block], retrying on transient failures with exponential backoff.
/// Rethrows the classified [DownloadFailure] once attempts are exhausted
/// or the failure is permanent (404 / 401 / 403). Ported from Android's
/// `RetryPolicy.retrying`.
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
