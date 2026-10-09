// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../common/navigator/route_names.dart';
import '../../../../common/windows/window_frame.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../bloc/bibles_cubit.dart';
import 'widgets/bibles_dialogs.dart';
import 'widgets/multi_bible_toggle_card.dart';
import 'widgets/other_bibles_card.dart';
import 'widgets/primary_bible_card.dart';
import 'widgets/secondary_bibles_card.dart';
import 'widgets/section_header_row.dart';

class BiblesScreen extends StatelessWidget {
  const BiblesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BiblesCubit(),
      child: _BiblesView(embedded: embedded),
    );
  }
}

class _BiblesView extends StatefulWidget {
  const _BiblesView({required this.embedded});

  final bool embedded;

  @override
  State<_BiblesView> createState() => _BiblesViewState();
}

class _BiblesViewState extends State<_BiblesView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<BiblesCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && cubit.takeFirstOpenTip()) showFirstOpenPrompt(context);
    });
  }

  void _changeSelection() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.pushNamed(RouteNames.biblelibSetup);
  }

  Future<void> _delete(BibleVersion bible) async {
    final cubit = context.read<BiblesCubit>();
    if (await confirmDeleteBible(context, bible)) {
      await cubit.deleteBible(bible.abbreviation);
    }
  }

  Future<void> _pickPrimary(BiblesState state) async {
    final cubit = context.read<BiblesCubit>();
    final chosen = await pickPrimaryBible(
      context,
      bibles: state.bibles,
      current: state.primaryAbbr,
    );
    if (chosen != null) cubit.setPrimaryBible(chosen);
  }

  Widget _content(BiblesState state) {
    final cubit = context.read<BiblesCubit>();
    final primary =
        state.bibles.where((b) => b.abbreviation == state.primaryAbbr).firstOrNull;
    final others = state.bibles.where((b) {
      if (b.abbreviation == state.primaryAbbr) return false;
      return !state.multiBibleEnabled ||
          !state.secondaryBibles.contains(b.abbreviation);
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 90),
          children: [
            if (widget.embedded)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'How Bible management works',
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showBiblesInfo(context),
                ),
              ),
            SectionHeaderRow(
              left: SectionHeaderRow.label(context, 'Primary Bible'),
              right: SectionHeaderRow.label(context, 'Click to Change'),
            ),
            PrimaryBibleCard(primary: primary, onTap: () => _pickPrimary(state)),
            const SizedBox(height: 12),
            MultiBibleToggleCard(
              enabled: state.multiBibleEnabled,
              onChanged: cubit.setMultiBibleEnabled,
            ),
            if (state.multiBibleEnabled) ...[
              const SizedBox(height: 12),
              SecondaryBiblesCard(state: state, cubit: cubit, onDelete: _delete),
            ],
            if (others.isNotEmpty) ...[
              const SizedBox(height: 12),
              OtherBiblesCard(
                bibles: others,
                state: state,
                cubit: cubit,
                onDelete: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.embedded
          ? null
          : WindowAppBar(
              icon: Icons.library_books_outlined,
              title: 'Manage Bibles',
              actions: [
                IconButton(
                  tooltip: 'How Bible management works',
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showBiblesInfo(context),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _changeSelection,
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Change Selection'),
      ),
      body: BlocBuilder<BiblesCubit, BiblesState>(
        builder: (context, state) => state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _content(state),
      ),
    );
  }
}
