part of 'presentor_screen.dart';

class PresentorDetails extends StatefulWidget {
  final PresentorScreenState parent;

  const PresentorDetails({super.key, required this.parent});

  @override
  State<PresentorDetails> createState() => PresentorDetailsState();
}

const double _minFontSize = 12, _maxFontSize = 200, _fontStep = 2;

class PresentorDetailsState extends State<PresentorDetails> {
  late PresentorScreenState parent;
  int _currentSlide = 0;

  int get currentSlide => _currentSlide;

  // Also tells the verses sidebar which slide is showing.
  set currentSlide(int value) {
    _currentSlide = value;
    parent.activeSlide.value = value;
  }

  double shownFontSize = 18;

  double? userFontSize;
  List<String> stanzas = [];
  List<Widget> slides = [];
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    parent = widget.parent;
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void resetForSong() {
    slides = [];
    stanzas = [];
    currentSlide = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  void setSlideByNumber(int slide) {
    setState(() {
      currentSlide = getSlideByNumber(slide, parent.hasChorus, slides.length);
    });
  }

  void setSlideByLetter(String slide) {
    setState(() {
      currentSlide = getSlideByLetter(slide, parent.hasChorus, slides.length);
    });
  }

  void setPreviousSlide() {
    if (currentSlide != 0) {
      setState(() => currentSlide = currentSlide - 1);
    }
  }

  void setNextSlide() {
    if (currentSlide < slides.length) {
      setState(() => currentSlide = currentSlide + 1);
    }
  }

  void resizeFont(bool decrease) {
    // Step from the size on screen, so a key press always changes what the
    // user sees. Bigger stops once the longest verse would stop fitting.
    final current = shownFontSize;
    final wanted = decrease ? current - _fontStep : current + _fontStep;
    final next = min(_maxFontSize, max(_minFontSize, wanted));
    setState(() => userFontSize = next);
    focusNode.requestFocus();
  }

  void _buildSlides(List<String> newStanzas, double screenHeight) {
    if (newStanzas.isNotEmpty) {
      slides = presentorWidgets(
        parent.songTitle,
        parent.songBook,
        screenHeight,
        newStanzas,
        pickedFontSize: userFontSize,
        hasChorus: parent.hasChorus,
        textAlign: parent.textAlign,
        onFontFit: (size) => shownFontSize = size,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: context.read<PresentorBloc>(),
      builder: (context, state) {
        if (state is PresentorLoadedState) {
          if (state.stanzas.isNotEmpty || slides.isEmpty) {
            stanzas = state.stanzas;
            _buildSlides(state.stanzas, MediaQuery.sizeOf(context).height);
          }

          var presentation = state.stanzas.isNotEmpty
              ? PresentorSlide(
                  key: ValueKey(currentSlide),
                  index: currentSlide,
                  songbook: parent.songBook,
                  tabs: state.tabs,
                  slides: slides,
                  onSlideChanged: (index) => currentSlide = index,
                  songNo: parent.song.songNo,
                  textAlign: parent.textAlign,
                  onAlign: parent.setAlign,
                  indicatorWidth: MediaQuery.of(context).size.height * 0.08156,
                )
              : SizedBox();

          return Shortcuts(
            shortcuts: presentorShortcuts,
            child: Actions(
              actions: <Type, Action<Intent>>{
                CloseIntent: CallbackAction<CloseIntent>(
                  onInvoke: (intent) => context.pop(true),
                ),
                PreviousIntent: CallbackAction<PreviousIntent>(
                  onInvoke: (intent) => setPreviousSlide(),
                ),
                NextIntent: CallbackAction<NextIntent>(
                  onInvoke: (intent) => setNextSlide(),
                ),
                PreviousSongIntent: CallbackAction<PreviousSongIntent>(
                  onInvoke: (intent) =>
                      parent.changeSong(-1, context.read<PresentorBloc>()),
                ),
                NextSongIntent: CallbackAction<NextSongIntent>(
                  onInvoke: (intent) =>
                      parent.changeSong(1, context.read<PresentorBloc>()),
                ),
                SlideNumberIntent: CallbackAction<SlideNumberIntent>(
                  onInvoke: (intent) => setSlideByNumber(intent.slideNumber),
                ),
                SlideLetterIntent: CallbackAction<SlideLetterIntent>(
                  onInvoke: (intent) => setSlideByLetter(intent.letter),
                ),
                BiggerFontIntent: CallbackAction<BiggerFontIntent>(
                  onInvoke: (intent) => resizeFont(false),
                ),
                SmallerFontIntent: CallbackAction<SmallerFontIntent>(
                  onInvoke: (intent) => resizeFont(true),
                ),
              },
              child: Focus(
                focusNode: focusNode,
                autofocus: true,
                onKeyEvent: (node, event) => KeyEventResult.ignored,
                child: presentation,
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
