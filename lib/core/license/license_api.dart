import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'license_config.dart';
import 'license_models.dart';

class LicenseApiException implements Exception {
  const LicenseApiException(this.message, {this.offline = false});

  final String message;

  /// The server could not be reached (as opposed to rejecting the request).
  final bool offline;

  @override
  String toString() => message;
}

/// Talks to the admin portal's /api/v1 endpoints.
///
/// Requests and responses are deliberately not logged: they carry tokens and
/// payment details.
class LicenseApi {
  LicenseApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? LicenseConfig.apiBaseUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  static String get _platform {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static String _clip(String value, int max) =>
      value.length <= max ? value : value.substring(0, min(max, value.length));

  /// First call starts the free trial. Later calls refresh the signed status.
  Future<LicenseResponse> checkIn({
    required String machineId,
    required String appVersion,
  }) {
    return _post('/api/v1/checkin', {
      'machineId': machineId,
      'platform': _platform,
      'osVersion': _clip(Platform.operatingSystemVersion, 120),
      'appVersion': _clip(appVersion, 32),
      'locale': _clip(Platform.localeName, 16),
    });
  }

  /// [method] is 'mpesa' or 'paypal'. [reference] is the M-Pesa code or the
  /// PayPal transaction id.
  Future<LicenseResponse> submitPayment({
    required String machineId,
    required String method,
    required String reference,
    required String payerName,
    required String payerPhone,
  }) {
    return _post('/api/v1/payments', {
      'machineId': machineId,
      'method': method,
      'reference': reference,
      'payerName': payerName,
      'payerPhone': payerPhone,
    });
  }

  /// Attach a license that was released from another computer.
  Future<LicenseResponse> redeem({
    required String machineId,
    required String licenseKey,
  }) {
    return _post('/api/v1/redeem', {
      'machineId': machineId,
      'licenseKey': licenseKey,
    });
  }

  /// Free this computer's license so it can be used elsewhere.
  Future<LicenseResponse> release({required String machineId}) {
    return _post('/api/v1/release', {'machineId': machineId});
  }

  Future<LicenseResponse> _post(String path, Map<String, dynamic> body) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(LicenseConfig.requestTimeout);
    } on TimeoutException {
      throw const LicenseApiException(
        'The license server took too long to answer.',
        offline: true,
      );
    } on SocketException {
      throw const LicenseApiException(
        'Could not reach the license server. Check your internet connection.',
        offline: true,
      );
    } on http.ClientException {
      throw const LicenseApiException(
        'Could not reach the license server. Check your internet connection.',
        offline: true,
      );
    } on HandshakeException {
      throw const LicenseApiException(
        'A secure connection to the license server could not be made. '
        "Check your computer's date and time.",
        offline: true,
      );
    }

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {
      // not JSON: handled below
    }

    if (json == null) {
      throw const LicenseApiException(
        'The license server is not available right now. Try again later.',
        offline: true,
      );
    }
    if (json['ok'] == true && json['data'] is Map<String, dynamic>) {
      try {
        return LicenseResponse.fromJson(json['data'] as Map<String, dynamic>);
      } catch (_) {
        throw const LicenseApiException(
          'The license server sent an answer the app could not read.',
        );
      }
    }
    throw LicenseApiException(
      (json['error'] as String?) ?? 'The request was not accepted.',
      offline: response.statusCode >= 500,
    );
  }

  void close() => _client.close();
}
