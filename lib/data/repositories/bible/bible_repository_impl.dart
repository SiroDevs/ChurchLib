import 'dart:convert';

import '../../../core/utils/app_util.dart';
import '../../../core/utils/async_semaphore.dart';
import '../../../domain/entities/bible/verse_display.dart';
import '../../models/bible/bible_book.dart';
import '../../models/bible/bible_chapter.dart';
import '../../models/bible/bible_verse_cache.dart';
import '../../models/bible/bible_version.dart';
import '../../sources/local/app_database.dart';
import '../../sources/remote/bible/bible_api_service.dart';
import '../../sources/remote/bible/bible_dtos.dart';
import 'bible_repository.dart';
import 'retry_policy.dart';

/// Same book-fetch concurrency cap Android uses
/// (`BibleRepo.MAX_CONCURRENT_BOOK_BATCHES`).
const _maxConcurrentBookBatches = 20;

class BibleRepositoryImpl implements BibleRepository {
  final AppDatabase _appDB;
  final BibleApiService _service;

  BibleRepositoryImpl(this._appDB, this._service);

  @override
  Future<List<BibleInfoDto>> fetchAvailableBibles() async {
    final groups = await retrying(() => _service.getGroups());
    final results = await Future.wait(
      groups.map((group) async {
        try {
          return await retrying(() => _service.getGroupInfo(group));
        } catch (e) {
          logger("⚠️ Couldn't fetch group '$group', skipping: $e");
          return <BibleInfoDto>[];
        }
      }),
    );
    return results.expand((list) => list).toList();
  }

  Future<String> _resolvePath(String abbr) async {
    final local = await _appDB.bibleVersionsDao.getByAbbr(abbr);
    if (local != null && local.path.trim().isNotEmpty) return local.path;
    return abbr;
  }

  @override
  Future<void> downloadBible(
    String abbr, {
    Future<void> Function(String step, double progress)? onProgress,
  }) async {
    final path = await _resolvePath(abbr);
    logger('▶ Downloading $abbr bible from path=$path');

    Future<void> reportProgress(String step, double progress) async {
      await _appDB.bibleVersionsDao.updateProgress(abbr, progress);
      if (onProgress != null) await onProgress(step, progress);
    }

    try {
      await reportProgress('Fetching books...', 0.05);
      final booksResp = await retrying(() => _service.getBooks(path));
      final bookEntities = <BibleBook>[
        for (var i = 0; i < booksResp.length; i++)
          BibleBook(
            id: booksResp[i].id,
            bibleAbbr: abbr,
            abbreviation: booksResp[i].abbreviation,
            name: booksResp[i].name,
            nameLong: booksResp[i].nameLong,
            sortOrder: i,
          ),
      ];
      await _appDB.bibleBooksDao.insertAll(bookEntities);
      logger('✅ ${bookEntities.length} books saved for $abbr');

      await reportProgress('Fetching chapters...', 0.15);
      final chaptersResp = await retrying(() => _service.getChapters(path));
      final chapterEntities = <BibleChapter>[];
      for (final chapters in chaptersResp.values) {
        for (final dto in chapters) {
          chapterEntities.add(
            BibleChapter(
              id: dto.id,
              bibleAbbr: abbr,
              bookId: dto.bookId,
              number: dto.number,
              reference: dto.reference,
            ),
          );
        }
      }
      await _appDB.bibleChaptersDao.insertAll(chapterEntities);
      logger('✅ ${chapterEntities.length} chapters saved for $abbr');

      final chaptersByBook = <String, List<BibleChapter>>{};
      for (final c in chapterEntities) {
        (chaptersByBook[c.bookId] ??= []).add(c);
      }
      final bookIds = booksResp
          .map((b) => b.id)
          .where((id) => (chaptersByBook[id]?.isNotEmpty ?? false))
          .toList();

      final alreadyCachedChapterIds =
          (await _appDB.bibleVersesDao.getCachedChapterIds(abbr)).toSet();

      await reportProgress('Fetching verses...', 0.25);

      final semaphore = AsyncSemaphore(_maxConcurrentBookBatches);
      var completedBooks = 0;

      await Future.wait(
        bookIds.map((bookId) {
          return semaphore.withPermit(() async {
            try {
              final chaptersForBook = chaptersByBook[bookId] ?? const [];
              final pendingChapters = chaptersForBook
                  .where((c) => !alreadyCachedChapterIds.contains(c.id))
                  .toList();
              if (pendingChapters.isNotEmpty) {
                final verseEntities = await _fetchVersesForBook(
                  abbr,
                  path,
                  bookId,
                  pendingChapters,
                );
                if (verseEntities.isNotEmpty) {
                  await _appDB.bibleVersesDao.insertAll(verseEntities);
                }
              }
            } catch (e) {
              logger('⚠️ Book $bookId failed for $abbr, continuing: $e');
            }

            completedBooks++;
            final fraction = completedBooks / bookIds.length;
            await reportProgress(
              'Fetching verses ($bookId, $completedBooks/${bookIds.length})...',
              0.25 + fraction * 0.7,
            );
          });
        }),
      );

      logger('✅ Verses saved in ${bookIds.length} book batches for $abbr');

      await _appDB.bibleVersionsDao.markDownloaded(abbr);
      if (onProgress != null) await onProgress('Done!', 1.0);
      logger('✅ Download complete for $abbr');
    } catch (e) {
      final existing = await _appDB.bibleVersionsDao.getByAbbr(abbr);
      final lastKnownProgress = existing?.downloadProgress ?? 0.0;
      await _appDB.bibleVersionsDao.markFailed(abbr, lastKnownProgress);
      rethrow;
    }
  }

