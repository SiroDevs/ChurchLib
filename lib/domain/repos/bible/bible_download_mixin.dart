part of 'bible_repo_impl.dart';

mixin BibleDownloadMixin {
  AppDatabase get _appDB;
  BibleApiService get _service;

  Future<String> _resolvePath(String abbr) async {
    final local = await _appDB.bibleVersionsDao.getByAbbr(abbr);
    if (local != null && local.path.trim().isNotEmpty) return local.path;
    return abbr;
  }

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
              logger('⚠️ SongBook $bookId failed for $abbr, continuing: $e');
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
}
