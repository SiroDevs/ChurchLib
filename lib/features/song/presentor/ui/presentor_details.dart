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

  /// Size the text would like to be: what the user picked with - and =, or
  /// else one worked out from the screen height.
  double fontSize = 18;

  /// Size the text is really drawn at; smaller than [fontSize] whenever the
  /// text would not fit on the slide.
  double shownFontSize = 18;
  double? userFontSize;
  double _autoFontSize = 18, _autoForHeight = 0;
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

  double _preferredFontSize(double screenHeight) {
    final picked = userFontSize;
    if (picked != null) return picked;
    if (screenHeight != _autoForHeight) {
      _autoForHeight = screenHeight;
      _autoFontSize = max(
        _minFontSize,
        calcFontSize(height: screenHeight, content: parent.song.content),
      );
    }
    return _autoFontSize;
  }

  void resetForSong() {
    _autoForHeight = 0;
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

  void _buildSlides(List<String> newStanzas) {
    if (newStanzas.isNotEmpty) {
      slides = presentorWidgets(
        parent.songTitle,
        parent.songBook,
        fontSize,
        newStanzas,
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
          fontSize = _preferredFontSize(MediaQuery.sizeOf(context).height);
          if (state.stanzas.isNotEmpty || slides.isEmpty) {
            stanzas = state.stanzas;
            _buildSlides(state.stanzas);
          }

          var presentation = state.stanzas.isNotEmpty
              ? PresentorSlide(
                  key: ValueKey(currentSlide),
                  index: currentSlide,
                  songbook: parent.songBook,
                  tabs: state.tabs,
                  slides: slides,
                  onSlideChanged: (index) => currentSlide = index,
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
