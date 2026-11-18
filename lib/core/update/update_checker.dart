// Dart imports:
import 'dart:convert';
import 'dart:math';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import '../../common/utils/logging/app_logger.dart';
import 'release_asset.dart';

export 'release_asset.dart';

const String kRepo = 'SiroDevs/ChurchLib';
const String kRepoUrl = 'https://github.com/$kRepo';
const String kRepoReleasesUrl = '$kRepoUrl/releases/latest';
const String _apiLatestUrl =
    'https://api.github.com/repos/$kRepo/releases/latest';

/// Keeps an optional build number while removing a tag prefix and prerelease suffix.
String? normalizeVersion(String tag) {
  final match = RegExp(r'^v?(\d+(?:\.\d+)*)(?:-[0-9A-Za-z.-]+)?(?:\+(\d+))?$')
      .firstMatch(tag);
  if (match == null) return null;
  final version = match.group(1)!;
  final buildNumber = match.group(2);
  return buildNumber == null ? version : '$version+$buildNumber';
}

bool isNewerVersion(String latest, String current) {
  List<int> parts(String version) => version
      .split('+')
      .first
      .split('.')
      .map((part) => int.tryParse(part) ?? 0)
      .toList();
  int buildNumber(String version) {
    final separator = version.indexOf('+');
    return separator < 0
        ? 0
        : int.tryParse(version.substring(separator + 1)) ?? 0;
  }

  final latestParts = parts(latest), currentParts = parts(current);
  for (
    var index = 0;
    index < max(latestParts.length, currentParts.length);
    index++
  ) {
    final latestPart = index < latestParts.length ? latestParts[index] : 0;
    final currentPart = index < currentParts.length ? currentParts[index] : 0;
    if (latestPart != currentPart) return latestPart > currentPart;
  }
  return buildNumber(latest) > buildNumber(current);
}

/// The newest published (non-draft, non-prerelease) GitHub release.
/// Reads the real asset list from the API; if the API is unavailable (rate limit, offline proxy)
/// it falls back to the /releases/latest redirect and the known file names.
Future<ReleaseInfo?> fetchLatestRelease() async =>
    await _fromApi() ?? await _fromRedirect();

Future<ReleaseInfo?> _fromApi() async {
  try {
    final response = await http
        .get(
          Uri.parse(_apiLatestUrl),
          headers: const {'Accept': 'application/vnd.github+json'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      logger('Update check: GitHub API answered ${response.statusCode}');
      return null;
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final version = normalizeVersion('${json['tag_name']}');
    if (version == null) return null;
    final assets = [
      for (final a in (json['assets'] as List? ?? const []))
        ReleaseAsset('${a['name']}', '${a['browser_download_url']}'),
    ];
    return ReleaseInfo(
      version: version,
      pageUrl: '${json['html_url'] ?? kRepoReleasesUrl}',
      assets: assets,
    );
  } catch (e) {
    logger('Update check (API) failed: $e');
    return null;
  }
}

Future<ReleaseInfo?> _fromRedirect() async {
  final client = http.Client();
  try {
    final request = http.Request('HEAD', Uri.parse(kRepoReleasesUrl))
      ..followRedirects = false;
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 15));
    final location = response.headers['location'] ?? '';
    final tag = RegExp(r'/releases/tag/([^/?#]+)$')
        .firstMatch(location)
        ?.group(1);
    if (tag == null) return null;
    final decoded = Uri.decodeComponent(tag);
    final version = normalizeVersion(decoded);
    if (version == null) return null;
    final base = '$kRepoUrl/releases/download/$decoded';
    return ReleaseInfo(
      version: version,
      pageUrl: '$kRepoUrl/releases/tag/$decoded',
      assets: [
        for (final name in knownAssetNames(version))
          ReleaseAsset(name, '$base/$name'),
      ],
    );
  } catch (e) {
    logger('Update check (redirect) failed: $e');
    return null;
  } finally {
    client.close();
  }
}
