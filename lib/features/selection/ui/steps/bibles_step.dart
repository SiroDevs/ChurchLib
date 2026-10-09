// Flutter imports:
// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/widgets/state/error_view.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../bloc/selection_bloc.dart';
import '../../utils/bible_grouping.dart';
import '../widgets/bible_tile.dart';
import '../widgets/selection_title.dart';

part 'bibles_step_builders.dart';
part 'bibles_step_list.dart';

class BiblesStep extends StatefulWidget {
  const BiblesStep({super.key});

  @override
  State<BiblesStep> createState() => _BiblesStepState();
}

class _BiblesStepState extends State<BiblesStep> with BiblesStepBuilders, BiblesStepList {
  String _query = '';
  GroupingMode _grouping = GroupingMode.regions;
  final Map<String, bool> _expanded = {};
  final Map<String, String> _countryFilters = {};

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
}
