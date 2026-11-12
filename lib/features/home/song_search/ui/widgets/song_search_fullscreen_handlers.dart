part of '../song_search_screen.dart';

extension SongSearchFullscreenHandlers on SongSearchScreenState {
  void _onFullScreenChanged() {
    if (!AppWindow.fullScreen.value || _presenting || !mounted) return;
    final current = HomeModuleScope.maybeOf(context)?.current;
    if (current != null && current != AppModule.songlib) return;
    if (selectedSong.songId == 0 || books.isEmpty) {
      AppWindow.setFullScreen(false);
      return;
    }
    openFullScreenPresenter();
  }
}
