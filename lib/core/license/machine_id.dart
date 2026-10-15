// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../common/constants/pref_constants.dart';
import '../../common/utils/formatting/app_util.dart';

/// A stable, anonymous id for this computer.
///
/// The operating system's own machine id (Windows install id, macOS hardware
/// UUID, Linux /etc/machine-id) is hashed with SHA-256, so the raw id never
/// leaves the computer. The id is recomputed on every launch and never copied
/// into app storage, so moving the app's data folder to another computer does
/// not move the license with it.
class MachineIdProvider {
  MachineIdProvider(this._prefs);

  final SharedPreferences _prefs;
  String? _cached;

  /// 64 lowercase hex characters, as the license server expects.
  Future<String> hashedId() async {
    final cached = _cached;
    if (cached != null) return cached;
    final raw = await _rawId();
    final hash = sha256.convert(utf8.encode('churchlib:machine:v1:$raw'));
    return _cached = hash.toString();
  }

  /// "A1B2-C3D4": what the customer reads out and the dashboard shows.
  static String shortId(String hash) {
    if (hash.length < 8) return hash.toUpperCase();
    final head = hash.substring(0, 8).toUpperCase();
    return '${head.substring(0, 4)}-${head.substring(4)}';
  }

  Future<String> _rawId() async {
    String? id;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isWindows) {
        id = (await info.windowsInfo).deviceId;
      } else if (Platform.isMacOS) {
        id = (await info.macOsInfo).systemGUID;
      } else if (Platform.isLinux) {
        id = (await info.linuxInfo).machineId;
      }
    } catch (e) {
      logger('Machine id: device info failed: $e');
    }

    if (_isBlank(id) && Platform.isWindows) id = await _windowsMachineGuid();
    if (_isBlank(id) && Platform.isLinux) id = await _linuxMachineId();
    if (_isBlank(id)) {
      // Last resort so the app still works: a random id kept in app storage.
      logger('Machine id: no system id available, using a generated one');
      id = _generatedId();
    }
    return id!.trim().toLowerCase();
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  Future<String?> _windowsMachineGuid() async {
    try {
      final result = await Process.run('reg', [
        'query',
        r'HKLM\SOFTWARE\Microsoft\Cryptography',
        '/v',
        'MachineGuid',
      ]);
      final match = RegExp(r'MachineGuid\s+REG_SZ\s+(\S+)')
          .firstMatch(result.stdout.toString());
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _linuxMachineId() async {
    for (final path in const ['/etc/machine-id', '/var/lib/dbus/machine-id']) {
      try {
        final text = (await File(path).readAsString()).trim();
        if (text.isNotEmpty) return text;
      } catch (_) {
        // try the next location
      }
    }
    return null;
  }

  String _generatedId() {
    final existing = _prefs.getString(PrefConstants.licenseFallbackIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final id = List<int>.generate(16, (_) => random.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    _prefs.setString(PrefConstants.licenseFallbackIdKey, id);
    return id;
  }
}
