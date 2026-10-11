import 'package:flutter/foundation.dart';

final ValueNotifier<int> bibleSettingsChanged = ValueNotifier<int>(0);

void notifyBibleSettingsChanged() => bibleSettingsChanged.value++;