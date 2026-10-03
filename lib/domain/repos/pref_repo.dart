// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../common/utils/constants/pref_constants.dart';

@singleton
abstract class PrefRepo {
  @factoryMethod
  factory PrefRepo(SharedPreferences prefrepo) = LocalStorageImp;

  ThemeMode getThemeMode();

  Future<void> updateThemeMode(ThemeMode themeMode);

  bool getPrefBool(String settingsKey, {bool defaultValue});
  int getPrefInt(String settingsKey);
  String getPrefString(String settingsKey);

  void setPrefBool(String settingsKey, bool settingsValue);
  void setPrefInt(String settingsKey, int settingsValue);
  void setPrefString(String settingsKey, String settingsValue);

  void clearData();
  void removeKeyPair(String settingsKey);
  bool keyExists(String settingsKey);
}

class LocalStorageImp implements PrefRepo {
  final SharedPreferences sharedPrefs;

  LocalStorageImp(this.sharedPrefs);

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await sharedPrefs.setString(
      PrefConstants.appThemeKey,
      themeMode.toString(),
    );
  }

  @override
  ThemeMode getThemeMode() {
    switch (sharedPrefs.getString(PrefConstants.appThemeKey)) {
      case 'ThemeMode.light':
        return ThemeMode.light;

      case 'ThemeMode.dark':
        return ThemeMode.dark;

      default:
        return ThemeMode.system;
    }
  }

  @override
  void clearData() {
    sharedPrefs.remove(PrefConstants.selectedBooksKey);
    sharedPrefs.remove(PrefConstants.dataIsSelectedKey);
    sharedPrefs.remove(PrefConstants.dataIsLoadedKey);
  }

  @override
  void removeKeyPair(String key) {
    sharedPrefs.remove(key);
  }

  @override
  bool keyExists(String key) {
    return sharedPrefs.containsKey(key);
  }

  @override
  bool getPrefBool(String settingsKey, {bool defaultValue = false}) {
    if (!sharedPrefs.containsKey(settingsKey)) {
      setPrefBool(settingsKey, defaultValue);
    }
    return sharedPrefs.getBool(settingsKey) ?? defaultValue;
  }

  @override
  int getPrefInt(String settingsKey) {
    return sharedPrefs.getInt(settingsKey) ?? 0;
  }

  @override
  String getPrefString(String settingsKey) {
    return sharedPrefs.getString(settingsKey) ?? '';
  }

  @override
  void setPrefBool(String settingsKey, bool settingsValue) {
    if (!settingsValue) {
      sharedPrefs.remove(settingsKey);
      return;
    }
    sharedPrefs.setBool(settingsKey, settingsValue);
  }

  @override
  void setPrefInt(String settingsKey, int settingsValue) {
    if (settingsValue.isNegative) {
      sharedPrefs.remove(settingsKey);
      return;
    }
    sharedPrefs.setInt(settingsKey, settingsValue);
  }

  @override
  void setPrefString(String settingsKey, String settingsValue) {
    if (settingsValue.isEmpty) {
      sharedPrefs.remove(settingsKey);
      return;
    }
    sharedPrefs.setString(settingsKey, settingsValue);
  }
}
