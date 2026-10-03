// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../common/utils/constants/pref_constants.dart';
import '../../core/di/injectable.dart';
import '../../core/theme/theme_colors.dart';
import '../../domain/repos/pref_repo.dart';
import '../bible_reader/ui/bible_reader_screen.dart';
import '../main/ui/main_screen.dart';

/// ChurchLib's top-level home shell. Reads which modules the user enabled
/// during setup:
/// - both enabled -> bottom NavigationBar to switch between SongLib and
///   BibleLib, each keeping its own state via IndexedStack
/// - exactly one enabled -> that module's screen fills the whole window,
///   no bottom bar
///
/// SongLib's own MainScreen already has an internal sidebar for
/// search/likes/settings within SongLib itself — this bottom bar is a
/// level above that, for switching between the two apps entirely.
class ChurchHomeScreen extends StatefulWidget {
  const ChurchHomeScreen({super.key});

  @override
  State<ChurchHomeScreen> createState() => _ChurchHomeScreenState();
}

class _ChurchHomeScreenState extends State<ChurchHomeScreen> {
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

    // Only one module active: no bottom bar, that module fills the window.
    if (!bothEnabled) {
      if (_songlibEnabled) return const MainScreen();
      if (_biblelibEnabled) return const BibleReaderScreen();
      // Neither enabled shouldn't be reachable (welcome screen requires at
      // least one), but fall back to SongLib rather than a blank screen.
      return const MainScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          MainScreen(),
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
