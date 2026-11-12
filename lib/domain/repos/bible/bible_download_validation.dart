void validateCachedChapterCoverage(
  Set<String> expectedChapterIds,
  Set<String> cachedChapterIds,
) {
  final missingChapterIds = expectedChapterIds.difference(cachedChapterIds);
  if (missingChapterIds.isNotEmpty) {
    throw StateError(
      'Bible download is missing ${missingChapterIds.length} chapters.',
    );
  }
}
