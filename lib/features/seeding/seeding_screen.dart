// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../core/theme/theme_colors.dart';
import '../../common/utils/constants/app_assets.dart';
import '../../common/navigator/route_names.dart';

/// Shown once, right after every selected module (SongLib, BibleLib, or
/// both) has finished its own setup step. SongLib's own step2 already
/// seeds its data with its own progress UI; this screen is the final,
/// app-wide checkpoint before dropping into Home. BibleLib's primary
/// translation is downloaded earlier, in BibleSelectionScreen.
class SeedingScreen extends StatefulWidget {
  const SeedingScreen({super.key});

  @override
  State<SeedingScreen> createState() => _SeedingScreenState();
}

class _SeedingScreenState extends State<SeedingScreen> {
  @override
  void initState() {
    super.initState();
    // Nothing left to seed today (each module seeds during its own setup
    // step), so this is a brief, reassuring checkpoint before Home. Once
    // BibleLib does real seeding, replace this delay with a listener on
    // its actual seeding progress stream.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.main,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.iconApp, height: 96, width: 96),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: ThemeColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Getting everything ready…',
              style: TextStyle(fontSize: 15, color: ThemeColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
