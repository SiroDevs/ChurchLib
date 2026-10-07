part of 'advanced_progress.dart';

class AdvancedProgress extends StatelessWidget {
  const AdvancedProgress({
    super.key,
    required this.radius,
    this.primaryValue,
    this.secondaryValue,
    this.secondaryWidth = 10.0,
    this.startAngle = 120.0,
    this.maxDegrees = 300.0,
    this.progressGap = 0.0,
    this.division = 10,
    this.levelAmount,
    this.levelLowWidth = 1.0,
    this.levelLowHeight = 8.0,
    this.levelHighWidth = 2.0,
    this.levelHighHeight = 16.0,
    this.levelHighBeginEnd = false,
    this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.child,
  });

  final double radius;

  final double? primaryValue;

  final double? secondaryValue;

  final double secondaryWidth;

  final double startAngle;

  final double maxDegrees;

  final double progressGap;

  final int division;

  final int? levelAmount;

  final double levelLowWidth;

  final double levelLowHeight;

  final double levelHighHeight;

  final double levelHighWidth;

  final bool levelHighBeginEnd;

  final Color? primaryColor;

  final Color? secondaryColor;

  final Color? tertiaryColor;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final size = radius * 2;

    return Container(
      clipBehavior: Clip.antiAlias,
      width: size,
      height: size,
      decoration: const BoxDecoration(),
      child: CustomPaint(
        painter: AdvancedProgressPainter(
          primaryValue: primaryValue,
          secondaryValue: secondaryValue,
          secondaryWidth: secondaryWidth,
          radius: radius,
          startAngle: startAngle,
          maxDegrees: maxDegrees,
          progressGap: progressGap,
          division: division,
          levelAmount: levelAmount,
          levelLowWidth: levelLowWidth,
          levelLowHeight: levelLowHeight,
          levelHighWidth: levelHighWidth,
          levelHighHeight: levelHighHeight,
          levelHighBeginEnd: levelHighBeginEnd,
          primaryColor: primaryColor ?? theme.indicatorColor,
          secondaryColor: secondaryColor ?? primaryColor,
          tertiaryColor: tertiaryColor ?? theme.hintColor,
        ),
        child: child,
      ),
    );
  }
}
