// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../common/windows/window_frame.dart';
import '../../../../domain/entities/bible/bible_reader.dart';
import '../../../../domain/entities/bible/verse_display.dart';
import '../cubit/bible_search_cubit.dart';
import 'widgets/bible_search_body.dart';

class BibleSearchScreen extends StatelessWidget {
  const BibleSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BibleSearchCubit(),
      child: const _BibleSearchView(),
    );
  }
}

class _BibleSearchView extends StatefulWidget {
  const _BibleSearchView();

  @override
  State<_BibleSearchView> createState() => _BibleSearchViewState();
}

class _BibleSearchViewState extends State<_BibleSearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _searchFromHistory(String qry) {
    _controller.text = qry;
    _controller.selection = TextSelection.collapsed(offset: qry.length);
    context.read<BibleSearchCubit>().searchFromHistory(qry);
  }

  void _clearQuery() {
    _controller.clear();
    context.read<BibleSearchCubit>().clearQuery();
  }

  void _openResult(BuildContext context, VerseDisplay verse, String abbr) {
    Navigator.of(context).pop(
      ReaderTarget(
        bibleAbbr: abbr,
        bookId: verse.bookId,
        chapterId: verse.chapterId,
        verseId: verse.verseId,
        searchQuery: _controller.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleSearchCubit, BibleSearchState>(
      builder: (context, state) {
        final cubit = context.read<BibleSearchCubit>();
        return Scaffold(
          appBar: WindowAppBar(
            icon: Icons.search,
            titleWidget: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: cubit.onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search scriptures ...',
                border: InputBorder.none,
                suffixIcon: state.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close),
                        onPressed: _clearQuery,
                      ),
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                children: [
                  if (state.bibles.length > 1)
                    BibleFilterStrip(state: state, onSelect: cubit.selectBible),
                  Expanded(
                    child: BibleSearchResults(
                      state: state,
                      onTapResult: (verse) =>
                          _openResult(context, verse, state.selectedAbbr),
                      onTapHistory: _searchFromHistory,
                      onClearHistory: cubit.clearHistory,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
