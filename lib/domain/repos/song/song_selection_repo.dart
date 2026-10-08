// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:http/http.dart';

// Project imports:
import '../../../common/utils/constants/api_constants.dart';
import '../../../data/models/song/song.dart';
import '../../../data/models/song/songbook.dart';
import '../../../data/sources/remote/song/selection_client.dart';

class SongApiException implements Exception {
  const SongApiException(this.statusCode);
  final int statusCode;

  @override
  String toString() => 'SongApiException($statusCode)';
}

class SongSelectionRepo {
  final _selectionClient = SelectionClient();

  Future<Response> getBooks() async => await _selectionClient.getBooks();

  Future<Response> getSongs() async => await _selectionClient.getSongs();

  Future<Response> getSongsByBooks(
    String bookIds, {
    int page = 1,
    int limit = ApiConstants.songsPageLimit,
  }) async {
    return await _selectionClient.getSongsByBooks(
      bookIds,
      page: page,
      limit: limit,
    );
  }

  Future<List<SongBook>> fetchBooks() async {
    final resp = await _selectionClient.getBooks();
    if (resp.statusCode != 200) throw SongApiException(resp.statusCode);

    final decoded = jsonDecode(resp.body);
    final list = decoded is Map ? decoded['data'] : decoded;
    return [
      for (final item in list as List)
        SongBook.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<List<Song>> fetchSongsByBooks(
    String bookIds, {
    void Function(int fetched, int? total)? onPage,
  }) async {
    final songs = <Song>[];
    var page = 1;
    while (true) {
      final resp = await _selectionClient.getSongsByBooks(
        bookIds,
        page: page,
        limit: ApiConstants.songsPageLimit,
      );
      if (resp.statusCode != 200) throw SongApiException(resp.statusCode);

      final decoded = jsonDecode(resp.body);
      final List data;
      var hasMore = false;
      int? total;
      if (decoded is List) {
        data = decoded;
      } else {
        data = decoded['data'] as List;
        final pagination = decoded['pagination'];
        if (pagination is Map) {
          hasMore = pagination['hasMore'] == true;
          total = (pagination['total'] as num?)?.toInt();
        }
      }

      songs.addAll([
        for (final item in data)
          Song.fromJson(Map<String, dynamic>.from(item as Map)),
      ]);
      onPage?.call(songs.length, total);

      if (!hasMore || data.isEmpty) break;
      page++;
    }
    return songs;
  }
}
