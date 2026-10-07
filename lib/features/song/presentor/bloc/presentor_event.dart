part of 'presentor_bloc.dart';

sealed class PresentorEvent {
  const PresentorEvent();
}

class LoadSong extends PresentorEvent {
  const LoadSong(this.song);
  final SongExt song;
}

class LikeSong extends PresentorEvent {
  const LikeSong(this.song);
  final SongExt song;
}

class SaveHistory extends PresentorEvent {
  const SaveHistory(this.song);
  final SongExt song;
}
