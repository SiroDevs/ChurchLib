// Dart imports:
import 'dart:io';

/// Opens the downloaded package with the operating system's installer.
class UpdateInstaller {
  /// Opens the downloaded package with the operating system's installer.
  static Future<void> open(File installer) async {
    final isWindowsArchive =
        Platform.isWindows && installer.path.toLowerCase().endsWith('.zip');
    final command = isWindowsArchive
        ? 'explorer.exe'
        : Platform.isWindows
        ? installer.path
        : Platform.isMacOS
        ? 'open'
        : 'xdg-open';
    final arguments = Platform.isWindows
        ? (isWindowsArchive ? [installer.path] : <String>[])
        : [installer.path];
    await Process.start(command, arguments, mode: ProcessStartMode.detached);
  }
}
