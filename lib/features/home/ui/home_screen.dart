// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../common/utils/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../domain/repos/pref_repo.dart';
import '../bible_reader/ui/bible_reader_screen.dart';
import '../song_search/ui/song_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final bool _songlibEnabled;
  late final bool _biblelibEnabled;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final prefRepo = getIt<PrefRepo>();
    _songlibEnabled = prefRepo.getPrefBool(
      PrefConstants.songlibModuleEnabledKey,
    );
    _biblelibEnabled = prefRepo.getPrefBool(
      PrefConstants.biblelibModuleEnabledKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bothEnabled = _songlibEnabled && _biblelibEnabled;

    if (!bothEnabled) {
      if (_songlibEnabled) return const SongSearchScreen();
      if (_biblelibEnabled) return const BibleReaderScreen();
      return const SongSearchScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          SongSearchScreen(),
          BibleReaderScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: ThemeColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: 'SongLib',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'BibleLib',
          ),
        ],
      ),
    );
  }
}
