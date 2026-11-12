part of '../presentor_screen.dart';

class PresentorFooter extends StatelessWidget {
  final int songNo;
  final Widget indicators;
  final TextAlign align;
  final ValueChanged<TextAlign> onAlign;

  const PresentorFooter({
    super.key,
    required this.songNo,
    required this.indicators,
    required this.align,
    required this.onAlign,
  });

  static const _options = <TextAlign, IconData>{
    TextAlign.left: Icons.format_align_left,
    TextAlign.center: Icons.format_align_center,
    TextAlign.right: Icons.format_align_right,
    TextAlign.justify: Icons.format_align_justify,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, thickness: 1, color: Colors.white),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Text(
                l10n.songNumberLabel(songNo),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              Expanded(child: indicators),
              PopupMenuButton<TextAlign>(
                tooltip: l10n.presentationAlign,
                initialValue: align,
                onSelected: onAlign,
                itemBuilder: (context) => [
                  for (final e in _options.entries)
                    PopupMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Icon(e.value, size: 20),
                          const SizedBox(width: 12),
                          Text(_alignmentLabel(l10n, e.key)),
                        ],
                      ),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_options[align]!, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        l10n.presentationAlign,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _alignmentLabel(AppLocalizations l10n, TextAlign value) =>
      switch (value) {
        TextAlign.left => l10n.presentationLeft,
        TextAlign.center => l10n.presentationCenter,
        TextAlign.right => l10n.presentationRight,
        _ => l10n.alignmentJustified,
      };
}
