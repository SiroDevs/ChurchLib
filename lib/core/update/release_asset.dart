// Dart imports:
import 'dart:io';

/// One downloadable file attached to a GitHub release.
class ReleaseAsset {
  const ReleaseAsset(this.name, this.url);

  final String name;
  final String url;
}

/// The newest published release of ChurchLib.
class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.pageUrl,
    required this.assets,
  });

  /// "1.0.5" (no leading "v", no build suffix).
  final String version;

  /// The human-readable release page (notes, all files).
  final String pageUrl;
  final List<ReleaseAsset> assets;
}

/// Release assets are named ChurchLib_{version}_{arch}.{ext}, the same convention
/// the ChurchLib-Admin landing page relies on:
///   x64.exe (Windows installer), x64.zip (Windows portable), {x64,arm64}.dmg,
///   {x64,arm64}.{deb,rpm,tar.gz}
List<String> knownAssetNames(String version) => [
      for (final suffix in const [
        'x64.exe',
        'x64.zip',
        'arm64.dmg',
        'x64.dmg',
        'x64.deb',
        'arm64.deb',
        'x64.rpm',
        'arm64.rpm',
        'x64.tar.gz',
        'arm64.tar.gz',
      ])
        'ChurchLib_${version}_$suffix',
    ];

enum HostOs { windows, macos, linux }

enum LinuxFamily { debian, redhat, other }

class HostPlatform {
  const HostPlatform(this.os, this.arch, [this.linuxFamily = LinuxFamily.other]);

  final HostOs os;

  /// 'x64' or 'arm64'
  final String arch;
  final LinuxFamily linuxFamily;

  /// Null on platforms we ship no binary for (Android, iOS, web, Fuchsia).
  static HostPlatform? detect() {
    final HostOs os;
    if (Platform.isWindows) {
      os = HostOs.windows;
    } else if (Platform.isMacOS) {
      os = HostOs.macos;
    } else if (Platform.isLinux) {
      os = HostOs.linux;
    } else {
      return null;
    }
    // Platform.version ends with the target, e.g. "windows_x64", "macos_arm64", "linux_arm64".
    final arch = RegExp(r'arm64|aarch64', caseSensitive: false)
            .hasMatch(Platform.version)
        ? 'arm64'
        : 'x64';
    return HostPlatform(
      os,
      arch,
      os == HostOs.linux ? _linuxFamily() : LinuxFamily.other,
    );
  }

  static LinuxFamily _linuxFamily() {
    try {
      final text = File('/etc/os-release').readAsStringSync().toLowerCase();
      String field(String key) =>
          RegExp('^$key=(.*)\$', multiLine: true)
              .firstMatch(text)
              ?.group(1)
              ?.replaceAll(RegExp('["\']'), '') ??
          '';
      final ids = '${field('id')} ${field('id_like')}'.split(RegExp(r'\s+'));
      if (ids.any((i) => const ['debian', 'ubuntu', 'linuxmint', 'pop'].contains(i))) {
        return LinuxFamily.debian;
      }
      if (ids.any((i) =>
          const ['fedora', 'rhel', 'centos', 'rocky', 'almalinux', 'suse', 'opensuse'].contains(i))) {
        return LinuxFamily.redhat;
      }
    } catch (_) {
      // unreadable: fall through to the tarball
    }
    return LinuxFamily.other;
  }
}

String? _archOf(String name) {
  final n = name.toLowerCase();
  if (n.contains('arm64') || n.contains('aarch64')) return 'arm64';
  if (n.contains('x64') || n.contains('amd64')) return 'x64';
  return null;
}

/// Picks the single file this machine should install, or null if the release has none for it.
ReleaseAsset? pickAsset(List<ReleaseAsset> assets, HostPlatform host) {
  ReleaseAsset? find(String ext, String arch) {
    for (final a in assets) {
      if (a.name.toLowerCase().endsWith(ext) && _archOf(a.name) == arch) return a;
    }
    return null;
  }

  switch (host.os) {
    case HostOs.windows:
      // Only x64 builds exist; Windows on ARM runs them under emulation.
      return find('.exe', 'x64') ?? find('.zip', 'x64');
    case HostOs.macos:
      return find('.dmg', host.arch) ??
          (host.arch == 'arm64' ? find('.dmg', 'x64') : null); // Rosetta
    case HostOs.linux:
      final order = switch (host.linuxFamily) {
        LinuxFamily.debian => const ['.deb', '.tar.gz'],
        LinuxFamily.redhat => const ['.rpm', '.tar.gz'],
        LinuxFamily.other => const ['.tar.gz'],
      };
      for (final ext in order) {
        final hit = find(ext, host.arch);
        if (hit != null) return hit;
      }
      return null;
  }
}
