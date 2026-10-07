// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/constants/app_assets.dart';
import '../../../../core/theme/theme_styles.dart';
import '../../../../data/models/song/songbook.dart';
import '../../../../domain/entities/basic_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common/widgets/general/list_items.dart';
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../common/widgets/state/general_progress.dart';
import '../../../../common/widgets/state/skeleton.dart';
import '../../bloc/selection_bloc.dart';
import '../widgets/steps/step_action_bar.dart';

class SongbooksStep extends StatefulWidget {
  final VoidCallback? onBack;
  const SongbooksStep({super.key, this.onBack});

  @override
  State<SongbooksStep> createState() => _SongbooksStepState();
}

class _SongbooksStepState extends State<SongbooksStep> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<SelectionBloc>();
    final status = bloc.state.booksStatus;
    if (status != LoadStatus.loaded && status != LoadStatus.loading) {
      bloc.add(const BooksRequested());
    }
  }

  Future<void> _proceed(SelectionState state, AppLocalizations l10n) async {
    if (state.selectedBookNos.isNotEmpty) {
      final result = await FlutterPlatformAlert.showCustomAlert(
        windowTitle: l10n.doneSelecting,
        text: l10n.doneSelectingBody,
        iconPath: AppAssets.iconApp,
        iconStyle: IconStyle.information,
        neutralButtonTitle: l10n.cancel.toUpperCase(),
        positiveButtonTitle: l10n.proceed.toUpperCase(),
      );
      if (result == CustomButton.positiveButton && mounted) {
        context.read<SelectionBloc>().add(const BooksConfirmed());
      }
    } else {
      await FlutterPlatformAlert.showCustomAlert(
        windowTitle: l10n.noSelection,
        text: l10n.noSelectionBody,
        iconPath: AppAssets.iconApp,
        iconStyle: IconStyle.warning,
        neutralButtonTitle: l10n.okay.toUpperCase(),
      );
    }
  }

  Widget _booksView(SelectionState state, Size size) {
    final bloc = context.read<SelectionBloc>();
    final books = state.books;

    Widget item(SongBook book) => BookItem(
          item: Selectable<SongBook>(
            book,
            state.selectedBookNos.contains(book.bookNo),
          ),
          onPressed: () {
            final no = book.bookNo;
            if (no == null) {
              logger('Book without a number: ${book.title}');
              return;
            }
            bloc.add(BookToggled(no));
          },
        );

    if (size.shortestSide > 550) {
      return LayoutBuilder(
        builder: (context, dimens) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (dimens.maxWidth / 400).round().clamp(1, 6),
            childAspectRatio: 4,
          ),
          padding: const EdgeInsets.all(Sizes.xs),
          itemCount: books.length,
          itemBuilder: (context, index) => item(books[index]),
        ),
      );
    }
    return ListView.builder(
      itemCount: books.length,
      padding: const EdgeInsets.all(Sizes.xs),
      itemBuilder: (context, index) => item(books[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return BlocConsumer<SelectionBloc, SelectionState>(
      listenWhen: (p, c) => p.booksStatus != c.booksStatus,
      listener: (context, state) {
        if (state.booksStatus == LoadStatus.failure) {
          CustomSnackbar.show(
            context,
            feedbackMessage(state.booksError, l10n),
          );
        } else if (state.booksStatus == LoadStatus.loaded) {
          CustomSnackbar.show(context, l10n.availableBooks, isSuccess: true);
        }
      },
      builder: (context, state) {
        final bloc = context.read<SelectionBloc>();
        return Column(
          children: [
            Expanded(
              child: switch (state.booksStatus) {
                LoadStatus.idle || LoadStatus.loading => const SelectionLoading(),
                LoadStatus.noInternet => EmptyState(
                    title: l10n.noConnection,
                    message: l10n.noConnectionBody,
                    showRetry: true,
                    onRetry: () => bloc.add(const BooksRequested()),
                  ),
                LoadStatus.failure => EmptyState(
                    title: l10n.nothingHere,
                    showRetry: true,
                    onRetry: () => bloc.add(const BooksRequested()),
                  ),
                LoadStatus.loaded => _booksView(state, size),
              },
            ),
            StepActionBar(
              label: l10n.proceed.toUpperCase(),
              onBack: widget.onBack,
              onPressed: state.booksStatus == LoadStatus.loaded
                  ? () => _proceed(state, l10n)
                  : null,
            ),
          ],
        );
      },
    );
  }
}
