// Dart imports:
import 'dart:async';

// Package imports:
import 'package:http/http.dart';

// Project imports:
import '../../../data/sources/remote/selection_client.dart';

class SongSelectionRepo {
  final _selectionClient = SelectionClient();

  /// Fetch all books
  Future<Response> getBooks() async => await _selectionClient.getBooks();

  /// Fetch  all songs
  Future<Response> getSongs() async => await _selectionClient.getSongs();

  /// Fetch songs by book ids
  Future<Response> getSongsByBooks(String bookIds) async {
    return await _selectionClient.getSongsByBooks(bookIds);
  }
}
