// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:import 'package:go_router/go_router.dart';

// Project imports:
import '../../common/navigator/route_names.dart';
import '../../common/utils/constants/app_assets.dart';
import '../../common/utils/constants/pref_constants.dart';
import '../../core/di/injectable.dart';
import '../../core/theme/theme_colors.dart';
import '../../domain/repos/pref_repo.dart';

/// First screen a fresh ChurchLib install shows. Lets the user pick which
/// module(s) they want: SongLib, BibleLib, or both. Each selected module
/// then runs its own setup flow (book/content selection + seeding) before
/// landing on the shared home screen.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _prefRepo = getIt<PrefRepo>();

  bool _songlib = true;
  bool _biblelib = true;

  bool get _canContinue => _songlib || _biblelib;

  void _continue() {
    _prefRepo.setPrefBool(PrefConstants.songlibModuleEnabledKey, _songlib);
    _prefRepo.setPrefBool(PrefConstants.biblelibModuleEnabledKey, _biblelib);

    // Route into the first selected module's setup. If SongLib is enabled
    // it always runs first (its step1/step2 flow already exists); BibleLib
    // setup (once it has its own module) runs after, chained from step2.
    final nextRoute = _songlib ? RouteNames.step1 : RouteNames.biblelibSetup;
    context.goNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.iconApp, height: 96, width: 96),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to ChurchLib',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose what you\'d like set up. You can always add '
                    'the other one later from Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: ThemeColors.grey),
                  ),
                  const SizedBox(height: 32),
                  _ModuleTile(
                    title: 'SongLib',
                    subtitle: 'Church songbook & hymns, offline',
                    icon: Icons.library_music_rounded,
                    selected: _songlib,
                    onChanged: (v) => setState(() => _songlib = v),
                  ),
                  const SizedBox(height: 16),
                  _ModuleTile(
                    title: 'BibleLib',
                    subtitle: 'Multi-translation Bible reader',
                    icon: Icons.menu_book_rounded,
                    selected: _biblelib,
                    onChanged: (v) => setState(() => _biblelib = v),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _canContinue ? _continue : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: ThemeColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _ModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? ThemeColors.primary : ThemeColors.lightGrey,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? ThemeColors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: ThemeColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ThemeColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: selected,
              activeColor: ThemeColors.primary,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ],
        ),
      ),
    );
  }
}
