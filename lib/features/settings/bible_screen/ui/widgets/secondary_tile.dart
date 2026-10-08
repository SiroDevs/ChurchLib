// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../data/models/bible/bible_version.dart';
import '../../bloc/bibles_cubit.dart';

class SecondaryTile extends StatelessWidget {
  final BibleVersion bible;

  final int index;
  final int total;
  final bool enabled;

  const SecondaryTile({super.key, 
    required this.bible,
    required this.index,
    required this.total,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BiblesCubit>();
    final selected = index >= 0;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: CheckboxListTile(
        value: selected,
        activeColor: ThemeColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: enabled
            ? (_) => cubit.toggleSecondaryBible(bible.abbreviation)
            : null,
        title: Text('${bible.abbreviation} · ${bible.name}'),
        secondary: selected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_upward, size: 18),
                    onPressed: enabled && index > 0
                        ? () => cubit.moveSecondaryBible(bible.abbreviation, -1)
                        : null,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_downward, size: 18),
                    onPressed: enabled && index < total - 1
                        ? () => cubit.moveSecondaryBible(bible.abbreviation, 1)
                        : null,
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
