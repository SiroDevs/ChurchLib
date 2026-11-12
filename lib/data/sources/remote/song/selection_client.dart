// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import '../../../../common/constants/api_constants.dart';
import 'api_service.dart';

class SelectionClient {
  SelectionClient({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<http.Response> getBooks() async {
    return await makeApiGetRequest(ApiConstants.books, {
      'Content-Type': 'application/json',
    }, client: _client);
  }

  Future<http.Response> getSongs() async {
    return await makeApiGetRequest(ApiConstants.songs, {
      'Content-Type': 'application/json',
    }, client: _client);
  }

  Future<http.Response> getSongsByBooks(
    String booksId, {
    int page = 1,
    int limit = ApiConstants.songsPageLimit,
  }) async {
    return await makeApiGetRequest(
      '${ApiConstants.songsByBook}$booksId?page=$page&limit=$limit',
      {'Content-Type': 'application/json'},
      client: _client,
    );
  }
}
