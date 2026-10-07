// Dart imports:
import 'dart:async';

// Package imports:
import 'package:http/http.dart';

// Project imports:
import '../../../../common/utils/constants/api_constants.dart';
import 'api_service.dart';

class SelectionClient {
  Future<Response> getBooks() async {
    return await makeApiGetRequest(
      ApiConstants.books,
      {
        'Content-Type': 'application/json',
      },
    );
  }

  Future<Response> getSongs() async {
    return await makeApiGetRequest(
      ApiConstants.songs,
      {
        'Content-Type': 'application/json',
      },
    );
  }

  Future<Response> getSongsByBooks(
    String booksId, {
    int page = 1,
    int limit = ApiConstants.songsPageLimit,
  }) async {
    return await makeApiGetRequest(
      '${ApiConstants.songsByBook}$booksId?page=$page&limit=$limit',
      {
        'Content-Type': 'application/json',
      },
    );
  }
}
