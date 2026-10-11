import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../core/theme/theme_colors.dart';
import '../../../../data/sources/remote/bible/bible_dtos.dart';
import '../../bloc/selection_bloc.dart';

class BibleTile extends StatelessWidget {
  final BibleInfoDto bible;
  final bool selected;
  final bool isPrimary;
  final bool atLimit;

  const BibleTile({super.key, 
    required this.bible,
    required this.selected,
    required this.isPrimary,
    required this.atLimit,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !selected && atLimit;
    return CheckboxListTile(
    value: selected,
    activeColor: ThemeColors.primary,
    controlAffinity: ListTileControlAffinity.leading,
    onChanged: disabled
        ? null
        : (_) => context
            .read<SelectionBloc>()
            .add(BibleToggled(bible.abbreviation)),
    title: Row(
      children: [
        Text(
          bible.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
            .flexible(),
        if (isPrimary) ...[
          const SizedBox(width: 8),
          const Text(
            'Primary',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ThemeColors.primary,
            ),
          )
              .padding(horizontal: 8, vertical: 2)
              .decorated(
                color: ThemeColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
        ],
      ],
    ),
    subtitle: Text(
      '${bible.abbreviation.toUpperCase()} · ${bible.language.name}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12),
    ),
  )
        .card(
          margin: const EdgeInsets.all(3),
          elevation: selected ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selected ? ThemeColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
        )
        .opacity(disabled ? 0.45 : 1);
  }
}
