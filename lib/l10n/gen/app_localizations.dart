import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// Label for feedback section or button
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'ChurchLib'**
  String get appName;

  /// Title for song lists section
  ///
  /// In en, this message translates to:
  /// **'Song Lists'**
  String get listTitle;

  /// Title for search songs section
  ///
  /// In en, this message translates to:
  /// **'Search Songs'**
  String get searchTitle;

  /// Title for liked songs section
  ///
  /// In en, this message translates to:
  /// **'Liked Songs'**
  String get likesTitle;

  /// Title for song history section
  ///
  /// In en, this message translates to:
  /// **'Histories'**
  String get historiesTitle;

  /// Title for song drafts section
  ///
  /// In en, this message translates to:
  /// **'Song Drafts'**
  String get draftTitle;

  /// Title for settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title for help desk section
  ///
  /// In en, this message translates to:
  /// **'Help Desk'**
  String get helpdeskTitle;

  /// Title for donation information section
  ///
  /// In en, this message translates to:
  /// **'How to Donate'**
  String get donateTitle;

  /// Title for merchandise section
  ///
  /// In en, this message translates to:
  /// **'Buy our Merchandise'**
  String get merchandiseTitle;

  /// Title for song book selection
  ///
  /// In en, this message translates to:
  /// **'Select Song Books'**
  String get booksTitle;

  /// Loading message while fetching song books data
  ///
  /// In en, this message translates to:
  /// **'Loading data ...'**
  String get booksTitleLoading;

  /// Title for home section
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Title for adding new song list
  ///
  /// In en, this message translates to:
  /// **'Adding a new list'**
  String get listedTitle;

  /// Title for song drafting/editing screen
  ///
  /// In en, this message translates to:
  /// **'Drafting a new song'**
  String get editorTitle;

  /// Placeholder for song title input
  ///
  /// In en, this message translates to:
  /// **'Your song in one line'**
  String get songTitle;

  /// Placeholder for song lyrics/content input
  ///
  /// In en, this message translates to:
  /// **'The rest of your song'**
  String get songText;

  /// Label for chorus toggle/checkbox
  ///
  /// In en, this message translates to:
  /// **'With a Chorus'**
  String get hasChorus;

  /// Label for song verses
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get verses;

  /// Action to add song to a list
  ///
  /// In en, this message translates to:
  /// **'Add to a List'**
  String get addtoList;

  /// Action description for adding song to list
  ///
  /// In en, this message translates to:
  /// **'Add this song to a List'**
  String get addSongtoList;

  /// Action to like/favorite a song
  ///
  /// In en, this message translates to:
  /// **'Like this song'**
  String get likeSong;

  /// Action to edit a song
  ///
  /// In en, this message translates to:
  /// **'Edit this song'**
  String get editSong;

  /// Action to delete a song
  ///
  /// In en, this message translates to:
  /// **'Delete this song'**
  String get deleteSong;

  /// Action to copy a song
  ///
  /// In en, this message translates to:
  /// **'Copy this song'**
  String get copySong;

  /// Action to delete a song list
  ///
  /// In en, this message translates to:
  /// **'Delete this list'**
  String get deleteList;

  /// Action to share a song
  ///
  /// In en, this message translates to:
  /// **'Share this song'**
  String get shareSong;

  /// Success message when song is copied
  ///
  /// In en, this message translates to:
  /// **'song copied!'**
  String get songCopied;

  /// Action to copy a verse
  ///
  /// In en, this message translates to:
  /// **'Copy verse'**
  String get copyVerse;

  /// Success message when text is copied
  ///
  /// In en, this message translates to:
  /// **' copied!'**
  String get textCopied;

  /// Action to share a verse
  ///
  /// In en, this message translates to:
  /// **'Share verse'**
  String get shareVerse;

  /// Action to project/present a song
  ///
  /// In en, this message translates to:
  /// **'Project this Song'**
  String get projectSong;

  /// Success message when song is added to favorites
  ///
  /// In en, this message translates to:
  /// **'Song added to Favorites!'**
  String get songLiked;

  /// Message when song is removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Song removed from Favorites!'**
  String get songDisliked;

  /// Tooltip or label for like action
  ///
  /// In en, this message translates to:
  /// **'Add this Song to Favorites!'**
  String get songLike;

  /// Tooltip or label for unlike action
  ///
  /// In en, this message translates to:
  /// **'Remove this Song from Favorites!'**
  String get songDislike;

  /// Success message when song is added to a list
  ///
  /// In en, this message translates to:
  /// **' added to '**
  String get songAddedToList;

  /// Success message when list is created
  ///
  /// In en, this message translates to:
  /// **'song list created!'**
  String get listCreated;

  /// Success message when list is updated
  ///
  /// In en, this message translates to:
  /// **'song list updated!'**
  String get listUpdated;

  /// Success message when item is deleted
  ///
  /// In en, this message translates to:
  /// **'deleted!'**
  String get deleted;

  /// Message indicating content is ready to share
  ///
  /// In en, this message translates to:
  /// **'Ready for sharing'**
  String get readyShare;

  /// Action to take screenshot of verse
  ///
  /// In en, this message translates to:
  /// **'Screenshot verse'**
  String get screenshotVerse;

  /// Success message when screenshot is taken
  ///
  /// In en, this message translates to:
  /// **'We have your screenshot!'**
  String get screenshoted;

  /// Title for app settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appSettings;

  /// Title for display settings section
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displayTitle;

  /// Title for user's collection section
  ///
  /// In en, this message translates to:
  /// **'Your Collection'**
  String get collectionTitle;

  /// Title for song presentation settings
  ///
  /// In en, this message translates to:
  /// **'Song Presentation'**
  String get presentationTitle;

  /// Label for app theme setting
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// Description showing current theme
  ///
  /// In en, this message translates to:
  /// **'Current Theme:'**
  String get appThemeDesc;

  /// Action to reselect songbooks
  ///
  /// In en, this message translates to:
  /// **'Select Songbooks Afresh'**
  String get reselectSongbooks;

  /// Description for reselecting songbooks
  ///
  /// In en, this message translates to:
  /// **'Restructure your collection once again'**
  String get reselectSongbooksDesc;

  /// Label for song presentation direction setting
  ///
  /// In en, this message translates to:
  /// **'Slide Scroll Direction'**
  String get songPresentation;

  /// Description for song presentation direction
  ///
  /// In en, this message translates to:
  /// **'Song slides to scroll vertically'**
  String get songPresentationDesc;

  /// Starts presentation mode
  ///
  /// In en, this message translates to:
  /// **'Start presenting'**
  String get presentationStart;

  /// Stops presentation mode
  ///
  /// In en, this message translates to:
  /// **'Stop presenting'**
  String get presentationStop;

  /// Heading above the local presentation preview
  ///
  /// In en, this message translates to:
  /// **'Presentation preview'**
  String get presentationPreview;

  /// Moves to the previous presentation slide
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get presentationPrevious;

  /// Moves to the next presentation slide
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get presentationNext;

  /// Reduces presentation text size
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get presentationSmaller;

  /// Increases presentation text size
  ///
  /// In en, this message translates to:
  /// **'Bigger'**
  String get presentationLarger;

  /// Cycles presentation text alignment
  ///
  /// In en, this message translates to:
  /// **'Text alignment'**
  String get presentationAlign;

  /// Left text alignment
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get presentationLeft;

  /// Centered text alignment
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get presentationCenter;

  /// Right text alignment
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get presentationRight;

  /// Turns the audience screen black
  ///
  /// In en, this message translates to:
  /// **'Blackout'**
  String get presentationBlackout;

  /// Restores the audience screen after blackout
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get presentationShow;

  /// Stops the current presentation
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get presentationStopAction;

  /// Tooltip for the previous slide button
  ///
  /// In en, this message translates to:
  /// **'Previous (Up)'**
  String get presentationPreviousTooltip;

  /// Tooltip for the next slide button
  ///
  /// In en, this message translates to:
  /// **'Next (Down)'**
  String get presentationNextTooltip;

  /// Tooltip for reducing presentation text size
  ///
  /// In en, this message translates to:
  /// **'Smaller text (-)'**
  String get presentationSmallerTooltip;

  /// Tooltip for increasing presentation text size
  ///
  /// In en, this message translates to:
  /// **'Bigger text (=)'**
  String get presentationLargerTooltip;

  /// Tooltip for audience screen blackout
  ///
  /// In en, this message translates to:
  /// **'Blackout the screen'**
  String get presentationBlackoutTooltip;

  /// Tooltip for stopping presentation mode
  ///
  /// In en, this message translates to:
  /// **'Stop presenting (Esc)'**
  String get presentationStopTooltip;

  /// Title of the audience display window
  ///
  /// In en, this message translates to:
  /// **'ChurchLib · Audience'**
  String get presentationWindowTitle;

  /// Action to show the current Bible chapter on the audience display
  ///
  /// In en, this message translates to:
  /// **'Present Bible'**
  String get presentationPresentBible;

  /// Title for theme selection dialog
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Option for system default theme
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeDefault;

  /// Option for light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Option for dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Confirmation button text
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Action to open app settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Button to postpone reminder
  ///
  /// In en, this message translates to:
  /// **'Remind Me Later'**
  String get remind;

  /// Action to make donation
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// Action to continue/next
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// Attention-grabbing dialog title
  ///
  /// In en, this message translates to:
  /// **'Just a minute!'**
  String get justAMinute;

  /// Title for support/donation request
  ///
  /// In en, this message translates to:
  /// **'Support ChurchLib'**
  String get supportSongLib;

  /// Title for reminder dialog
  ///
  /// In en, this message translates to:
  /// **'Let\'s remind you'**
  String get notificationDialog;

  /// Error message when no song is selected
  ///
  /// In en, this message translates to:
  /// **'No song item has been selected'**
  String get noSongSelected;

  /// Shown when the local song library has no songbooks
  ///
  /// In en, this message translates to:
  /// **'No songbooks are available. Select songbooks to set up SongLib.'**
  String get noSongbooksAvailable;

  /// Shown when the selected songbook has no songs
  ///
  /// In en, this message translates to:
  /// **'No songs are available in this songbook.'**
  String get noSongsInSongbook;

  /// Action to select songs again
  ///
  /// In en, this message translates to:
  /// **'Select Songs Afresh'**
  String get selectSongsAfresh;

  /// Error message when songs cannot be displayed
  ///
  /// In en, this message translates to:
  /// **'Oops there is a problem displaying songs under the book you selected.\n\nYou can fix the issue by selecting them afresh'**
  String get problemDisplaySongs;

  /// Title for donation request
  ///
  /// In en, this message translates to:
  /// **'Donation Request'**
  String get donationRequest;

  /// Body text for donation request
  ///
  /// In en, this message translates to:
  /// **'ChurchLib has a lot in the pipelines and will need your support to accomplish that.'**
  String get donationRequestBody;

  /// Prompt to confirm selection completion
  ///
  /// In en, this message translates to:
  /// **'Done with selecting?'**
  String get doneSelecting;

  /// Body text for selection completion prompt
  ///
  /// In en, this message translates to:
  /// **'If you are done selecting please proceed ahead. We can always bring you back here to reselect afresh.'**
  String get doneSelectingBody;

  /// Error message when no selection is made
  ///
  /// In en, this message translates to:
  /// **'Oops! No selection found'**
  String get noSelection;

  /// Body text for no selection error
  ///
  /// In en, this message translates to:
  /// **'Please select at least 1 book to proceed to the next step.'**
  String get noSelectionBody;

  /// Title for unexpected error
  ///
  /// In en, this message translates to:
  /// **'Wueh! You weren\'t supposed to see this!'**
  String get errorOccurred;

  /// Body text for song presentation error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while trying to present the song to you. Please try again later or contact support'**
  String get errorOccurredBody1;

  /// Body text for server fetch error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while trying to fetch data from the server. Please try again later or contact support'**
  String get errorOccurredBody;

  /// Title for no internet connection error
  ///
  /// In en, this message translates to:
  /// **'No internet connection!'**
  String get noConnection;

  /// Body text for connection error with support email
  ///
  /// In en, this message translates to:
  /// **'If you have reliable internet connection, then it\'s our servers that are down or unaccessible.\n\nIf this situation persists, email us: futuristicken@gmail.com with a screenshot and your device info.'**
  String get noConnectionBody;

  /// Empty state title for general sections
  ///
  /// In en, this message translates to:
  /// **'Wueh! It\'s empty here'**
  String get itsEmptyHere;

  /// Empty state title for lists section
  ///
  /// In en, this message translates to:
  /// **'Wueh! No lists here yet'**
  String get itsEmptyHere1;

  /// Empty state body for song selection
  ///
  /// In en, this message translates to:
  /// **'All caught here, do a selection of songs once again'**
  String get itsEmptyHereBody;

  /// Empty state body with suggestions for lists
  ///
  /// In en, this message translates to:
  /// **'All caught here, please like a song, search or view a song or better still add a custom list to clear this emptiness here'**
  String get itsEmptyHereBody1;

  /// Empty state body for drafts section
  ///
  /// In en, this message translates to:
  /// **'All caught here, please add draft song to clear this emptiness here'**
  String get itsEmptyHereBody2;

  /// Empty state body for favorites section
  ///
  /// In en, this message translates to:
  /// **'All caught here, please like a song to clear this emptiness here'**
  String get itsEmptyHereBody3;

  /// Empty state body with suggestion for personal lists
  ///
  /// In en, this message translates to:
  /// **'All caught here, you can add personal lists and add songs to them'**
  String get itsEmptyHereBody4;

  /// Title for keyboard shortcuts section
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get keyboardShortcuts;

  /// List of keyboard shortcuts with descriptions
  ///
  /// In en, this message translates to:
  /// **'Letter   I - Show keyboard shortcuts \nESC Key - Exit from Song Presentation \n\nDOWN Arrow - Go to Next Verse \nUP  Arrow     - Go to Previous Verse \n\nRIGHT Arrow - Go to Next Song \nLEFT Arrow - Go to Previous Song \n\nLetter C - Go to the Song Chorus \nLetter S - Go to Second Last Verse \nLetter L - Go to Last Verse \n\nNumpad 1, 2, 3, 4, 5, 6, 7 - Go to the Verse by Number'**
  String get keyboardShortcutsTexts;

  /// Title for current update highlights
  ///
  /// In en, this message translates to:
  /// **'In this Latest Update'**
  String get hintsCurrentUpdate;

  /// Text describing new features in current update
  ///
  /// In en, this message translates to:
  /// **'1. Search without worrying about commas or exclamations \n2. Search with words not following each other by using a comma in between them \n\t\tE.g \'Jesus, sin\' can be used to search the song \'Jesus paid it all\''**
  String get hintsCurrentUpdateText;

  /// Reminder text about supporting with donations
  ///
  /// In en, this message translates to:
  /// **'\n\nRemember to support our work with your donation from time to time.\nHead over to the Help Desk to Donate'**
  String get donationRequestReminder;

  /// Instruction text for book selection
  ///
  /// In en, this message translates to:
  /// **'Here are the available books, please select as many as you like to proceed'**
  String get availableBooks;

  /// Generic empty state message
  ///
  /// In en, this message translates to:
  /// **'Sorry nothing to show here at the moment.'**
  String get nothingHere;

  /// Message indicating redirection to song selection
  ///
  /// In en, this message translates to:
  /// **'Redirecting you to select songs afresh'**
  String get redirectingYou;

  /// Label for disabled state
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Label for enabled state
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Label for system default option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Option for vertical slide direction
  ///
  /// In en, this message translates to:
  /// **'Vertical (Up, Down)'**
  String get verticalSlide;

  /// Option for horizontal slide direction
  ///
  /// In en, this message translates to:
  /// **'Horizontal (Left, Right)'**
  String get horizontalSlide;

  /// Title for songbooks management section
  ///
  /// In en, this message translates to:
  /// **'Songbooks Management'**
  String get songbooksMgnt;

  /// Description for songbooks management
  ///
  /// In en, this message translates to:
  /// **'Reselect your songbooks afresh'**
  String get songbooksMgntText;

  /// Setting to keep screen awake during song presentation
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On in Song View'**
  String get screenAwake;

  /// Label for slide direction setting
  ///
  /// In en, this message translates to:
  /// **'Song Slides Direction'**
  String get slideDirection;

  /// Message showing current slide direction with parameter
  ///
  /// In en, this message translates to:
  /// **'Direction: {direction}'**
  String setDirection(String direction);

  /// Label for theme mode setting
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Message showing current theme with parameter
  ///
  /// In en, this message translates to:
  /// **'Theme: {theme}'**
  String setTheme(String theme);

  /// Label for default mode
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultMode;

  /// Label for light mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// Label for dark mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occured.'**
  String get labelError0;

  /// Error message for 404 (not found) server error
  ///
  /// In en, this message translates to:
  /// **'We\'re unable to connect you to our server at the moment.'**
  String get labelError404;

  /// Error message for 500 (server) error
  ///
  /// In en, this message translates to:
  /// **'You\'re unable to connect to our server at the moment.'**
  String get labelError500;

  /// Error message for 504 (timeout) error
  ///
  /// In en, this message translates to:
  /// **'Your request to our server has timed out.'**
  String get labelError504;

  /// Error message for invalid server response
  ///
  /// In en, this message translates to:
  /// **'Our server returned an invalid response.'**
  String get labelError999;

  /// Error message for request submission failure
  ///
  /// In en, this message translates to:
  /// **'We\'re unable to submit your request.'**
  String get labelError1000;

  /// Generic unknown error for feedback
  ///
  /// In en, this message translates to:
  /// **'An unknown error occured.'**
  String get labelFeedback0;

  /// Detailed 404 error message with support contact for feedback
  ///
  /// In en, this message translates to:
  /// **'We can\'t connect you to our server at the moment due to a technical issue on our end. Please try connecting again, if the issue persists contact us on: thesonglibapp@gmail.com'**
  String get labelFeedback404;

  /// Detailed 500 error message with troubleshooting steps for feedback
  ///
  /// In en, this message translates to:
  /// **'We can\'t connect you to our server at the moment due to a technical issue on your end. Please try switching to a reliable internet service and trying again. If the issue persists contact us on: thesonglibapp@gmail.com'**
  String get labelFeedback500;

  /// Timeout error message for feedback
  ///
  /// In en, this message translates to:
  /// **'Your request to our server has timed out.'**
  String get labelFeedback504;

  /// Invalid response error for feedback
  ///
  /// In en, this message translates to:
  /// **'Our server returned an invalid response.'**
  String get labelFeedback999;

  /// Request submission failure for feedback
  ///
  /// In en, this message translates to:
  /// **'We\'re unable to submit your request.'**
  String get labelFeedback1000;

  /// Title for permission request dialog
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get labelPermissionTitle;

  /// Explanation text for why permissions are needed
  ///
  /// In en, this message translates to:
  /// **'This app requires this permissions to function properly.'**
  String get labelPermissionText;

  /// Miscellaneous category label
  ///
  /// In en, this message translates to:
  /// **'misc'**
  String get misc;

  /// Title of the license section
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get licenseTitle;

  /// Label shown while the free trial is running
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get licenseTrialActive;

  /// Shown when one trial day remains
  ///
  /// In en, this message translates to:
  /// **'1 day left'**
  String get licenseDayLeft;

  /// Shown when several trial days remain
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String licenseDaysLeft(String days);

  /// Button that opens the purchase window
  ///
  /// In en, this message translates to:
  /// **'Buy license'**
  String get licenseBuy;

  /// Title of the purchase window
  ///
  /// In en, this message translates to:
  /// **'Unlock ChurchLib'**
  String get licenseUnlock;

  /// Heading when the trial is over
  ///
  /// In en, this message translates to:
  /// **'Your free trial has ended'**
  String get licenseTrialEndedTitle;

  /// Explains what buying a license gives
  ///
  /// In en, this message translates to:
  /// **'Unlock ChurchLib once and use it for good on this computer.'**
  String get licenseTrialEndedBody;

  /// Heading when the license was withdrawn
  ///
  /// In en, this message translates to:
  /// **'This license is no longer active'**
  String get licenseRevokedTitle;

  /// Asks the person to contact support
  ///
  /// In en, this message translates to:
  /// **'Please contact support and we will help you.'**
  String get licenseRevokedBody;

  /// Heading when the first online check could not happen
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet'**
  String get licenseConnectTitle;

  /// Explains why internet is needed once
  ///
  /// In en, this message translates to:
  /// **'ChurchLib needs to go online once to start your free trial. After that it works offline.'**
  String get licenseConnectBody;

  /// Heading when the clock looks wrong
  ///
  /// In en, this message translates to:
  /// **'Check your computer\'s date and time'**
  String get licenseClockTitle;

  /// Asks the person to fix the clock
  ///
  /// In en, this message translates to:
  /// **'The clock looks wrong. Correct it, then try again.'**
  String get licenseClockBody;

  /// Shown by builds that have no license server configured
  ///
  /// In en, this message translates to:
  /// **'The license server is not set up in this version of ChurchLib.'**
  String get licenseNotConfigured;

  /// Shown while the license is being checked
  ///
  /// In en, this message translates to:
  /// **'Checking your license…'**
  String get licenseChecking;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get licenseRetry;

  /// Price line with both currencies
  ///
  /// In en, this message translates to:
  /// **'{local} or {usd}, one time, for this computer'**
  String licensePriceLine(String local, String usd);

  /// Heading above the payment instructions
  ///
  /// In en, this message translates to:
  /// **'How to pay'**
  String get licenseHowToPay;

  /// Instruction before the payment number or email
  ///
  /// In en, this message translates to:
  /// **'Send {amount} to'**
  String licenseSendTo(String amount);

  /// Explains what happens after paying
  ///
  /// In en, this message translates to:
  /// **'Then enter the transaction code below. We approve it and ChurchLib unlocks.'**
  String get licenseAfterPaying;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Name used for payment'**
  String get licenseNameLabel;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get licensePhoneLabel;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'M-Pesa confirmation code'**
  String get licenseCodeMpesa;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'PayPal transaction ID'**
  String get licenseCodePaypal;

  /// Button that sends the payment details
  ///
  /// In en, this message translates to:
  /// **'Submit payment'**
  String get licenseSubmitPayment;

  /// Validation message for the transaction code
  ///
  /// In en, this message translates to:
  /// **'Enter the 8 to 20 letters and numbers from your message or receipt'**
  String get licenseCodeInvalid;

  /// Validation message for the name
  ///
  /// In en, this message translates to:
  /// **'Enter the name used for payment'**
  String get licenseNameInvalid;

  /// Validation message for the phone number
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number'**
  String get licensePhoneInvalid;

  /// Heading while a payment waits for approval
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get licensePaymentPendingTitle;

  /// Explains the wait for approval
  ///
  /// In en, this message translates to:
  /// **'We are checking it. This usually takes a few hours. ChurchLib unlocks by itself once it is approved.'**
  String get licensePaymentPendingBody;

  /// Button that checks the payment status
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get licenseCheckAgain;

  /// Link that reveals the license key box
  ///
  /// In en, this message translates to:
  /// **'Have a license key?'**
  String get licenseHaveKey;

  /// Label for the license key
  ///
  /// In en, this message translates to:
  /// **'License key'**
  String get licenseKeyLabel;

  /// Button that applies a license key
  ///
  /// In en, this message translates to:
  /// **'Use key'**
  String get licenseRedeem;

  /// Success message after unlocking
  ///
  /// In en, this message translates to:
  /// **'License activated. Thank you!'**
  String get licenseActivated;

  /// Label for the short computer id
  ///
  /// In en, this message translates to:
  /// **'This computer'**
  String get licenseComputerId;

  /// Copy button tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get licenseCopy;

  /// Shown after copying
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get licenseCopied;

  /// Label before the support links
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get licenseSupport;

  /// Status of a paid license
  ///
  /// In en, this message translates to:
  /// **'Licensed'**
  String get licenseStatusLicensed;

  /// Date the license was issued
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String licenseSince(String date);

  /// When the server was last asked
  ///
  /// In en, this message translates to:
  /// **'Last checked {when}'**
  String licenseLastChecked(String when);

  /// Shown before the first check
  ///
  /// In en, this message translates to:
  /// **'Not checked yet'**
  String get licenseNeverChecked;

  /// Button that asks the server now
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get licenseCheckNow;

  /// Title of the release-license action
  ///
  /// In en, this message translates to:
  /// **'Move to another computer'**
  String get licenseMoveTitle;

  /// Explains the release-license action
  ///
  /// In en, this message translates to:
  /// **'Free this license here so you can use it on a new computer.'**
  String get licenseMoveDesc;

  /// Confirmation text before releasing a license
  ///
  /// In en, this message translates to:
  /// **'This computer will go back to the free trial. Then enter your license key on the new computer.'**
  String get licenseMoveConfirm;

  /// Confirm button of the release dialog
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get licenseRelease;

  /// Sidebar banner after the trial ended
  ///
  /// In en, this message translates to:
  /// **'Free trial ended. ChurchLib will ask for a license next time you open it.'**
  String get licenseTrialEndedBanner;

  /// Shown in debug builds without a license server
  ///
  /// In en, this message translates to:
  /// **'Developer build: license checks are off.'**
  String get licenseDeveloperBuild;

  /// Hint for searching songs
  String get songSearchHint;

  /// Clear action label
  String get clearAction;

  /// Song copy confirmation
  String get songCopiedClipboard;

  /// Empty state for liked songs
  String get noLikedSongs;

  /// Song presentation verses panel setting
  String get versesPanel;

  /// Title for module settings
  String get modulesTitle;

  /// Add SongLib setting title
  String get addSonglib;

  /// SongLib setup description
  String get songlibSetupSubtitle;

  /// Add BibleLib setting title
  String get addBiblelib;

  /// BibleLib setup description
  String get biblelibSetupSubtitle;

  /// Reset data setting title
  String get resetData;

  /// Reset BibleLib action
  String get startOverBiblelib;

  /// Reset ChurchLib action
  String get resetChurchlib;

  /// Theme dialog title
  String get setThemeDialogTitle;

  /// Settings window title
  String get settingsWindowTitle;

  /// Move item up tooltip
  String get moveUp;

  /// Move item down tooltip
  String get moveDown;

  /// Multi-Bible reader setting
  String get multiBibleReader;

  /// Message shown when no primary Bible is set
  String get noPrimaryBible;

  /// Confirm removing a Bible
  String removeBibleQuestion(String bibleName);

  /// Title for choosing the primary Bible
  String get choosePrimaryBible;

  /// Close action label
  String get closeAction;

  /// Bible management help title
  String get managingBibles;

  /// Bible management help prompt
  String get bibleManagementQuestion;

  /// Decline action label
  String get noThanks;

  /// Show help action label
  String get showMe;

  /// Restart action label
  String get restartAction;

  /// Continue action label
  String get continueAction;

  /// Delete action label
  String get deleteAction;

  /// Bible management help tooltip
  String get howBibleManagementWorks;

  /// Bible management screen title
  String get manageBibles;

  /// Change selected Bible editions action
  String get changeSelection;

  /// Confirm deleting a scripture list
  String get deleteScriptureListQuestion;

  /// Scripture lists screen title
  String get scriptureListsTitle;

  /// Rename list dialog title
  String get renameList;

  /// Save action label
  String get saveAction;

  /// Play action label
  String get playAction;

  /// Confirm deleting selected items
  String get deleteSelectedQuestion;

  /// Bookmarks and notes screen title
  String get bookmarksNotesTitle;

  /// Delete selected items tooltip
  String get deleteSelectedTooltip;

  /// Clear all action label
  String get clearAll;

  /// Confirm clearing reading history
  String get clearReadingHistoryQuestion;

  /// Confirm clearing search history
  String get clearSearchHistoryQuestion;

  /// Bible history screen title
  String get historyTitle;

  /// Bible search hint
  String get searchScripturesHint;

  /// Empty search state without downloaded Bibles
  String get noDownloadedBiblesToSearch;

  /// Empty Bible search results
  String noSearchResultsForQuery(String query);

  /// Minimum Bible search query hint
  String get typeAtLeast3Letters;

  /// Bible selection search hint
  String get searchBiblesHint;

  /// Bible selection step title
  String get chooseBiblesTitle;

  /// No Bible search matches
  String get noBiblesMatch;

  /// ChurchLib setup screen title
  String get setupChurchLibTitle;

  /// Refresh action label
  String get refreshAction;

  /// Back action label
  String get backAction;

  /// Finish action label
  String get finishAction;

  /// Songbook selection step title
  String get chooseSongbooksTitle;

  /// Setup progress title
  String get gettingEverythingReady;

  /// Song download failure title
  String get unableDownloadSongs;

  /// Retry action label
  String get retryAction;

  /// SongLib module description
  String get songlibDescription;

  /// BibleLib module description
  String get biblelibDescription;

  /// Previous action label
  String get previousAction;

  /// Previous chapter tooltip
  String get previousChapterTooltip;

  /// Chapter picker button label
  String chapterNumberLabel(int chapterNumber);

  /// Chapter picker tooltip
  String get pickChapter;

  /// Next action label
  String get nextAction;

  /// Next chapter tooltip
  String get nextChapterTooltip;

  /// Quick reader options title
  String get quickOptions;

  /// Decrease reader text size action
  String get smallerText;

  /// Increase reader text size action
  String get largerText;

  /// Decrease auto-scroll speed tooltip
  String get slower;

  /// Increase auto-scroll speed tooltip
  String get faster;

  /// Switch primary Bible tooltip
  String get switchPrimaryBible;

  /// Bible book picker tooltip
  String get pickBibleBook;

  /// Scripture opener action
  String get scriptureOpener;

  /// Close scripture queue tooltip
  String get closeScriptureQueue;

  /// Previous scripture tooltip
  String get previousScripture;

  /// Next scripture tooltip
  String get nextScripture;

  /// Highlight color dialog title
  String get chooseHighlightColor;

  /// Bookmark verses dialog title
  String get bookmarkVerses;

  /// Bookmark without adding notes
  String get bookmarkOnly;

  /// Bookmark and add notes action
  String get bookmarkWithNotes;

  /// Save note tooltip
  String get saveNote;

  /// Note editor hint
  String get writeVerseThoughts;

  /// Empty Bible book picker state
  String get noBooksFound;

  /// Bible book picker search hint
  String get searchBooksHint;

  /// Reader font size label
  String fontSizeLabel(int size);

  /// Copy confirmation
  String get copyTextToClipboard;

  /// Cancel verse selection tooltip
  String get cancelVerseSelection;

  /// Bookmark or highlight tooltip
  String get bookmarkHighlight;

  /// Copy action label
  String get copyAction;

  /// Back navigation button label
  String get backButton;

  /// Available application update banner
  String versionUpdateBanner(String latest, String current);

  /// Reader message when no Bibles are downloaded
  String get noBiblesDownloaded;

  /// Reader message while Bible data downloads
  String get bibleDataUnavailable;

  /// Reader message when a book has no chapters
  String noChaptersFound(String bookName);

  /// Reader message when chapter verses are missing
  String get versesNotCached;

  /// Generic Bible reader load error
  String get readerLoadFailed;

  /// Scripture opener empty state
  String get noBooksForBible;

  /// Scripture list loading error
  String get scriptureListsFailed;

  /// Missing scripture list error
  String get scriptureListNotFound;

  /// Song search failure message
  String get songSearchFailed;

  /// Verses panel setting description
  String get showVersesPanel;

  /// Confirm resetting BibleLib
  String get startOverBiblelibQuestion;

  /// Confirm resetting BibleLib message
  String get startOverBiblelibMessage;

  /// Confirm resetting ChurchLib
  String get resetChurchlibQuestion;

  /// Confirm resetting ChurchLib message
  String get resetChurchlibMessage;

  /// BibleLib reset setting description
  String get resetBibleSubtitle;

  /// ChurchLib reset setting description
  String get resetChurchSubtitle;

  /// Settings appearance section title
  String get appearanceTitle;

  /// General settings section title
  String get generalTitle;

  /// Presentation settings navigation title
  String get presentationNavTitle;

  /// Bible settings navigation title
  String get biblesNavTitle;

  /// Update banner title
  String get updateAvailable;

  /// Song number label
  String songNumberLabel(int songNumber);

  /// Back action tooltip
  String get backEscapeTooltip;

  /// Stop action label
  String get stopAction;

  /// Done action label
  String get doneAction;

  /// Reorder action label
  String get reorderAction;

  /// Remove a Bible from secondary translations
  String get removeFromSecondary;

  /// Count label for secondary Bibles
  String secondaryBibleCount(int count);

  /// One secondary Bible label
  String get oneSecondaryBible;

  /// Hint for removing a secondary Bible
  String get hoverRemoveBible;

  /// Download failure status label
  String get downloadFailedStatus;

  /// Download progress status label
  String get fetchingVersesStatus;

  /// Stopped download status label
  String get downloadStoppedStatus;

  /// Primary Bible label
  String biblePrimaryLabel(String language);

  /// Bible language label
  String bibleLanguageLabel(String language);

  /// Instructions for managing downloaded Bible translations
  String get bibleManagementInfo;

  /// Confirmation message for deleting a Bible
  String get deleteBibleMessage;

  /// Primary Bible section label
  String get primaryBible;

  /// Primary Bible change hint
  String get clickToChange;

  /// Secondary Bible section label
  String get secondaryBiblesTitle;

  /// Other Bible section label
  String get otherBiblesTitle;

  /// Set a Bible as a secondary translation
  String get setAsSecondary;

  /// Rename action label
  String get renameAction;

  /// Reader theme setting label
  String get themeLabel;

  /// System theme option
  String get themeSystem;

  /// Decrease reader text size tooltip
  String get smallerTextTooltip;

  /// Increase reader text size tooltip
  String get largerTextTooltip;

  /// Clear search history action
  String get clearSearchHistory;

  /// Empty Bible search history state
  String get noSearchHistory;

  /// Empty Bible reading history state
  String get noReadingHistory;

  /// Hint for adding a secondary Bible
  String get hoverSetSecondary;

  /// Bible management prompt description
  String get bibleManagementPrompt;

  /// Multi-Bible reader setting description
  String get multiBibleDescription;

  /// Embedded Bible management title
  String get manageYourBibles;

  /// Reading history tab title
  String get historyReading;

  /// Search history tab title
  String get historySearches;

  /// Empty search history state
  String get noSearchesYet;

  /// Clear reading history confirmation
  String get clearReadingHistoryMessage;

  /// Clear search history confirmation
  String get clearSearchHistoryMessage;

  /// Recent Bible searches heading
  String get recentSearches;

  /// Number of Bible search results
  String searchResultCount(int count);

  /// Delete scripture list confirmation
  String get deleteListMessage;

  /// Empty scripture list state
  String get noScriptureLists;

  /// Scripture count in a saved list
  String scriptureCount(int count);

  /// Fallback scripture list title
  String get scriptureListTitle;

  /// Rename list tooltip
  String get renameTooltip;

  /// Confirm clearing all bookmarks
  String get clearAllBookmarksQuestion;

  /// Confirm clearing all notes
  String get clearAllNotesQuestion;

  /// Delete selected bookmarks or notes confirmation
  String deleteSelectedCountMessage(int count);

  /// Clear all bookmarks confirmation
  String get clearBookmarksMessage;

  /// Clear all notes confirmation
  String get clearNotesMessage;

  /// Bookmarks tab label
  String get bookmarksTab;

  /// Notes tab label
  String get notesTab;

  /// Reading tab label
  String get readingTab;

  /// Empty scripture list state
  String get noSavedScriptureLists;

  /// First setup screen heading
  String get welcomeToChurchLib;

  /// First setup screen description
  String get chooseModulesPrompt;

  /// Selection count label
  String biblesSelectedCount(int count, int max, String noun);

  /// Songbook selection noun
  String get songbooksNoun;

  /// Bible selection noun
  String get biblesNoun;

  /// Bible selection hint
  String get firstPickPrimaryBible;

  /// Songbook selection maximum message
  String songbookSelectionLimit(int count);

  /// Continue navigation button label
  String get continueUpper;

  /// Finish navigation button label
  String get finishUpper;

  /// Setup progress detail
  String get almostThere;

  /// Download progress message
  String percentDownloaded(int percent);

  /// Song save progress title
  String get savingYourSongs;

  /// Song download progress title
  String get fetchingYourSongs;

  /// Song download progress message
  String get momentOnly;

  /// Primary Bible download progress title
  String get downloadingPrimaryBible;

  /// Bible progress label
  String get bibleWord;

  /// Secondary Bible download progress message
  String get otherBiblesBackground;

  /// Start auto-scroll button label
  String get autoScrollAction;

  /// Stop auto-scroll button label
  String get stopScrollAction;

  /// Start auto-scroll tooltip
  String get startAutoScroll;

  /// Stop auto-scroll tooltip
  String get stopAutoScroll;

  /// Old Testament tab label
  String get oldTestament;

  /// New Testament tab label
  String get newTestament;

  /// Multi-Bible reader enabled description
  String get showOtherBibles;

  /// Multi-Bible reader disabled description
  String get downloadBibleToUse;

  /// Add note action label
  String get addNoteAction;

  /// Add note selection hint
  String get selectSingleVerseNote;

  /// Selected item count
  String selectedCount(int count);

  /// Setup modules description
  String get firstSetupMessage;

  /// Bookmark options dialog prompt
  String get bookmarkOptionsPrompt;

  /// How it works sheet title
  String howModuleWorks(String moduleName);

  /// Switch application module tooltip
  String switchToModule(String moduleName);

  /// SongLib guide section title
  String get songHowFindTitle;

  /// SongLib guide for finding songs
  String get songHowFindBody;

  /// SongLib guide section title
  String get songHowReadTitle;

  /// SongLib guide for reading songs
  String get songHowReadBody;

  /// SongLib guide section title
  String get songHowPresentTitle;

  /// SongLib guide for presenting songs
  String get songHowPresentBody;

  /// SongLib guide section title
  String get songHowKeysTitle;

  /// SongLib presenter keyboard shortcuts
  String get songHowKeysBody;

  /// SongLib guide section title
  String get songHowQuickTitle;

  /// SongLib guide for quick actions
  String get songHowQuickBody;

  /// SongLib guide section title
  String get songHowLikesTitle;

  /// SongLib guide for liked songs
  String get songHowLikesBody;

  /// SongLib guide section title
  String get songHowBooksTitle;

  /// SongLib guide for songbook storage and updates
  String get songHowBooksBody;

  /// BibleLib guide section title
  String get bibleHowReadingTitle;

  /// BibleLib guide for reading
  String get bibleHowReadingBody;

  /// BibleLib guide section title
  String get bibleHowTextTitle;

  /// BibleLib guide for text size and auto scroll
  String get bibleHowTextBody;

  /// BibleLib guide section title
  String get bibleHowParallelTitle;

  /// BibleLib guide for parallel translations
  String get bibleHowParallelBody;

  /// BibleLib guide section title
  String get bibleHowSelectTitle;

  /// BibleLib guide for selecting verses
  String get bibleHowSelectBody;

  /// BibleLib guide section title
  String get bibleHowSearchTitle;

  /// BibleLib guide for Bible search
  String get bibleHowSearchBody;

  /// BibleLib guide section title
  String get bibleHowHistoryTitle;

  /// BibleLib guide for history
  String get bibleHowHistoryBody;

  /// BibleLib guide section title
  String get bibleHowBookmarksTitle;

  /// BibleLib guide for bookmarks and notes
  String get bibleHowBookmarksBody;

  /// BibleLib guide section title
  String get bibleHowOpenerTitle;

  /// BibleLib guide for Scripture Opener
  String get bibleHowOpenerBody;

  /// BibleLib guide section title
  String get bibleHowListsTitle;

  /// BibleLib guide for saved scripture lists
  String get bibleHowListsBody;

  /// BibleLib guide section title
  String get bibleHowManageTitle;

  /// BibleLib guide for Bible management
  String get bibleHowManageBody;

  /// Justified presentation text alignment label
  String get alignmentJustified;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
