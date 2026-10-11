import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../../../../common/constants/api_constants.dart';
import '../../../../common/utils/network/http_utils.dart';

Future<bool> isConnectedToInternet() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) return false;

    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<http.Response> makeApiGetRequest(
  String endpoint,
  Map<String, String> headers,
) =>
    sendHttpRequest('GET', ApiConstants.songliveApi + endpoint, headers);

Future<http.Response> makeApiDeleteRequest(
  String endpoint,
  Map<String, String> headers,
) =>
    sendHttpRequest('DELETE', ApiConstants.songliveApi + endpoint, headers);

Future<http.Response> makeApiPostRequest(
  String endpoint,
  Map<String, String> headers,
  dynamic requestBody,
) =>
    sendHttpRequest(
      'POST',
      ApiConstants.songliveApi + endpoint,
      headers,
      body: requestBody,
    );

Future<http.Response> makeApiPutRequest(
  String endpoint,
  Map<String, String> headers,
  dynamic requestBody,
) =>
    sendHttpRequest(
      'PUT',
      ApiConstants.songliveApi + endpoint,
      headers,
      body: requestBody,
    );

Future<http.Response> makeApiPatchRequest(
  String endpoint,
  Map<String, String> headers,
  dynamic requestBody,
) =>
    sendHttpRequest(
      'PATCH',
      ApiConstants.songliveApi + endpoint,
      headers,
      body: requestBody,
    );
