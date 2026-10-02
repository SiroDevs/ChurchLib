import 'dart:async';
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import '../../../../core/utils/app_util.dart';
import '../../../../core/utils/constants/bible_api_constants.dart';
import '../../../repositories/bible/retry_policy.dart';
import 'bible_dtos.dart';

/// Thin GET client for the BibleLib static JSON API, matching the shape of
/// [ApiConstants]/`api_service.dart`'s SongLib client, but scoped to
/// BibleLib's own base URL and endpoints — ported 1:1 from
/// biblelib-android's `BibleLibService` (Retrofit interface):
///
/// - `info.json`                               -> list of group names
/// - `{group}/info.json`                       -> list of [BibleInfoDto]
/// - `{path}/books.json`                       -> list of [BookDto]
/// - `{path}/chapters.json`                    -> bookId -> [ChapterDto]
/// - `{path}/verses/{bookId}/{chapter}.json`   -> [ChapterContentDto]
class BibleApiService {
  Future<dynamic> _getJson(String path) async {
    final endpoint = '${BibleApiConstants.bibleApi}/$path';
    logger('BibleLib Api Request [GET]: $endpoint');

    final response = await http.get(Uri.parse(endpoint)).timeout(
      const Duration(seconds: 60),
      onTimeout: () => http.Response('Timeout occurred', 504),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final retryAfterHeader = response.headers['retry-after'];
      throw classifyHttpFailure(
        response.statusCode,
        retryAfterSeconds: retryAfterHeader != null
            ? int.tryParse(retryAfterHeader)
            : null,
      );
    }

    return jsonDecode(response.body);
  }

  Future<List<String>> getGroups() async {
    final json = await _getJson('info.json');
    return (json as List<dynamic>).map((e) => e as String).toList();
  }

  Future<List<BibleInfoDto>> getGroupInfo(String group) async {
    final json = await _getJson('$group/info.json');
    return (json as List<dynamic>)
        .map((e) => BibleInfoDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookDto>> getBooks(String path) async {
    final json = await _getJson('$path/books.json');
    return (json as List<dynamic>)
        .map((e) => BookDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `{path}/chapters.json` is a map of bookId -> list of chapters, not a
  /// flat list — kept as-is to match the source data shape.
  Future<Map<String, List<ChapterDto>>> getChapters(String path) async {
    final json = await _getJson('$path/chapters.json') as Map<String, dynamic>;
    return json.map(
      (bookId, chapters) => MapEntry(
        bookId,
        (chapters as List<dynamic>)
            .map((e) => ChapterDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  Future<ChapterContentDto> getVersesForChapter(
    String path,
    String bookId,
    String chapter,
  ) async {
    final json = await _getJson('$path/verses/$bookId/$chapter.json');
    return ChapterContentDto.fromJson(json as Map<String, dynamic>);
  }
}
