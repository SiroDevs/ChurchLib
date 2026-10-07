// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/constants/api_constants.dart';
import '../../../../domain/repos/bible/retry_policy.dart';
import 'bible_dtos.dart';

class BibleApiService {
  Future<dynamic> _getJson(String path) async {
    final endpoint = '${ApiConstants.bibleApi}/$path';
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
