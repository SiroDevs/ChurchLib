// Dart imports:
import 'dart:async';

// Package imports:
import 'package:http/http.dart';

// Project imports:
import '../../../../common/utils/constants/api_constants.dart';
import 'api_service.dart';

class SelectionClient {
  /// Fetch all the books
  Future<Response> getBooks() async {
    return await makeApiGetRequest(
      ApiConstants.books,
      {
        'Content-Type': 'application/json',
      },
    );
  }

  /// Fetch all songs
  Future<Response> getSongs() async {
    return await makeApiGetRequest(
      ApiConstants.songs,
      {
        'Content-Type': 'application/json',
      },
    );
  }

  /// Fetch one page of songs for the given book ids (comma separated
  /// `bookId`s). The v2 API answers with
  /// `{data: [...], pagination: {page, limit, total, totalPages, hasMore}}`.
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
