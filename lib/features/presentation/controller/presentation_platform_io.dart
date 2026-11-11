import 'dart:io';

bool get supportsMultiViewPresentation =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;
