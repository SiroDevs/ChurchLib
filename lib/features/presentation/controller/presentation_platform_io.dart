import 'dart:io';

// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:flutter/src/foundation/_features.dart' show isWindowingEnabled;

bool get supportsMultiViewPresentation =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;

/// Enables Flutter's windowing flag for the multi-view desktop runtime.
void enableMultiViewWindowing() {
  // ignore: invalid_use_of_internal_member
  isWindowingEnabled = true;
}
