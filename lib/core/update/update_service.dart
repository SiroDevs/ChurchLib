// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'update_release.dart';
import 'update_notification_service.dart';

/// Downloads release installers and verifies them against the published checksums.
class UpdateService {
  final HttpClient _http = HttpClient()..userAgent = 'ChurchLib';
  final UpdateNotificationService _notifications = UpdateNotificationService();

  /// Closes the release connection when the application exits.
  void dispose() => _http.close(force: true);

  /// Prepares operating-system notification support.
  Future<void> initialize(String openReleaseAction) =>
      _notifications.initialize(openReleaseAction);

  /// Downloads and verifies the selected release installer.
  Future<File> download(UpdateRelease release) async {
    if (release.assetName.isEmpty ||
        release.assetName.contains('/') ||
        release.assetName.contains('\\')) {
      throw const FormatException('Release asset name is invalid.');
    }
    _requireGitHubUrl(release.assetUrl);
    _requireGitHubUrl(release.checksumUrl);
    final directory = await getApplicationSupportDirectory();
    final updatesDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}updates',
    );
    await updatesDirectory.create(recursive: true);
    final file = File(
      '${updatesDirectory.path}${Platform.pathSeparator}${release.assetName}',
    );
    final expectedHash = await _checksumFor(
      Uri.parse(release.checksumUrl),
      release.assetName,
    );
    if (expectedHash == null) {
      throw const FormatException('Release checksum was not published.');
    }
    if (await file.exists() && await _matchesHash(file, expectedHash)) {
      return file;
    }

    try {
      final request = await _http.getUrl(Uri.parse(release.assetUrl));
      final response = await request.close().timeout(
        const Duration(minutes: 5),
      );
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Release asset returned ${response.statusCode}.');
      }
      await response.pipe(file.openWrite());
      if (!await _matchesHash(file, expectedHash)) {
        throw const FormatException(
          'Downloaded release checksum did not match.',
        );
      }
      return file;
    } on Object {
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  /// Shows an update notification with a link to its GitHub release.
  Future<void> showNotification(String title, String body, String url) =>
      _notifications.show(title, body, url);

  /// Finds the checksum entry for the selected installer.
  Future<String?> _checksumFor(Uri checksumUri, String assetName) async {
    final request = await _http.getUrl(checksumUri);
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != HttpStatus.ok) return null;
    final manifest = await response.transform(utf8.decoder).join();
    for (final line in manifest.split('\n')) {
      final match = RegExp(r'^([a-fA-F0-9]{64})\s+\*?(.+)$').firstMatch(line);
      if (match?.group(2) == assetName) return match!.group(1)!.toLowerCase();
    }
    return null;
  }

  /// Confirms that a file matches its published SHA-256 digest.
  Future<bool> _matchesHash(File file, String expected) async {
    final actual = await sha256.bind(file.openRead()).first;
    return actual.toString() == expected;
  }

  /// Rejects release URLs that are not hosted on GitHub.
  void _requireGitHubUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri?.scheme != 'https' || uri?.host != 'github.com') {
      throw const FormatException('Release URLs must be hosted on GitHub.');
    }
  }
}
