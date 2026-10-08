// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme/theme_colors.dart';
import 'verse_spans.dart';

Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

class VerseRow extends StatefulWidget {
  final int number;
  final String text;
  final double fontSize;
  final String? highlightQuery;
  
  final Map<String, String> parallelTexts;
  final bool isBookmarked;
  final String? bookmarkColorHex;
  final bool hasNote;
  final VoidCallback onToggleBookmark;
  final VoidCallback onOpenNote;

  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onToggleSelected;

  const VerseRow({
    super.key,
    required this.number,
    required this.text,
    required this.fontSize,
    this.highlightQuery,
    this.parallelTexts = const {},
    required this.isBookmarked,
    this.bookmarkColorHex,
    this.hasNote = false,
    required this.onToggleBookmark,
    required this.onOpenNote,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onToggleSelected,
  });

  @override
  State<VerseRow> createState() => _VerseRowState();
}

class _VerseRowState extends State<VerseRow> {
  bool _hovering = false;

  Widget _richText(TextSpan span) => widget.isSelectionMode
      ? Text.rich(span)
      : SelectableText.rich(span);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = parseHexColor(widget.bookmarkColorHex);
    final baseStyle = TextStyle(
      fontSize: widget.fontSize,
      height: 1.5,
      color: theme.colorScheme.onSurface,
    );
    final hitStyle = baseStyle.copyWith(
      backgroundColor: ThemeColors.primary1.withValues(alpha: 0.35),
      fontWeight: FontWeight.w600,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
       behavior: HitTestBehavior.translucent,
       onTap: widget.isSelectionMode ? widget.onToggleSelected : null,
       onLongPress: widget.onToggleSelected,
       onSecondaryTap: widget.onToggleSelected,
       child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? ThemeColors.primary.withValues(alpha: 0.16)
              : bg?.withValues(alpha: 0.28) ??
                  (_hovering
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
                      : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: widget.isSelected
              ? Border.all(color: ThemeColors.primary, width: 1.2)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: InkWell(
                onTap: widget.onToggleSelected,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: widget.isSelected
                      ? const Icon(Icons.check_circle,
                          size: 18, color: ThemeColors.primary)
                      : Text(
                          '${widget.number}',
                          style: TextStyle(
                            fontSize: widget.fontSize * 0.62,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.primary,
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _richText(
                    TextSpan(children: highlightSpans(widget.text, baseStyle, hitStyle, widget.highlightQuery)),
                  ),
                  for (final e in widget.parallelTexts.entries)
                    if (e.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _richText(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${e.key}  ',
                                style: TextStyle(
                                  fontSize: widget.fontSize * 0.6,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: e.value,
                                style: TextStyle(
                                  fontSize: widget.fontSize * 0.88,
                                  height: 1.45,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
            SizedBox(
              width: 84,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.hasNote || (_hovering && !widget.isSelectionMode))
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      tooltip: widget.hasNote ? 'SongEdit note' : 'Add note',
                      onPressed: widget.onOpenNote,
                      icon: Icon(
                        widget.hasNote
                            ? Icons.sticky_note_2
                            : Icons.sticky_note_2_outlined,
                        color: widget.hasNote
                            ? ThemeColors.primary
                            : ThemeColors.mediumGrey,
                      ),
                    ),
                  if (widget.isBookmarked || _hovering)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 20,
                      tooltip: widget.isBookmarked
                          ? 'Remove bookmark'
                          : 'Bookmark verse',
                      onPressed: widget.onToggleBookmark,
                      icon: Icon(
                        widget.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: widget.isBookmarked
                            ? (bg ?? ThemeColors.primary)
                            : ThemeColors.mediumGrey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
       ),
      ),
    );
  }
}
