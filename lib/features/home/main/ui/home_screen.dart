// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../common/utils/constants/pref_constants.dart';
import '../../../../core/di/injectable.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../bible_reader/ui/bible_reader_screen.dart';
import '../../song_search/ui/song_search_screen.dart';
import '../shell/app_module.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<AppModule> _enabled;
  late AppModule _current;

  @override
  void initState() {
    super.initState();
    final prefRepo = getIt<PrefRepo>();
    final songlib = prefRepo.getPrefBool(PrefConstants.songlibModuleEnabledKey);
    final biblelib = prefRepo.getPrefBool(
      PrefConstants.biblelibModuleEnabledKey,
    );
    _enabled = [
      if (songlib) AppModule.songlib,
      if (biblelib) AppModule.biblelib,
    ];
    if (_enabled.isEmpty) _enabled.add(AppModule.songlib);
    _current = _enabled.first;
  }

  @override
  Widget build(BuildContext context) {
    return HomeModuleScope(
      current: _current,
      enabled: _enabled,
      onSwitch: (m) => setState(() => _current = m),
      child: IndexedStack(
        index: _enabled.indexOf(_current),
        children: [
          for (final m in _enabled)
            switch (m) {
              AppModule.songlib => const SongSearchScreen(),
              AppModule.biblelib => const BibleReaderScreen(),
            },
        ],
      ),
    );
  }
}
