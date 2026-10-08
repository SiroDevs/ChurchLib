// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../app_util.dart';

bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
bool isMobile = Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;

class AppConstants {
  AppConstants._();
  static const kFontFamily = 'TrebuchetMS';
  static String dbName = 'ChurchLib.db';

  static const fromApp = "\n\nSource: ChurchLib\nhttps://sirodevs.com/churchlib";
  static const siteLink = "https://sirodevs.com/churchlib/";

  static const appTitle = "ChurchLib";
  static const appVersionx = "v0.0.7.60";
  static const appCredits = "© Siro Devs";
  static const IconData whatsapp =
      IconData(0xf05a6, fontFamily: 'MaterialIcons');

  static Future<String> get databaseFile async {
    Directory dbFolder = await getApplicationDocumentsDirectory();
    if (isDesktop) {
      dbFolder = await getApplicationSupportDirectory();
    }

    var dbPath = join(dbFolder.path, AppConstants.dbName);
    logger('Opening database from: $dbPath');
    return dbPath;
  }
}
