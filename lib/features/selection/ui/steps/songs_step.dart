import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/constants/app_assets.dart';
import '../../../../common/widgets/general/list_items.dart';
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../common/widgets/state/general_progress.dart';
import '../../../../common/widgets/state/skeleton.dart';
import '../../../../core/theme/theme_styles.dart';
import '../../../../data/models/song/songbook.dart';
import '../../../../domain/entities/basic_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../bloc/selection_bloc.dart';
import '../widgets/selection_title.dart';

Future<void> confirmSongbooks(
  BuildContext context,
  SelectionState state,
) async {
  final l10n = AppLocalizations.of(context)!;
  final bloc = context.read<SelectionBloc>();
  if (state.selectedBookIds.isEmpty) {
    await FlutterPlatformAlert.showCustomAlert(
      windowTitle: l10n.noSelection,
      text: l10n.noSelectionBody,
      iconPath: AppAssets.iconApp,
      iconStyle: IconStyle.warning,
      neutralButtonTitle: l10n.okay.toUpperCase(),
    );
  } else {
    bloc.add(const BooksConfirmed());
  }
}

class SongsStep extends StatefulWidget {
  const SongsStep({super.key});

  @override
  State<SongsStep> createState() => _SongsStepState();
}

class _SongsStepState extends State<SongsStep> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<SelectionBloc>();
    final status = bloc.state.booksStatus;
    if (status != LoadStatus.loaded && status != LoadStatus.loading) {
      bloc.add(const BooksRequested());
    }
  }

  Widget _booksView(SelectionState state) {
    final bloc = context.read<SelectionBloc>();
    final books = state.books;

    Widget item(SongBook book) => BookItem(
      item: Selectable<SongBook>(
        book,
        state.selectedBookIds.contains(book.bookId),
      ),
      onPressed: () {
        final id = book.bookId;
        if (id == null) {
          logger('Book without an id: ${book.title}');
          return;
        }
        if (!state.selectedBookIds.contains(id) &&
            state.selectedBookIds.length >= maxSongbookSelections) {
          CustomSnackbar.show(
            context,
            'You can select up to $maxSongbookSelections songbooks',
          );
          return;
        }
        bloc.add(BookToggled(id));
      },
    );

    final grid = GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 96,
      ),
      padding: const EdgeInsets.all(Sizes.xs),
      itemCount: books.length,
      itemBuilder: (context, index) => item(books[index]),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectionTitle(
          title: 'Choose your Songbooks',
          noun: 'songbooks',
          count: state.selectedBookIds.length,
          max: maxSongbookSelections,
        )
            .padding(left: 24, top: 16, right: 24, bottom: 8),
        grid.expanded(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<SelectionBloc, SelectionState>(
      listenWhen: (p, c) => p.booksStatus != c.booksStatus,
      listener: (context, state) {
        if (state.booksStatus == LoadStatus.failure) {
          CustomSnackbar.show(context, feedbackMessage(state.booksError, l10n));
        }
      },
      builder: (context, state) {
        final bloc = context.read<SelectionBloc>();
        return switch (state.booksStatus) {
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
          LoadStatus.loaded => _booksView(state),
        };
      },
    );
  }
}
