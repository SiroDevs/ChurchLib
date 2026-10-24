// Dart imports:
import 'dart:math';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import '../../common/utils/formatting/app_util.dart';

/// The app's pubspec.yaml on the default branch of github.com/sirodevs/churchlib.
const String kRepoPubspecUrl =
    'https://raw.githubusercontent.com/sirodevs/churchlib/HEAD/pubspec.yaml';

/// Where a user goes to get the new version.
const String kRepoReleasesUrl =
    'https://github.com/sirodevs/churchlib/releases/latest';

/// The version in a pubspec's text: "version: 1.0.12+3" gives "1.0.12".
String? parsePubspecVersion(String pubspec) {
  final match = RegExp(
    r'^version:\s*([0-9]+(?:\.[0-9]+)*)',
    multiLine: true,
  ).firstMatch(pubspec);
  return match?.group(1);
}

/// Whether [latest] is a higher version than [current], compared number by
/// number so that 1.0.10 is newer than 1.0.9.
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

/// The latest version published on GitHub, or null when it can't be read
/// (offline, rate limited, repository not public...).
Future<String?> fetchLatestVersion() async {
  try {
    final response = await http
        .get(Uri.parse(kRepoPubspecUrl))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      logger('Update check: GitHub answered ${response.statusCode}');
      return null;
    }
    return parsePubspecVersion(response.body);
  } catch (e) {
    logger('Update check failed: $e');
    return null;
  }
}
