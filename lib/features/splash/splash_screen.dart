// Dart imports:
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../common/navigator/route_names.dart';
import '../../common/utils/constants/app_assets.dart';
import '../../common/utils/constants/app_constants.dart';
import '../../common/utils/constants/pref_constants.dart';
import '../../core/di/injectable.dart';
import '../../core/theme/theme_colors.dart';
import '../../domain/repos/pref_repo.dart';

part 'splash_widgets.dart';

const _splashDuration = Duration(milliseconds: 2800);

const _textShadows = [
  Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
  Shadow(color: Colors.black54, blurRadius: 18),
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final String _background = _pickBackground();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_splashDuration, () {
      if (!mounted) return;
      context.goNamed(RouteNames.main);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pickBackground() {
    final images = AppAssets.splashBackgrounds;
    if (images.length == 1) return images.first;

    final prefs = getIt<PrefRepo>();
    final last = prefs.getPrefInt(PrefConstants.splashBgIndexKey) - 1;
    final candidates = [
      for (var i = 0; i < images.length; i++)
        if (i != last) i,
    ];
    final index = candidates[Random().nextInt(candidates.length)];
    prefs.setPrefInt(PrefConstants.splashBgIndexKey, index + 1);
    return images[index];
  }

  @override
  Widget build(BuildContext context) {
    const withLoveFromRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'with ',
          style: TextStyle(
            fontSize: 30,
            letterSpacing: 5,
            fontWeight: FontWeight.bold,
            color: ThemeColors.accent1,
            shadows: _textShadows,
          ),
        ),
        Icon(
          Icons.favorite_rounded,
          color: ThemeColors.primary1,
          shadows: _textShadows,
        ),
        Text(
          ' from',
          style: TextStyle(
            fontSize: 30,
            letterSpacing: 5,
            fontWeight: FontWeight.bold,
            color: ThemeColors.accent1,
            shadows: _textShadows,
          ),
        ),
      ],
    );

    const appDevelopers = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppConstants.appCredits,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeColors.accent3,
            shadows: _textShadows,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: ThemeColors.primaryDark2,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _background,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSyncLoaded) =>
                Opacity(
              opacity: wasSyncLoaded || frame != null ? 1 : 0,
              child: child,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x40000000), Color(0x20000000), Color(0x99000000)],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                const _ShadowedIcon(size: 200),
                const SizedBox(height: 10),
                const Text(
                  AppConstants.appTitle,
                  style: TextStyle(
                    fontSize: 50,
                    letterSpacing: 5,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.accent1,
                    shadows: _textShadows,
                  ),
                ),
                const SizedBox(height: 5),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: Divider(
                    color: Colors.white70,
                    thickness: 2,
                    height: 50,
                  ),
                ),
                withLoveFromRow,
                appDevelopers,
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
