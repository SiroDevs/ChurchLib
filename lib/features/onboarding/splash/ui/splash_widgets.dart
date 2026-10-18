part of 'splash_screen.dart';

class _ShadowedIcon extends StatelessWidget {
  final double size;
  const _ShadowedIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 8),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Image.asset(
              AppAssets.iconApp,
              height: size,
              width: size,
              color: Colors.black.withValues(alpha: 0.65),
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
        Image.asset(AppAssets.iconApp, height: size, width: size),
      ],
    );
  }
}
