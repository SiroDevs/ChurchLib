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
  ///
  /// In en, this message translates to:
  /// **'Search a song by title or words'**
  String get songSearchHint;

  /// Clear action label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// Song copy confirmation
  ///
  /// In en, this message translates to:
  /// **'Song copied to clipboard'**
  String get songCopiedClipboard;

  /// Empty state for liked songs
  ///
  /// In en, this message translates to:
  /// **'You have not liked a song yet.'**
  String get noLikedSongs;

  /// Song presentation verses panel setting
  ///
  /// In en, this message translates to:
  /// **'Verses panel'**
  String get versesPanel;

  /// Title for module settings
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modulesTitle;

  /// Add SongLib setting title
  ///
  /// In en, this message translates to:
  /// **'Add SongLib'**
  String get addSonglib;

  /// SongLib setup description
  ///
  /// In en, this message translates to:
  /// **'Set up your church songbook'**
  String get songlibSetupSubtitle;

  /// Add BibleLib setting title
  ///
  /// In en, this message translates to:
  /// **'Add BibleLib'**
  String get addBiblelib;

  /// BibleLib setup description
  ///
  /// In en, this message translates to:
  /// **'Set up a Bible translation'**
  String get biblelibSetupSubtitle;

  /// Reset data setting title
  ///
  /// In en, this message translates to:
  /// **'Reset data'**
  String get resetData;

  /// Reset BibleLib action
  ///
  /// In en, this message translates to:
  /// **'Start over with BibleLib'**
  String get startOverBiblelib;

  /// Reset ChurchLib action
  ///
  /// In en, this message translates to:
  /// **'Reset ChurchLib'**
  String get resetChurchlib;

  /// Theme dialog title
  ///
  /// In en, this message translates to:
  /// **'Set the Theme'**
  String get setThemeDialogTitle;

  /// Settings window title
  ///
  /// In en, this message translates to:
  /// **'ChurchLib Settings'**
  String get settingsWindowTitle;

  /// Move item up tooltip
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// Move item down tooltip
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// Multi-Bible reader setting
  ///
  /// In en, this message translates to:
  /// **'Multi-Bible reader'**
  String get multiBibleReader;

  /// Message shown when no primary Bible is set
  ///
  /// In en, this message translates to:
  /// **'No primary Bible set yet.'**
  String get noPrimaryBible;

  /// Confirm removing a Bible
  ///
  /// In en, this message translates to:
  /// **'Remove {bibleName}?'**
  String removeBibleQuestion(String bibleName);

  /// Title for choosing the primary Bible
  ///
  /// In en, this message translates to:
  /// **'Choose primary Bible'**
  String get choosePrimaryBible;

  /// Close action label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// Bible management help title
  ///
  /// In en, this message translates to:
  /// **'Managing your Bibles'**
  String get managingBibles;

  /// Bible management help prompt
  ///
  /// In en, this message translates to:
  /// **'Would you like to know how to manage your Bibles?'**
  String get bibleManagementQuestion;

  /// Decline action label
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get noThanks;

  /// Show help action label
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get showMe;

  /// Restart action label
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartAction;

  /// Continue action label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// Bible management help tooltip
  ///
  /// In en, this message translates to:
  /// **'How Bible management works'**
  String get howBibleManagementWorks;

  /// Bible management screen title
  ///
  /// In en, this message translates to:
  /// **'Manage Bibles'**
  String get manageBibles;

  /// Change selected Bible editions action
  ///
  /// In en, this message translates to:
  /// **'Change Selection'**
  String get changeSelection;

  /// Confirm deleting a scripture list
  ///
  /// In en, this message translates to:
  /// **'Delete this list?'**
  String get deleteScriptureListQuestion;

  /// Scripture lists screen title
  ///
  /// In en, this message translates to:
  /// **'Scripture Lists'**
  String get scriptureListsTitle;

  /// Rename list dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename list'**
  String get renameList;

  /// Save action label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// Play action label
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playAction;

  /// Confirm deleting selected items
  ///
  /// In en, this message translates to:
  /// **'Delete selected?'**
  String get deleteSelectedQuestion;

  /// Bookmarks and notes screen title
  ///
  /// In en, this message translates to:
  /// **'Bookmarks & Notes'**
  String get bookmarksNotesTitle;

  /// Delete selected items tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get deleteSelectedTooltip;

  /// Clear all action label
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Confirm clearing reading history
  ///
  /// In en, this message translates to:
  /// **'Clear reading history?'**
  String get clearReadingHistoryQuestion;

  /// Confirm clearing search history
  ///
  /// In en, this message translates to:
  /// **'Clear search history?'**
  String get clearSearchHistoryQuestion;

  /// Bible history screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// Bible search hint
  ///
  /// In en, this message translates to:
  /// **'Search scriptures ...'**
  String get searchScripturesHint;

  /// Empty search state without downloaded Bibles
  ///
  /// In en, this message translates to:
  /// **'No downloaded Bibles to search yet.'**
  String get noDownloadedBiblesToSearch;

  /// Empty Bible search results
  ///
  /// In en, this message translates to:
  /// **'No results for {query}'**
  String noSearchResultsForQuery(String query);

  /// Minimum Bible search query hint
  ///
  /// In en, this message translates to:
  /// **'Type at least 3 letters to search.'**
  String get typeAtLeast3Letters;

  /// Bible selection search hint
  ///
  /// In en, this message translates to:
  /// **'Search name, abbreviation or language'**
  String get searchBiblesHint;

  /// Bible selection step title
  ///
  /// In en, this message translates to:
  /// **'Choose your Bibles'**
  String get chooseBiblesTitle;

  /// No Bible search matches
  ///
  /// In en, this message translates to:
  /// **'No Bibles match your search'**
  String get noBiblesMatch;

  /// ChurchLib setup screen title
  ///
  /// In en, this message translates to:
  /// **'Set up ChurchLib'**
  String get setupChurchLibTitle;

  /// Refresh action label
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// Back action label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// Finish action label
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishAction;

  /// Songbook selection step title
  ///
  /// In en, this message translates to:
  /// **'Choose your Songbooks'**
  String get chooseSongbooksTitle;

  /// Setup progress title
  ///
  /// In en, this message translates to:
  /// **'Getting everything ready…'**
  String get gettingEverythingReady;

  /// Song download failure title
  ///
  /// In en, this message translates to:
  /// **'Unable to download songs'**
  String get unableDownloadSongs;

  /// Retry action label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// SongLib module description
  ///
  /// In en, this message translates to:
  /// **'Church songbook & hymns, offline'**
  String get songlibDescription;

  /// BibleLib module description
  ///
  /// In en, this message translates to:
  /// **'Multi-translation Bible reader'**
  String get biblelibDescription;

  /// Previous action label
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousAction;

  /// Previous chapter tooltip
  ///
  /// In en, this message translates to:
  /// **'Previous chapter (Alt + ←)'**
  String get previousChapterTooltip;

  /// Chapter picker button label
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapterNumber}'**
  String chapterNumberLabel(int chapterNumber);

  /// Chapter picker tooltip
  ///
  /// In en, this message translates to:
  /// **'Pick chapter'**
  String get pickChapter;

  /// Next action label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextAction;

  /// Next chapter tooltip
  ///
  /// In en, this message translates to:
  /// **'Next chapter (Alt + →)'**
  String get nextChapterTooltip;

  /// Quick reader options title
  ///
  /// In en, this message translates to:
  /// **'Quick Options'**
  String get quickOptions;

  /// Decrease reader text size action
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get smallerText;

  /// Increase reader text size action
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get largerText;

  /// Decrease auto-scroll speed tooltip
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get slower;

  /// Increase auto-scroll speed tooltip
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get faster;

  /// Switch primary Bible tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch Your Primary Bible'**
  String get switchPrimaryBible;

  /// Bible book picker tooltip
  ///
  /// In en, this message translates to:
  /// **'Pick a Bible Book'**
  String get pickBibleBook;

  /// Scripture opener action
  ///
  /// In en, this message translates to:
  /// **'Scripture Opener'**
  String get scriptureOpener;

  /// Close scripture queue tooltip
  ///
  /// In en, this message translates to:
  /// **'Close Scripture Queue'**
  String get closeScriptureQueue;

  /// Previous scripture tooltip
  ///
  /// In en, this message translates to:
  /// **'Previous Scripture'**
  String get previousScripture;

  /// Next scripture tooltip
  ///
  /// In en, this message translates to:
  /// **'Next Scripture'**
  String get nextScripture;

  /// Highlight color dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose a highlight color'**
  String get chooseHighlightColor;

  /// Bookmark verses dialog title
  ///
  /// In en, this message translates to:
  /// **'Bookmark verses'**
  String get bookmarkVerses;

  /// Bookmark without adding notes
  ///
  /// In en, this message translates to:
  /// **'Bookmark only'**
  String get bookmarkOnly;

  /// Bookmark and add notes action
  ///
  /// In en, this message translates to:
  /// **'Bookmark with notes'**
  String get bookmarkWithNotes;

  /// Save note tooltip
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get saveNote;

  /// Note editor hint
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts on this verse...'**
  String get writeVerseThoughts;

  /// Empty Bible book picker state
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get noBooksFound;

  /// Bible book picker search hint
  ///
  /// In en, this message translates to:
  /// **'Search books...'**
  String get searchBooksHint;

  /// Reader font size label
  ///
  /// In en, this message translates to:
  /// **'Font size: {size}'**
  String fontSizeLabel(int size);

  /// Copy confirmation
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copyTextToClipboard;

  /// Cancel verse selection tooltip
  ///
  /// In en, this message translates to:
  /// **'Cancel selection (Esc)'**
  String get cancelVerseSelection;

  /// Bookmark or highlight tooltip
  ///
  /// In en, this message translates to:
  /// **'Bookmark / highlight'**
  String get bookmarkHighlight;

  /// Copy action label
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// Back navigation button label
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get backButton;

  /// Available application update banner
  ///
  /// In en, this message translates to:
  /// **'Version {latest} is out (you have {current}).'**
  String versionUpdateBanner(String latest, String current);

  /// Reader message when no Bibles are downloaded
  ///
  /// In en, this message translates to:
  /// **'No Bibles downloaded yet.'**
  String get noBiblesDownloaded;

  /// Reader message while Bible data downloads
  ///
  /// In en, this message translates to:
  /// **'Bible data is not available. Wait for the download to complete.'**
  String get bibleDataUnavailable;

  /// Reader message when a book has no chapters
  ///
  /// In en, this message translates to:
  /// **'No chapters found for {bookName}'**
  String noChaptersFound(String bookName);

  /// Reader message when chapter verses are missing
  ///
  /// In en, this message translates to:
  /// **'Verses are not cached. Make sure the download is complete.'**
  String get versesNotCached;

  /// Generic Bible reader load error
  ///
  /// In en, this message translates to:
  /// **'Unable to load this Bible content. Please try again.'**
  String get readerLoadFailed;

  /// Scripture opener empty state
  ///
  /// In en, this message translates to:
  /// **'No books found for this Bible.'**
  String get noBooksForBible;

  /// Scripture list loading error
  ///
  /// In en, this message translates to:
  /// **'Failed to load scripture lists.'**
  String get scriptureListsFailed;

  /// Missing scripture list error
  ///
  /// In en, this message translates to:
  /// **'This scripture list could not be found.'**
  String get scriptureListNotFound;

  /// Song search failure message
  ///
  /// In en, this message translates to:
  /// **'Unable to display songs'**
  String get songSearchFailed;

  /// Verses panel setting description
  ///
  /// In en, this message translates to:
  /// **'Show every verse of the song beside the slides while presenting'**
  String get showVersesPanel;

  /// Confirm resetting BibleLib
  ///
  /// In en, this message translates to:
  /// **'Start over with BibleLib?'**
  String get startOverBiblelibQuestion;

  /// Confirm resetting BibleLib message
  ///
  /// In en, this message translates to:
  /// **'This deletes every downloaded Bible, bookmark and note. This can\'t be undone.'**
  String get startOverBiblelibMessage;

  /// Confirm resetting ChurchLib
  ///
  /// In en, this message translates to:
  /// **'Reset ChurchLib?'**
  String get resetChurchlibQuestion;

  /// Confirm resetting ChurchLib message
  ///
  /// In en, this message translates to:
  /// **'This erases everything — songbooks, Bibles, bookmarks, notes and settings — and takes you back to setup. This can\'t be undone.'**
  String get resetChurchlibMessage;

  /// BibleLib reset setting description
  ///
  /// In en, this message translates to:
  /// **'Delete all downloaded Bibles and choose translations again'**
  String get resetBibleSubtitle;

  /// ChurchLib reset setting description
  ///
  /// In en, this message translates to:
  /// **'Erase everything — songbooks, Bibles, bookmarks — and start over'**
  String get resetChurchSubtitle;

  /// Settings appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// General settings section title
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalTitle;

  /// Presentation settings navigation title
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get presentationNavTitle;

  /// Bible settings navigation title
  ///
  /// In en, this message translates to:
  /// **'Bibles'**
  String get biblesNavTitle;

  /// Update banner title
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// Song number label
  ///
  /// In en, this message translates to:
  /// **'Song #{songNumber}'**
  String songNumberLabel(int songNumber);

  /// Back action tooltip
  ///
  /// In en, this message translates to:
  /// **'Back (Esc)'**
  String get backEscapeTooltip;

  /// Stop action label
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAction;

  /// Done action label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// Reorder action label
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderAction;

  /// Remove a Bible from secondary translations
  ///
  /// In en, this message translates to:
  /// **'Remove from secondary'**
  String get removeFromSecondary;

  /// Count label for secondary Bibles
  ///
  /// In en, this message translates to:
  /// **'{count} secondary Bibles'**
  String secondaryBibleCount(int count);

  /// One secondary Bible label
  ///
  /// In en, this message translates to:
  /// **'1 secondary Bible'**
  String get oneSecondaryBible;

  /// Hint for removing a secondary Bible
  ///
  /// In en, this message translates to:
  /// **'Hover a Bible to remove it'**
  String get hoverRemoveBible;

  /// Download failure status label
  ///
  /// In en, this message translates to:
  /// **' · Download failed'**
  String get downloadFailedStatus;

  /// Download progress status label
  ///
  /// In en, this message translates to:
  /// **' · Fetching verses'**
  String get fetchingVersesStatus;

  /// Stopped download status label
  ///
  /// In en, this message translates to:
  /// **' · Download stopped'**
  String get downloadStoppedStatus;

  /// Primary Bible label
  ///
  /// In en, this message translates to:
  /// **'{language} BIBLE • PRIMARY'**
  String biblePrimaryLabel(String language);

  /// Bible language label
  ///
  /// In en, this message translates to:
  /// **'{language} BIBLE'**
  String bibleLanguageLabel(String language);

  /// Instructions for managing downloaded Bible translations
  ///
  /// In en, this message translates to:
  /// **'You can add a Bible to the Multi-Bible Reader by hovering over it in \"Other Bibles\" and choosing \"Set as secondary\". Hover over it again and choose \"Remove from secondary\" to take it out.\n\nTo delete a Bible from your device, hover over it, choose \"Delete\" and confirm.\n\nTo add or remove translations from your library, choose \"Change Selection\" below.'**
  String get bibleManagementInfo;

  /// Confirmation message for deleting a Bible
  ///
  /// In en, this message translates to:
  /// **'This deletes all downloaded content for this Bible from your device. This can\'t be undone.'**
  String get deleteBibleMessage;

  /// Primary Bible section label
  ///
  /// In en, this message translates to:
  /// **'Primary Bible'**
  String get primaryBible;

  /// Primary Bible change hint
  ///
  /// In en, this message translates to:
  /// **'Click to change'**
  String get clickToChange;

  /// Secondary Bible section label
  ///
  /// In en, this message translates to:
  /// **'Secondary Bibles'**
  String get secondaryBiblesTitle;

  /// Other Bible section label
  ///
  /// In en, this message translates to:
  /// **'Other Bibles'**
  String get otherBiblesTitle;

  /// Set a Bible as a secondary translation
  ///
  /// In en, this message translates to:
  /// **'Set as secondary'**
  String get setAsSecondary;

  /// Rename action label
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameAction;

  /// Reader theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Decrease reader text size tooltip
  ///
  /// In en, this message translates to:
  /// **'Smaller text (-)'**
  String get smallerTextTooltip;

  /// Increase reader text size tooltip
  ///
  /// In en, this message translates to:
  /// **'Larger text (=)'**
  String get largerTextTooltip;

  /// Clear search history action
  ///
  /// In en, this message translates to:
  /// **'Clear search history'**
  String get clearSearchHistory;

  /// Empty Bible search history state
  ///
  /// In en, this message translates to:
  /// **'No search history yet.'**
  String get noSearchHistory;

  /// Empty Bible reading history state
  ///
  /// In en, this message translates to:
  /// **'No reading history yet.'**
  String get noReadingHistory;

  /// Hint for adding a secondary Bible
  ///
  /// In en, this message translates to:
  /// **'Hover a Bible to set it as secondary'**
  String get hoverSetSecondary;

  /// Bible management prompt description
  ///
  /// In en, this message translates to:
  /// **'Learn how to add or remove Bibles from the Multi-Bible Reader, and how to add translations to your library.'**
  String get bibleManagementPrompt;

  /// Multi-Bible reader setting description
  ///
  /// In en, this message translates to:
  /// **'Read parallel translations alongside your primary text'**
  String get multiBibleDescription;

  /// Embedded Bible management title
  ///
  /// In en, this message translates to:
  /// **'Manage Your Bibles'**
  String get manageYourBibles;

  /// Reading history tab title
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get historyReading;

  /// Search history tab title
  ///
  /// In en, this message translates to:
  /// **'Searches'**
  String get historySearches;

  /// Empty search history state
  ///
  /// In en, this message translates to:
  /// **'No searches yet.'**
  String get noSearchesYet;

  /// Clear reading history confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your reading history. This can\'t be undone.'**
  String get clearReadingHistoryMessage;

  /// Clear search history confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your search history. This can\'t be undone.'**
  String get clearSearchHistoryMessage;

  /// Recent Bible searches heading
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// Number of Bible search results
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String searchResultCount(int count);

  /// Delete scripture list confirmation
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteListMessage;

  /// Empty scripture list state
  ///
  /// In en, this message translates to:
  /// **'No saved scripture lists yet.\nBuild one in Scripture Opener.'**
  String get noScriptureLists;

  /// Scripture count in a saved list
  ///
  /// In en, this message translates to:
  /// **'{count} scriptures'**
  String scriptureCount(int count);

  /// Fallback scripture list title
  ///
  /// In en, this message translates to:
  /// **'Scripture list'**
  String get scriptureListTitle;

  /// Rename list tooltip
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameTooltip;

  /// Confirm clearing all bookmarks
  ///
  /// In en, this message translates to:
  /// **'Clear all bookmarks?'**
  String get clearAllBookmarksQuestion;

  /// Confirm clearing all notes
  ///
  /// In en, this message translates to:
  /// **'Clear all notes?'**
  String get clearAllNotesQuestion;

  /// Delete selected bookmarks or notes confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {count} selected items. This can\'t be undone.'**
  String deleteSelectedCountMessage(int count);

  /// Clear all bookmarks confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your bookmarks across every Bible. This can\'t be undone.'**
  String get clearBookmarksMessage;

  /// Clear all notes confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your notes across every Bible. This can\'t be undone.'**
  String get clearNotesMessage;

  /// Bookmarks tab label
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTab;

  /// Notes tab label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTab;

  /// Reading tab label
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get readingTab;

  /// Empty scripture list state
  ///
  /// In en, this message translates to:
  /// **'No saved scripture lists yet.\nBuild one in Scripture Opener.'**
  String get noSavedScriptureLists;

  /// First setup screen heading
  ///
  /// In en, this message translates to:
  /// **'Welcome to ChurchLib'**
  String get welcomeToChurchLib;

  /// First setup screen description
  ///
  /// In en, this message translates to:
  /// **'Choose what you\'d like set up. You can always add the other one later from Settings.'**
  String get chooseModulesPrompt;

  /// Selection count label
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} {noun} selected'**
  String biblesSelectedCount(int count, int max, String noun);

  /// Songbook selection noun
  ///
  /// In en, this message translates to:
  /// **'songbooks'**
  String get songbooksNoun;

  /// Bible selection noun
  ///
  /// In en, this message translates to:
  /// **'Bibles'**
  String get biblesNoun;

  /// Bible selection hint
  ///
  /// In en, this message translates to:
  /// **'Your first pick is the primary Bible'**
  String get firstPickPrimaryBible;

  /// Songbook selection maximum message
  ///
  /// In en, this message translates to:
  /// **'You can select up to {count} songbooks'**
  String songbookSelectionLimit(int count);

  /// Continue navigation button label
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueUpper;

  /// Finish navigation button label
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finishUpper;

  /// Setup progress detail
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get almostThere;

  /// Download progress message
  ///
  /// In en, this message translates to:
  /// **'{percent}% downloaded'**
  String percentDownloaded(int percent);

  /// Song save progress title
  ///
  /// In en, this message translates to:
  /// **'Saving your songs'**
  String get savingYourSongs;

  /// Song download progress title
  ///
  /// In en, this message translates to:
  /// **'Fetching your songs…'**
  String get fetchingYourSongs;

  /// Song download progress message
  ///
  /// In en, this message translates to:
  /// **'This only takes a moment'**
  String get momentOnly;

  /// Primary Bible download progress title
  ///
  /// In en, this message translates to:
  /// **'Downloading your primary Bible'**
  String get downloadingPrimaryBible;

  /// Bible progress label
  ///
  /// In en, this message translates to:
  /// **'Bible'**
  String get bibleWord;

  /// Secondary Bible download progress message
  ///
  /// In en, this message translates to:
  /// **'Your other Bibles will download in the background.'**
  String get otherBiblesBackground;

  /// Start auto-scroll button label
  ///
  /// In en, this message translates to:
  /// **'Auto scroll'**
  String get autoScrollAction;

  /// Stop auto-scroll button label
  ///
  /// In en, this message translates to:
  /// **'Stop scroll'**
  String get stopScrollAction;

  /// Start auto-scroll tooltip
  ///
  /// In en, this message translates to:
  /// **'Start auto scroll'**
  String get startAutoScroll;

  /// Stop auto-scroll tooltip
  ///
  /// In en, this message translates to:
  /// **'Stop auto scroll'**
  String get stopAutoScroll;

  /// Old Testament tab label
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get oldTestament;

  /// New Testament tab label
  ///
  /// In en, this message translates to:
  /// **'New Testament'**
  String get newTestament;

  /// Multi-Bible reader enabled description
  ///
  /// In en, this message translates to:
  /// **'Show your other Bibles under each verse'**
  String get showOtherBibles;

  /// Multi-Bible reader disabled description
  ///
  /// In en, this message translates to:
  /// **'Download another Bible to use this'**
  String get downloadBibleToUse;

  /// Add note action label
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNoteAction;

  /// Add note selection hint
  ///
  /// In en, this message translates to:
  /// **'Select a single verse to add a note'**
  String get selectSingleVerseNote;

  /// Selected item count
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// Setup modules description
  ///
  /// In en, this message translates to:
  /// **'Choose what you would like to set up. You can add the other module later from Settings.'**
  String get firstSetupMessage;

  /// Bookmark options dialog prompt
  ///
  /// In en, this message translates to:
  /// **'Would you like to bookmark these verses only, or add a note as well?'**
  String get bookmarkOptionsPrompt;

  /// How it works sheet title
  ///
  /// In en, this message translates to:
  /// **'How {moduleName} works'**
  String howModuleWorks(String moduleName);

  /// Switch application module tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to {moduleName}'**
  String switchToModule(String moduleName);

  /// SongLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Finding a song'**
  String get songHowFindTitle;

  /// SongLib guide for finding songs
  ///
  /// In en, this message translates to:
  /// **'Type in the search box at the top to find a song by its number, title or any words from its lyrics. Press S anywhere to jump to the box. The chips above the list narrow the songs down to one songbook.'**
  String get songHowFindBody;

  /// SongLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Reading a song'**
  String get songHowReadTitle;

  /// SongLib guide for reading songs
  ///
  /// In en, this message translates to:
  /// **'Pick a song in the list and its verses appear on the right, with the song title and songbook shown at the top of the window.'**
  String get songHowReadBody;

  /// SongLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Presenting'**
  String get songHowPresentTitle;

  /// SongLib guide for presenting songs
  ///
  /// In en, this message translates to:
  /// **'Double-click a song, press Enter, or choose Present song from Quick Options to open it in the presenter. Step through the verses one slide at a time; change slide direction in Settings. Words are sized to fit the screen. The list button in the presenter title bar shows every verse in a sidebar, with the current verse highlighted. The sidebar starts open; press the button again to hide it.'**
  String get songHowPresentBody;

  /// SongLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Presenter keys'**
  String get songHowKeysTitle;

  /// SongLib presenter keyboard shortcuts
  ///
  /// In en, this message translates to:
  /// **'Right or Down arrow: next slide.\nLeft or Up arrow: previous slide.\n1 to 7: jump to that verse.\nC: jump to the chorus.\nL: jump to the last slide.\n- : make the text smaller.\n= : make the text bigger, as far as the longest verse still fits.\nEsc: close the presenter.'**
  String get songHowKeysBody;

  /// SongLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Quick Options'**
  String get songHowQuickTitle;

  /// SongLib guide for quick actions
  ///
  /// In en, this message translates to:
  /// **'The Quick Options button at the bottom right collects what you can do with the selected song: copy its words, like it or present it.'**
  String get songHowQuickBody;

  /// SongLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get songHowLikesTitle;

  /// SongLib guide for liked songs
  ///
  /// In en, this message translates to:
  /// **'Songs you like are gathered under Likes in the sidebar so you can open your favourites quickly.'**
  String get songHowLikesBody;

  /// SongLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Songbooks and updates'**
  String get songHowBooksTitle;

  /// SongLib guide for songbook storage and updates
  ///
  /// In en, this message translates to:
  /// **'Your songbooks are stored on this device and refreshed in the background when you are online. To choose different songbooks, open Settings and use Songbooks.'**
  String get songHowBooksBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get bibleHowReadingTitle;

  /// BibleLib guide for reading
  ///
  /// In en, this message translates to:
  /// **'Use the Bible button at the top to switch translation and the chapter button to jump to another chapter. Previous and Next at the bottom move chapter by chapter, or press Alt with the left or right arrow. The Up and Down arrow keys scroll the chapter. These keys only work while BibleLib is the open app.'**
  String get bibleHowReadingBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Text size and auto scroll'**
  String get bibleHowTextTitle;

  /// BibleLib guide for text size and auto scroll
  ///
  /// In en, this message translates to:
  /// **'Aa- and Aa+ in the title bar change the text size, or press - on your keyboard to make it smaller and = to make it bigger. Auto scroll at the bottom left scrolls the chapter for you; use the plus and minus beside it to set the speed, and touch the text to stop.'**
  String get bibleHowTextBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Parallel Bibles'**
  String get bibleHowParallelTitle;

  /// BibleLib guide for parallel translations
  ///
  /// In en, this message translates to:
  /// **'Download more than one Bible and turn on the Multi-Bible reader in Quick Options to show your other translations under each verse.'**
  String get bibleHowParallelBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Selecting verses'**
  String get bibleHowSelectTitle;

  /// BibleLib guide for selecting verses
  ///
  /// In en, this message translates to:
  /// **'Click verses to select them. The bar at the top then lets you bookmark or highlight them, add a note to a single verse, or copy them. Press Esc to cancel the selection.'**
  String get bibleHowSelectBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get bibleHowSearchTitle;

  /// BibleLib guide for Bible search
  ///
  /// In en, this message translates to:
  /// **'Search looks through every verse of the Bible you choose and takes you straight to the result. Earlier searches are kept for next time.'**
  String get bibleHowSearchBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get bibleHowHistoryTitle;

  /// BibleLib guide for history
  ///
  /// In en, this message translates to:
  /// **'History lists the chapters you read and the searches you made, so you can pick up where you stopped.'**
  String get bibleHowHistoryBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Bookmarks and Notes'**
  String get bibleHowBookmarksTitle;

  /// BibleLib guide for bookmarks and notes
  ///
  /// In en, this message translates to:
  /// **'Everything you bookmark or write a note on is collected under Bookmarks and Notes in the sidebar, across all your Bibles.'**
  String get bibleHowBookmarksBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Scripture Opener'**
  String get bibleHowOpenerTitle;

  /// BibleLib guide for Scripture Opener
  ///
  /// In en, this message translates to:
  /// **'Scripture Opener in the title bar opens a passage by typing its book, chapter and verse. Add several passages to a queue and open them one after another.'**
  String get bibleHowOpenerBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Scripture lists'**
  String get bibleHowListsTitle;

  /// BibleLib guide for saved scripture lists
  ///
  /// In en, this message translates to:
  /// **'Scriptures in the sidebar keeps lists of passages you reuse, such as a sermon outline. Press Play on a list to step through its verses with the queue bar at the bottom.'**
  String get bibleHowListsBody;

  /// BibleLib guide section title
  ///
  /// In en, this message translates to:
  /// **'Managing Bibles'**
  String get bibleHowManageTitle;

  /// BibleLib guide for Bible management
  ///
  /// In en, this message translates to:
  /// **'Add, remove or choose your main translation from Settings and Bibles, or from Choose Bible in the title bar.'**
  String get bibleHowManageBody;

  /// Justified presentation text alignment label
  ///
  /// In en, this message translates to:
  /// **'Justified'**
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
