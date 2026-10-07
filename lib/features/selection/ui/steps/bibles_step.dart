// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/widgets/state/error_view.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/sources/remote/bible/bible_dtos.dart';
import '../../bloc/selection_bloc.dart';
import '../widgets/bible_tile.dart';
import '../widgets/steps/step_action_bar.dart';

enum _Grouping { countries, languages, none }

class BiblesStep extends StatefulWidget {
  final VoidCallback? onBack;
  const BiblesStep({super.key, this.onBack});

  @override
  State<BiblesStep> createState() => _BiblesStepState();
}

class _BiblesStepState extends State<BiblesStep> {
  String _query = '';
  _Grouping _grouping = _Grouping.countries;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<SelectionBloc>();
    if (bloc.state.availableBibles.isEmpty &&
        bloc.state.bibleStatus != BibleStatus.error) {
      bloc.add(const BiblesRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectionBloc, SelectionState>(
      builder: (context, state) => switch (state.bibleStatus) {
        BibleStatus.loading => const Center(
            child: CircularProgressIndicator(color: ThemeColors.primary),
          ),
        BibleStatus.error => ErrorView(
            message: state.bibleMessage,
            onRetry: () => context
                .read<SelectionBloc>()
                .add(const BiblesRequested()),
          ),
        BibleStatus.loaded => _buildPicker(context, state),
        BibleStatus.saving ||
        BibleStatus.saved ||
        BibleStatus.saveFailed =>
          const SizedBox.shrink(),
      },
    );
  }

  Widget _buildPicker(BuildContext context, SelectionState state) {
    final q = _query.trim().toLowerCase();
    final filtered = state.availableBibles.where((b) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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
                    onSelectionChanged: (s) =>
                        setState(() => _grouping = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No Bibles match your search'))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        BibleTile(
                          bible: b,
                          selected: state.selectedAbbrs.contains(b.abbreviation),
                          isPrimary: state.selectedAbbrs.isNotEmpty &&
                              state.selectedAbbrs.first == b.abbreviation,
                          atLimit:
                              state.selectedAbbrs.length >= state.maxSelections,
                        ),
                    ],
                  ],
                ),
        ),
        StepActionBar(
          label: 'Download & Continue',
          onBack: widget.onBack,
          onPressed: state.canProceedBibles
              ? () => context
                  .read<SelectionBloc>()
                  .add(const BiblesConfirmed())
              : null,
        ),
      ],
    );
  }
}
