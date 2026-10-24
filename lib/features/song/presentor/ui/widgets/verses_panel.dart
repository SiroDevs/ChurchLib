part of '../presentor_screen.dart';

/// Small sidebar listing every verse at once, styled like the song preview on
/// the songs screen, with the verse on the current slide highlighted.
class PresentorVersesPanel extends StatefulWidget {
  final SongExt song;
  final bool hasChorus;
  final ValueListenable<int> activeSlide;

  const PresentorVersesPanel({
    super.key,
    required this.song,
    required this.hasChorus,
    required this.activeSlide,
  });

  @override
  State<PresentorVersesPanel> createState() => _PresentorVersesPanelState();
}

class _PresentorVersesPanelState extends State<PresentorVersesPanel> {
  late final List<String> verses = widget.song.content.split('##');
  late final List<GlobalKey> keys = [for (final _ in verses) GlobalKey()];

  int get _activeVerse => min(
    verses.length - 1,
    rawVerseForSlide(widget.activeSlide.value, widget.hasChorus),
  );

  @override
  void initState() {
    super.initState();
    widget.activeSlide.addListener(_onSlideChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive(false));
  }

  @override
  void dispose() {
    widget.activeSlide.removeListener(_onSlideChanged);
    super.dispose();
  }

  void _onSlideChanged() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive(true));
  }

  void _scrollToActive(bool animate) {
    if (!mounted) return;
    final context = keys[_activeVerse].currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0,
      duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
    );
  }

  static const _fontSize = 12.0;

  /// Wide enough for the longest line of the song, so no line wraps, but never
  /// more than a third of the screen (a longer line is cut with an ellipsis).
  double _panelWidth(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    var widest = 0.0;
    for (final verse in verses) {
      for (final line in verse.split('#')) {
        final painter = TextPainter(
          text: TextSpan(text: line, style: const TextStyle(fontSize: _fontSize)),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout();
        widest = max(widest, painter.width);
        painter.dispose();
      }
    }
    // Card padding and margins around the text.
    final wanted = widest + 40;
    final cap = MediaQuery.sizeOf(context).width / 3;
    return min(cap, max(130.0, wanted));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: _panelWidth(context),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < verses.length; i++)
              Card(
                key: keys[i],
                elevation: i == _activeVerse ? 6 : 2,
                color: i == _activeVerse ? scheme.primaryContainer : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: i == _activeVerse
                      ? BorderSide(color: scheme.primary, width: 2)
                      : BorderSide(color: scheme.outlineVariant),
                ),
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      verses[i].replaceAll('#', '\n'),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: _fontSize),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
