import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants/pref_constants.dart';
import 'license_models.dart';

/// Keeps the signed token and a few display details between launches.
///
/// Editing these values can't grant anything: the token is signed, and a
/// missing or damaged one only means the app asks the server again.
class LicenseStorage {
  LicenseStorage(this._prefs);

  final SharedPreferences _prefs;

  String? get token => _prefs.getString(PrefConstants.licenseTokenKey);

  Future<void> saveToken(String token) =>
      _prefs.setString(PrefConstants.licenseTokenKey, token);

  /// The latest moment this computer's clock has ever been seen at, or that
  /// the server told us. Used to notice a clock that was turned back.
  DateTime? get lastSeen {
    final ms = _prefs.getInt(PrefConstants.licenseLastSeenKey);
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  /// Only ever moves forward.
  Future<void> touchLastSeen(DateTime moment) async {
    final current = lastSeen;
    if (current != null && !moment.isAfter(current)) return;
    await _prefs.setInt(
      PrefConstants.licenseLastSeenKey,
      moment.toUtc().millisecondsSinceEpoch,
    );
  }

  LicenseMeta get meta {
    final raw = _prefs.getString(PrefConstants.licenseMetaKey);
    if (raw == null) return LicenseMeta.empty;
    try {
      return LicenseMeta.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return LicenseMeta.empty;
    }
  }

  Future<void> saveMeta(LicenseMeta meta) =>
      _prefs.setString(PrefConstants.licenseMetaKey, jsonEncode(meta.toJson()));
}