  Future<List<BibleVerseCache>> _fetchVersesForBook(
    String abbr,
    String path,
    String bookId,
    List<BibleChapter> chapters,
  ) async {
    final verseEntities = <BibleVerseCache>[];
    for (final chapter in chapters) {
      try {
        final content = await retrying(
          () => _service.getVersesForChapter(path, bookId, chapter.number),
        );
        final verses = _extractVerses(content);
        verseEntities.add(
          BibleVerseCache(
            chapterId: chapter.id,
            bibleAbbr: abbr,
            bookId: bookId,
            verseCount: content.verseCount,
            contentJson: jsonEncode(verses.map((v) => v.toJson()).toList()),
            cachedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } catch (e) {
        logger(
          '⚠️ Skipping unparseable chapter $bookId/${chapter.number} for $abbr: $e',
        );
      }
    }
    return verseEntities;
  }

  /// Walks a chapter's content tree, collecting verse text under each
  /// `tag`/"verse" marker into [VerseDisplay]s. Ported field-for-field
  /// from Android's `BibleRepo.extractVerses` — a "verse" tag sets the
  /// current verse number/id, and subsequent "text" nodes (until the next
  /// verse tag) are appended to that verse, since a verse can be split
  /// across several text runs (e.g. around inline formatting).
  List<VerseDisplay> _extractVerses(ChapterContentDto content) {
    final verses = <VerseDisplay>[];
    var currentVerseNumber = 0;

    void walkItems(List<ContentItemDto> items) {
      for (final item in items) {
        if (item.type == 'tag' && item.name == 'verse') {
          currentVerseNumber =
              int.tryParse(item.attrs?['number'] ?? '') ?? currentVerseNumber;
        } else if (item.type == 'text' && item.text != null) {
          final verseId = item.attrs?['verseId'] ?? '';
          final text = item.text!.trim();
          if (verseId.isNotEmpty && text.isNotEmpty && currentVerseNumber > 0) {
            final existingIndex =
                verses.lastIndexWhere((v) => v.verseId == verseId);
            if (existingIndex != -1) {
              verses[existingIndex] = verses[existingIndex]
                  .copyWith(text: '${verses[existingIndex].text} $text');
            } else {
              verses.add(
                VerseDisplay(
                  verseId: verseId,
                  number: currentVerseNumber,
                  text: text,
                  chapterId: content.id,
                  bookId: content.bookId,
                ),
              );
            }
          }
        }
        if (item.items != null) walkItems(item.items!);
      }
    }

    walkItems(content.content);
    verses.sort((a, b) => a.number.compareTo(b.number));
    return verses;
  }

  @override
  Future<List<BibleBook>> getLocalBooks(String abbr) {
    return _appDB.bibleBooksDao.getByBible(abbr);
  }

  @override
  Future<List<BibleChapter>> getLocalChapters(String abbr, String bookId) {
    return _appDB.bibleChaptersDao.getByBook(abbr, bookId);
  }

  @override
  Future<List<VerseDisplay>?> getLocalVerses(
    String abbr,
    String chapterId,
  ) async {
    final entity = await _appDB.bibleVersesDao.getChapter(abbr, chapterId);
    if (entity == null) return null;
    final decoded = jsonDecode(entity.contentJson) as List<dynamic>;
    return decoded
        .map((e) => VerseDisplay.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<VerseDisplay>> searchVerses(String abbr, String query) async {
    final entities = await _appDB.bibleVersesDao.searchInBible(abbr, query);
    final lowerQuery = query.toLowerCase();
    return entities.expand((entity) {
      final decoded = jsonDecode(entity.contentJson) as List<dynamic>;
      final verses = decoded
          .map((e) => VerseDisplay.fromJson(e as Map<String, dynamic>))
          .toList();
      return verses.where((v) => v.text.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<BibleVersion>> getBibles() {
    return _appDB.bibleVersionsDao.getAll();
  }

  @override
  Future<void> saveBibles(List<BibleVersion> versions) {
    return _appDB.bibleVersionsDao.insertAll(versions);
  }

  @override
  Future<void> deleteBible(String abbr) async {
    await _appDB.bibleVersionsDao.deleteByAbbr(abbr);
    await _appDB.bibleBooksDao.deleteByBible(abbr);
    await _appDB.bibleChaptersDao.deleteByBible(abbr);
    await _appDB.bibleVersesDao.deleteByBible(abbr);
  }

  @override
  Future<void> clearBibleContent(String abbr) async {
    await _appDB.bibleBooksDao.deleteByBible(abbr);
    await _appDB.bibleChaptersDao.deleteByBible(abbr);
    await _appDB.bibleVersesDao.deleteByBible(abbr);
    final existing = await _appDB.bibleVersionsDao.getByAbbr(abbr);
    if (existing != null) {
      existing.isDownloaded = false;
      existing.downloadProgress = 0;
      existing.downloadFailed = false;
      await _appDB.bibleVersionsDao.insert(existing);
    }
  }

  @override
  Future<void> markDownloadFailed(String abbr) async {
    final existing = await _appDB.bibleVersionsDao.getByAbbr(abbr);
    await _appDB.bibleVersionsDao.markFailed(
      abbr,
      existing?.downloadProgress ?? 0,
    );
  }

  @override
  Future<void> deleteAllData() async {
    await _appDB.bibleVersionsDao.deleteAll();
    await _appDB.bibleBooksDao.deleteAll();
    await _appDB.bibleChaptersDao.deleteAll();
    await _appDB.bibleVersesDao.deleteAll();
  }
}
