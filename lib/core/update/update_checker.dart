// Dart imports:
import 'dart:convert';
import 'dart:math';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import '../../common/utils/formatting/app_util.dart';
import 'release_asset.dart';

export 'release_asset.dart';

const String kRepo = 'SiroDevs/ChurchLib';
const String kRepoUrl = 'https://github.com/$kRepo';
const String kRepoReleasesUrl = '$kRepoUrl/releases/latest';
const String _apiLatestUrl = 'https://api.github.com/repos/$kRepo/releases/latest';

/// "v1.0.4+12" -> "1.0.4"; "1.1.0-beta.1" -> "1.1.0"
String? normalizeVersion(String tag) =>
    RegExp(r'(\d+(?:\.\d+)*)').firstMatch(tag)?.group(1);

bool isNewerVersion(String latest, String current) {
  List<int> parts(String v) =>
      v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final a = parts(latest), b = parts(current);
  for (var i = 0; i < max(a.length, b.length); i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

/// The newest published (non-draft, non-prerelease) GitHub release.
/// Reads the real asset list from the API; if the API is unavailable (rate limit, offline proxy)
/// it falls back to the /releases/latest redirect and the known file names.
Future<ReleaseInfo?> fetchLatestRelease() async =>
    await _fromApi() ?? await _fromRedirect();

Future<ReleaseInfo?> _fromApi() async {
  try {
    final response = await http.get(
      Uri.parse(_apiLatestUrl),
      headers: const {'Accept': 'application/vnd.github+json'},
    ).timeout(const Duration(seconds: 15));
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
    final response =
        await client.send(request).timeout(const Duration(seconds: 15));
    final location = response.headers['location'] ?? '';
    final tag =
        RegExp(r'/releases/tag/([^/?#]+)$').firstMatch(location)?.group(1);
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
