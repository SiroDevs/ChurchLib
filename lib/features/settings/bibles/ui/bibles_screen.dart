// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/navigator/route_names.dart';
import '../../../../common/windows/window_frame.dart';
import '../../../../core/theme/theme_fonts.dart';
import '../../../../core/theme/theme_styles.dart';
import '../../../../data/models/bible/bible_version.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/bibles_cubit.dart';
import 'widgets/cards/multi_bible_toggle_card.dart';
import 'widgets/cards/other_bibles_card.dart';
import 'widgets/cards/primary_bible_card.dart';
import 'widgets/cards/secondary_bibles_card.dart';
import 'widgets/rows/bibles_dialogs.dart';
import 'widgets/rows/section_header_row.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<BiblesCubit>();
    final primary = state.bibles
        .where((b) => b.abbreviation == state.primaryAbbr)
        .firstOrNull;
    final others = state.bibles.where((b) {
      if (b.abbreviation == state.primaryAbbr) return false;
      return !state.multiBibleEnabled ||
          !state.secondaryBibles.contains(b.abbreviation);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 90),
      children: [
        if (widget.embedded)
          Row(
            children: [
              Text(
                l10n.manageYourBibles,
                style: TextStyles.headingStyle3,
              ).padding(left: Sizes.sm, top: Sizes.sm),
              const Spacer(),
              IconButton(
                tooltip: l10n.howBibleManagementWorks,
                icon: const Icon(Icons.info_outline),
                onPressed: () => showBiblesInfo(context),
              ),
            ],
          ),
        SectionHeaderRow(
          left: SectionHeaderRow.label(context, l10n.primaryBible),
          right: SectionHeaderRow.label(context, l10n.clickToChange),
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
    ).constrained(maxWidth: 720).center();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: widget.embedded
          ? null
          : WindowAppBar(
              icon: Icons.library_books_outlined,
              title: l10n.manageBibles,
              actions: [
                IconButton(
                  tooltip: l10n.howBibleManagementWorks,
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showBiblesInfo(context),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _changeSelection,
        icon: const Icon(Icons.swap_horiz),
        label: Text(l10n.changeSelection),
      ),
      body: BlocBuilder<BiblesCubit, BiblesState>(
        builder: (context, state) => state.isLoading
            ? CircularProgressIndicator().center()
            : _content(state),
      ),
    );
  }
}
