// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../common/utils/constants/app_assets.dart';

enum AppModule {
  songlib('SongLib', AppAssets.iconSonglib),
  biblelib('BibleLib', AppAssets.iconBiblelib);

  const AppModule(this.label, this.icon);
  final String label;
  final String icon;
}

class HomeModuleScope extends InheritedWidget {
  const HomeModuleScope({
    super.key,
    required this.current,
    required this.enabled,
    required this.onSwitch,
    required super.child,
  });

  final AppModule current;
  final List<AppModule> enabled;
  final ValueChanged<AppModule> onSwitch;

  static HomeModuleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeModuleScope>();

  @override
  bool updateShouldNotify(HomeModuleScope old) =>
      current != old.current || enabled != old.enabled;
}
