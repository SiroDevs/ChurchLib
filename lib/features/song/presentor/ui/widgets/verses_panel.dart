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
      alignment: 0.3,
      duration: animate ? const Duration(milliseconds: 200) : Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = min(180.0, max(130.0, MediaQuery.sizeOf(context).width * 0.16));

    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
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
                      : BorderSide.none,
                ),
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      verses[i].replaceAll('#', '\n'),
                      style: const TextStyle(fontSize: 12),
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
