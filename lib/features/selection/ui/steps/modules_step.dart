// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/utils/constants/app_assets.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../bloc/selection_bloc.dart';

class ModulesStep extends StatelessWidget {
  const ModulesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SelectionBloc>();
    return BlocBuilder<SelectionBloc, SelectionState>(
      buildWhen: (p, c) => p.songlib != c.songlib || p.biblelib != c.biblelib,
      builder: (context, state) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.iconApp, height: 96, width: 96),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to ChurchLib',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Choose what you'd like set up. You can always add "
                  'the other one later from Settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: ThemeColors.grey),
                ),
                const SizedBox(height: 32),
                _ModuleTile(
                  title: 'SongLib',
                  subtitle: 'Church songbook & hymns, offline',
                  icon: AppAssets.iconSonglib,
                  selected: state.songlib,
                  onChanged: (v) => bloc.add(ModulesToggled(songlib: v)),
                ),
                const SizedBox(height: 16),
                _ModuleTile(
                  title: 'BibleLib',
                  subtitle: 'Multi-translation Bible reader',
                  icon: AppAssets.iconBiblelib,
                  selected: state.biblelib,
                  onChanged: (v) => bloc.add(ModulesToggled(biblelib: v)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _ModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? ThemeColors.primary : ThemeColors.lightGrey,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? ThemeColors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(icon, width: 48, height: 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ThemeColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: selected,
              activeColor: ThemeColors.primary,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ],
        ),
      ),
    );
  }
}