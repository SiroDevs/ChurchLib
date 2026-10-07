// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
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
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: CheckboxListTile(
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
            Flexible(child: Text(bible.name)),
            if (isPrimary) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${bible.abbreviation} · ${bible.language.name}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
