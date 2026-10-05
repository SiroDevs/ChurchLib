class PrefConstants {
  static const appThemeKey = 'app_theme';
  static const darkModeKey = 'dark_mode';

  static const isLoggedInKey = 'is_logged_in';
  static const emailKey = 'email_address';
  static const userNameKey = 'username';
  static const passWordKey = 'password';
  static const filePathkey = 'file_path';
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const expiresInKey = 'expires_in';

  // SongLib's setup progress. These are the original keys from
  // songlib-flutter — Step1Bloc/Step2Bloc already read/write them, so they
  // are left as-is and simply treated as "SongLib's" state in ChurchLib
  // (as opposed to introducing a parallel songlib_* pair and touching the
  // generated bloc code).
  static const dataIsSelectedKey = 'data_selected';
  static const dataIsLoadedKey = 'data_loaded';

  // BibleLib's equivalent setup progress, namespaced since it's a second,
  // independent module living alongside SongLib in the same app/db.
  static const biblelibDataSelectedKey = 'biblelib_data_selected';
  static const biblelibDataLoadedKey = 'biblelib_data_loaded';

  // BibleLib selection + reading position, mirroring biblelib-android's
  // PrefsRepo (selectedBibles / primaryBible / secondaryBibles / last*).
  static const bibleSelectedBiblesKey = 'bible_selected_bibles';
  static const biblePrimaryKey = 'bible_primary';
  static const bibleSecondaryKey = 'bible_secondary';
  static const bibleLastBibleKey = 'bible_last_bible';
  static const bibleLastBibleAbbrKey = 'bible_last_bible_abbr';
  static const bibleLastBookIdKey = 'bible_last_book_id';
  static const bibleLastChapterIdKey = 'bible_last_chapter_id';
  static const bibleLastVerseIdKey = 'bible_last_verse_id';
  static const bibleFontSizeKey = 'bible_font_size_sp';
  static const bibleMultiBibleEnabledKey = 'bible_multi_bible_enabled';

  // ChurchLib module selection: which of SongLib/BibleLib the user opted
  // into on the welcome screen. Independent of whether each module has
  // finished its own setup above.
  static const songlibModuleEnabledKey = 'module_songlib_enabled';
  static const biblelibModuleEnabledKey = 'module_biblelib_enabled';

  static const dateInstalledKey = 'date_installed';
  static const notSongDraftKey = 'not_draft';
  static const onboardedCheckKey = 'on_boarded';
  static const predistinatedBooksKey = 'predestinated_books';
  static const selectedBooksKey = 'selected_books';
  static const slideVerticalKey = 'slide_vertically';
  static const pcHintsKey = 'pc_hints';
  static const uninstallCheckKey = 'uninstall_check';
  static const donationCheckKey = 'donation_check';
  static const wakeLockCheckKey = 'wake_lock_check';
}