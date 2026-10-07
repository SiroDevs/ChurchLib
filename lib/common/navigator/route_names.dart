/// Route names for go_router — every [GoRoute] is registered with a
/// matching `name:`, so call sites navigate with `context.goNamed(...)` /
/// `context.pushNamed(...)` instead of hard-coded path strings. See
/// `app_routes.dart`.
class RouteNames {
  RouteNames._();

  static const splash = 'splash';
  static const selection = 'selection';
  static const biblelibSetup = 'biblelib_setup';
  static const bibleSearch = 'bible_search';
  static const bibleHistory = 'bible_history';
  static const bibleBookmarksNotes = 'bible_bookmarks_notes';
  static const bibles = 'bibles';
  static const main = 'main';
  static const settings = 'settings';
  static const presentor = 'presentor';
  static const scriptureLists = 'scripture_lists';
  static const scriptureOpener = 'scripture_opener';
  static const scriptureListDetail = 'scripture_list_detail';
}
