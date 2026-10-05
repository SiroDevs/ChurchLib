// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../../../../common/utils/app_util.dart';
import '../../../../common/utils/constants/pref_constants.dart';
import '../../../../common/utils/network_utils.dart';
import '../../../../core/di/injectable.dart';
import '../../../../data/models/song/songbook.dart';
import '../../../../domain/entities/basic_model.dart';
import '../../../../domain/repos/database_repo.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../../../domain/repos/song/song_selection_repo.dart';

part 'step1_event.dart';
part 'step1_state.dart';
part 'step1_bloc.freezed.dart';

class Step1Bloc extends Bloc<Step1Event, Step1State> {
  Step1Bloc() : super(const _Step1State()) {
    on<FetchBooks>(_onFetchBooks);
    on<SaveBooks>(_onSaveBooks);
  }

  final _selectRepo = SongSelectionRepo();
  final _prefRepo = getIt<PrefRepo>();
  final _dbRepo = getIt<DatabaseRepo>();

  void _onFetchBooks(FetchBooks event, Emitter<Step1State> emit) async {
    emit(Step1ProgressState());
    if (await NetworkUtil.hasInternetConnection()) {
      var resp = await _selectRepo.getBooks();
      String selectedBooksIds = _prefRepo.getPrefString(
        PrefConstants.selectedBooksKey,
      );
      List<String> selectedBooksNumbers = [];
      List<Selectable<SongBook>> booksListing = [];

      if (selectedBooksIds.isNotEmpty) {
        selectedBooksNumbers = selectedBooksIds.split(",");
      }
      try {
        switch (resp.statusCode) {
          case 200:
            List<dynamic> dataList = List<Map<String, dynamic>>.from(
              jsonDecode(resp.body),
            );
            var books = dataList.map((item) => SongBook.fromJson(item)).toList();
            for (final book in books) {
              bool setSelected = false;
              if (selectedBooksNumbers.contains(book.bookNo.toString())) {
                setSelected = true;
              }
              booksListing.add(Selectable<SongBook>(book, setSelected));
            }
            emit(Step1FetchedState(selectedBooksIds, books, booksListing));
            break;

          default:
            emit(Step1FailureState(resp.statusCode.toString()));
            break;
        }
      } catch (e) {
        logger("Error log: $e");
        emit(Step1FailureState('100'));
      }
    } else {
      emit(Step1NoInternetState());
    }
  }

  void _onSaveBooks(SaveBooks event, Emitter<Step1State> emit) async {
    emit(Step1ProgressState());
    String selectedBooks = event.selectedBooksIds;
    try {
      if (event.selectedBooksIds.isNotEmpty) {
        await _dbRepo.removeAllBooks();
        _prefRepo.setPrefString(
          PrefConstants.predistinatedBooksKey,
          selectedBooks,
        );
        selectedBooks = "";
      }
      for (final book in event.books) {
        selectedBooks = "$selectedBooks${book.bookNo},";
        await _dbRepo.saveBook(book);
      }
      selectedBooks = selectedBooks.substring(0, selectedBooks.length - 1);
      _prefRepo.setPrefString(PrefConstants.selectedBooksKey, selectedBooks);

      _prefRepo.setPrefBool(PrefConstants.dataIsSelectedKey, true);
      _prefRepo.setPrefBool(PrefConstants.slideVerticalKey, true);
    } catch (e) {
      logger('Unable to save books: $e');
    }

    emit(Step1SavedState(selectedBooks));
  }
}
