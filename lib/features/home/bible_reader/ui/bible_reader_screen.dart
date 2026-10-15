// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../cubit/bible_reader_cubit.dart';
import 'bible_reader_view.dart';

class BibleReaderScreen extends StatelessWidget {
  final String bibleAbbr;
  final String bookId;
  final String chapterId;
  final String verseId;
  final String searchQuery;

  const BibleReaderScreen({
    super.key,
    this.bibleAbbr = '',
    this.bookId = '',
    this.chapterId = '',
    this.verseId = '',
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BibleReaderCubit()
        ..initialize(
          initialBibleAbbr: bibleAbbr,
          initialBookId: bookId,
          initialChapterId: chapterId,
          initialVerseId: verseId,
          initialSearchQry: searchQuery,
        ),
      child: const BiblerReaderView(),
    );
  }
}
