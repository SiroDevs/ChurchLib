// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'secondary_tile.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../../domain/repos/bible/bible_selection_repo.dart';
import '../../bloc/bibles_cubit.dart';

class SecondarySection extends StatelessWidget {
  final BiblesState state;
  const SecondarySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BiblesCubit>();
    final candidates = state.bibles
        .where((b) => b.isDownloaded && b.abbreviation != state.primaryAbbr)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Parallel Bibles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primary,
                  ),
                ),
              ),
              Switch(
                value: state.multiBibleEnabled,
                activeThumbColor: ThemeColors.primary,
                onChanged: cubit.setMultiBibleEnabled,
              ),
            ],
          ),
          Text(
            'Shown alongside your primary Bible in the reader '
            '(up to $bibleMaxSecondaryBibles, in this order).',
            style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
          ),
          const SizedBox(height: 8),
          for (final b in candidates)
            SecondaryTile(
              bible: b,
              index: state.secondaryBibles.indexOf(b.abbreviation),
              total: state.secondaryBibles.length,
              enabled: state.multiBibleEnabled,
            ),
        ],
      ),
    );
  }
}
