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

  static const _options = <TextAlign, (IconData, String)>{
    TextAlign.left: (Icons.format_align_left, 'Left'),
    TextAlign.center: (Icons.format_align_center, 'Center'),
    TextAlign.right: (Icons.format_align_right, 'Right'),
    TextAlign.justify: (Icons.format_align_justify, 'Justified'),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, thickness: 1, color: Colors.white),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Text(
                'Song #$songNo',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              Expanded(child: indicators),
              PopupMenuButton<TextAlign>(
                tooltip: 'Text alignment',
                initialValue: align,
                onSelected: onAlign,
                itemBuilder: (context) => [
                  for (final e in _options.entries)
                    PopupMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Icon(e.value.$1, size: 20),
                          const SizedBox(width: 12),
                          Text(e.value.$2),
                        ],
                      ),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_options[align]!.$1, size: 28),
                      const SizedBox(width: 8),
                      const Text('Align', style: TextStyle(fontSize: 20)),
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
}
