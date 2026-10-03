// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../core/theme/theme_colors.dart';
import '../../../data/sources/remote/bible/bible_dtos.dart';
import '../bloc/bible_selection_bloc.dart';
import '../../../common/navigator/route_names.dart';

enum _Grouping { countries, languages, none }

/// BibleLib's setup step: pick translations (first pick = primary), then
/// the primary downloads with visible progress before continuing to the
/// app-wide seeding checkpoint. Ported from biblelib-android's selection
/// feature; the "Regions" grouping mode is not ported yet.
class BibleSelectionScreen extends StatelessWidget {
  const BibleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BibleSelectionBloc()..add(const BibleSelectionFetch()),
      child: const _BibleSelectionView(),
    );
  }
}

class _BibleSelectionView extends StatefulWidget {
  const _BibleSelectionView();

  @override
  State<_BibleSelectionView> createState() => _BibleSelectionViewState();
}

class _BibleSelectionViewState extends State<_BibleSelectionView> {
  String _query = '';
  _Grouping _grouping = _Grouping.countries;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BibleSelectionBloc, BibleSelectionState>(
      listenWhen: (p, c) => p.phase != c.phase,
      listener: (context, state) {
        if (state.phase == BibleSelectionPhase.saved) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.seeding,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: switch (state.phase) {
                  BibleSelectionPhase.loading => const _Centered(
                      child: CircularProgressIndicator(
                        color: ThemeColors.primary,
                      ),
                    ),
                  BibleSelectionPhase.error => _ErrorView(
                      message: state.message,
                      onRetry: () => context
                          .read<BibleSelectionBloc>()
                          .add(const BibleSelectionFetch()),
                    ),
                  BibleSelectionPhase.saving ||
                  BibleSelectionPhase.saved =>
                    _SavingView(step: state.step, progress: state.progress),
                  BibleSelectionPhase.saveFailed => _SaveFailedView(
                      message: state.message,
                      progress: state.progress,
                    ),
                  BibleSelectionPhase.loaded => _buildPicker(context, state),
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPicker(BuildContext context, BibleSelectionState state) {
    final q = _query.trim().toLowerCase();
    final filtered = state.available.where((b) {
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q) ||
          b.abbreviation.toLowerCase().contains(q) ||
          b.language.name.toLowerCase().contains(q);
    }).toList();

    final groups = <String, List<BibleInfoDto>>{};
    for (final b in filtered) {
      final key = switch (_grouping) {
        _Grouping.countries => b.primaryCountryName,
        _Grouping.languages =>
          b.language.name.isEmpty ? 'Other' : b.language.name,
        _Grouping.none => '',
      };
      (groups[key] ??= []).add(b);
    }
    final keys = groups.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your Bibles',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.selectedAbbrs.length} of ${state.maxSelections} selected'
            ' · your first pick is the primary Bible',
            style: const TextStyle(fontSize: 13, color: ThemeColors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search name, abbreviation or language',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<_Grouping>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: _Grouping.countries,
                    label: Text('Countries'),
                  ),
                  ButtonSegment(
                    value: _Grouping.languages,
                    label: Text('Languages'),
                  ),
                  ButtonSegment(value: _Grouping.none, label: Text('None')),
                ],
                selected: {_grouping},
                onSelectionChanged: (s) => setState(() => _grouping = s.first),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No Bibles match your search'))
                : ListView(
                    children: [
                      for (final key in keys) ...[
                        if (key.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                            child: Text(
                              key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ThemeColors.primary,
                              ),
                            ),
                          ),
                        for (final b in groups[key]!)
                          _BibleTile(
                            bible: b,
                            selected:
                                state.selectedAbbrs.contains(b.abbreviation),
                            isPrimary: state.selectedAbbrs.isNotEmpty &&
                                state.selectedAbbrs.first == b.abbreviation,
                            atLimit: state.selectedAbbrs.length >=
                                state.maxSelections,
                          ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.canProceed
                  ? () => context
                      .read<BibleSelectionBloc>()
                      .add(const BibleSelectionSave())
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Download & Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BibleTile extends StatelessWidget {
  final BibleInfoDto bible;
  final bool selected;
  final bool isPrimary;
  final bool atLimit;

  const _BibleTile({
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
                .read<BibleSelectionBloc>()
                .add(BibleSelectionToggle(bible.abbreviation)),
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

class _Centered extends StatelessWidget {
  final Widget child;
  const _Centered({required this.child});

  @override
  Widget build(BuildContext context) => Center(child: child);
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 56, color: ThemeColors.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: ThemeColors.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SavingView extends StatelessWidget {
  final String step;
  final double progress;
  const _SavingView({required this.step, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress <= 0 ? null : progress,
                    strokeWidth: 6,
                    color: ThemeColors.primary,
                  ),
                ),
                Text('${(progress * 100).round()}%'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Downloading your primary Bible',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            step,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: ThemeColors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your other Bibles will download in the background.',
            style: TextStyle(fontSize: 12, color: ThemeColors.mediumGrey),
          ),
        ],
      ),
    );
  }
}

class _SaveFailedView extends StatelessWidget {
  final String message;
  final double progress;
  const _SaveFailedView({required this.message, required this.progress});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BibleSelectionBloc>();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: ThemeColors.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}% downloaded',
            style: const TextStyle(fontSize: 12, color: ThemeColors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => bloc.add(const BibleSelectionRestart()),
                child: const Text('Restart'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () => bloc.add(const BibleSelectionContinue()),
                style: FilledButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
