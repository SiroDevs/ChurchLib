import 'dart:io';

bool get supportsPresentationWindows {
  if (Platform.isWindows) return true;
  if (!Platform.isLinux) return false;

  final environment = Platform.environment;
  final requestedBackend = environment['GDK_BACKEND']?.split(',').first.trim();
  if (requestedBackend != null) return requestedBackend == 'wayland';
  return environment['WAYLAND_DISPLAY']?.isNotEmpty == true ||
      environment['XDG_SESSION_TYPE'] == 'wayland';
}

bool get supportsPresentationDisplays => Platform.isWindows || Platform.isLinux;

bool get usesLinuxAudienceProcess =>
    Platform.isLinux && !supportsPresentationWindows;
