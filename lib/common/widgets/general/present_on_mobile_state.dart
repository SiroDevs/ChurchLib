part of 'present_on_mobile.dart';

class PresentOnMobileState extends State<PresentOnMobile>
    with TickerProviderStateMixin {
  int? selectedIndex;
  bool? changePageByTapView;

  AnimationController? animationController;
  Animation<double?>? animation;
  Animation<RelativeRect?>? rectAnimation;

  PageController? pageController = PageController();

  List<AnimationController?>? animationControllers = [];

  ScrollPhysics? pageScrollPhysics = const AlwaysScrollableScrollPhysics();
  double targetOpacity = 1;

  @override
  void didUpdateWidget(PresentOnMobile oldWidget) {
    if (oldWidget.index == widget.index) return;
    setState(() => targetOpacity = 0);
    Future.delayed(1.milliseconds, () => setState(() => targetOpacity = 1));
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    selectedIndex = widget.index;
    for (int? i = 0; i! < widget.tabs!.length; i++) {
      animationControllers!.add(AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ));
    }
    selectTab(widget.index!);

    if (widget.disabledChangePageFromContentView == true) {
      pageScrollPhysics = const NeverScrollableScrollPhysics();
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController!.jumpToPage(widget.index!);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var contentContainer = Expanded(
      child: PageView.builder(
        scrollDirection: widget.contentScrollAxis!,
        physics: pageScrollPhysics,
        onPageChanged: (index) {
          if (changePageByTapView == false || changePageByTapView == null) {
            selectTab(index);
          }
          if (selectedIndex == index) {
            changePageByTapView = null;
          }
          setState(() {});
        },
        controller: pageController,

        itemCount: widget.contents!.length,

        itemBuilder: (BuildContext? context, int? index) {
          return widget.contents![index!];
        },
      ),
    );
    var indicatorContainer = SizedBox(
      height: widget.tabsWidth,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.tabs!.length,
        itemBuilder: (context, index) {
          Tab? tab = widget.tabs![index];

          Alignment? alignment = Alignment.centerLeft;
          if (widget.direction == TextDirection.rtl) {
            alignment = Alignment.centerRight;
          }

          var itemBGColor = widget.tabBackgroundColor;
          if (selectedIndex == index) {
            itemBGColor = widget.selectedTabBackgroundColor;
          }

          double? left, right;
          if (widget.direction == TextDirection.rtl) {
            left = (widget.indicatorSide == IndicatorSide.end) ? 0 : null;
            right = (widget.indicatorSide == IndicatorSide.start) ? 0 : null;
          } else {
            left = (widget.indicatorSide == IndicatorSide.start) ? 0 : null;
            right = (widget.indicatorSide == IndicatorSide.end) ? 0 : null;
          }

          return Stack(
            children: <Widget>[
              Positioned(
                top: 2,
                bottom: 2,
                width: widget.indicatorWidth,
                left: left,
                right: right,
                child: ScaleTransition(
                  scale: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationControllers![index]!,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ThemeColors.accent,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  changePageByTapView = true;
                  setState(() {
                    selectTab(index);
                  });

                  pageController!.animateToPage(index,
                      duration: widget.changePageDuration!,
                      curve: widget.changePageCurve!);
                },
                child: Container(
                  width: widget.indicatorWidth,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: itemBGColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  alignment: alignment,
                  child: tab.child,
                ),
              ),
            ],
          );
        },
      ),
    );
    return Directionality(
      textDirection: widget.direction!,
      child: Column(
        children: <Widget>[
          contentContainer,
          indicatorContainer,
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              '  ${widget.songbook!}',
              style: TextStyle(
                  fontSize: widget.tabsWidth! / 2, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void selectTab(int index) {
    selectedIndex = index;
    for (final AnimationController? animationController
        in animationControllers!) {
      animationController!.reset();
    }
    animationControllers![index]!.forward();

    if (widget.onSelect != null) {
      widget.onSelect!(selectedIndex);
    }
  }
}
