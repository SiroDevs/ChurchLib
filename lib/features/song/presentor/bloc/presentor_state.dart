part of 'presentor_bloc.dart';

sealed class PresentorState extends Equatable {
  const PresentorState();

  @override
  List<Object?> get props => [];
}

class _PresentorState extends PresentorState {
  const _PresentorState();
}

class PresentorLoadedState extends PresentorState {
  const PresentorLoadedState(this.tabs, this.stanzas);
  final List<Tab> tabs;
  final List<String> stanzas;

  @override
  List<Object?> get props => [tabs, stanzas];
}

class PresentorProgressState extends PresentorState {
  const PresentorProgressState();
}

class PresentorSuccessState extends PresentorState {
  const PresentorSuccessState();
}

class PresentorLikedState extends PresentorState {
  const PresentorLikedState(this.liked);
  final bool liked;

  @override
  List<Object?> get props => [liked];
}

class PresentorHistoryState extends PresentorState {
  const PresentorHistoryState();
}

class PresentorFailureState extends PresentorState {
  const PresentorFailureState(this.feedback);
  final String feedback;

  @override
  List<Object?> get props => [feedback];
}
