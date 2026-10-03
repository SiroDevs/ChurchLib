// Dart imports:
import 'dart:async';

// Package imports:
import 'package:http/http.dart';

// Project imports:
import '../../../common/utils/constants/api_constants.dart';
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

  /// Fetch songs by book ids
  Future<Response> getSongsByBooks(String booksId) async {
    return await makeApiGetRequest(
      ApiConstants.songsByBook + booksId,
      {
        'Content-Type': 'application/json',
      },
    );
  }
}
