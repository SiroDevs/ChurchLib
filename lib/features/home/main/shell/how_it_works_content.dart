// Project imports:
import 'app_module.dart';

class HowItWorksEntry {
  const HowItWorksEntry(this.title, this.body);

  final String title;
  final String body;
}

List<HowItWorksEntry> howItWorksFor(AppModule module) => switch (module) {
      AppModule.songlib => _songlib,
      AppModule.biblelib => _biblelib,
    };

const _songlib = [
  HowItWorksEntry(
    'Finding a song',
    'Type in the search box at the top to find a song by its number, title '
        'or any words from its lyrics. Press S anywhere to jump to the box. '
        'The chips above the list narrow the songs down to one songbook.',
  ),
  HowItWorksEntry(
    'Reading a song',
    'Pick a song in the list and its verses appear on the right, with the '
        'song title and songbook shown at the top of the window.',
  ),
  HowItWorksEntry(
    'Presenting',
    'Double-click a song, press Enter, or choose Present song from Quick '
        'Options to open it in the presenter. Step through the verses one '
        'slide at a time; the slide direction can be changed in Settings.',
  ),
  HowItWorksEntry(
    'Quick Options',
    'The Quick Options button at the bottom right collects what you can do '
        'with the selected song: copy its words, like it or present it.',
  ),
  HowItWorksEntry(
    'Likes',
    'Songs you like are gathered under Likes in the sidebar so you can open '
        'your favourites quickly.',
  ),
  HowItWorksEntry(
    'Songbooks and updates',
    'Your songbooks are stored on this device and refreshed in the '
        'background when you are online. To choose different songbooks, open '
        'Settings and use Songbooks.',
  ),
];

const _biblelib = [
  HowItWorksEntry(
    'Reading',
    'Use the Bible button at the top to switch translation and the chapter '
        'button to jump to another chapter. Previous and Next at the bottom '
        'move chapter by chapter, or press Alt with the left or right arrow.',
  ),
  HowItWorksEntry(
    'Text size and auto scroll',
    'Aa- and Aa+ in the title bar change the text size. Auto scroll at the '
        'bottom left scrolls the chapter for you; use the plus and minus '
        'beside it to set the speed, and touch the text to stop.',
  ),
  HowItWorksEntry(
    'Parallel Bibles',
    'Download more than one Bible and turn on the Multi-Bible reader in '
        'Quick Options to show your other translations under each verse.',
  ),
  HowItWorksEntry(
    'Selecting verses',
    'Click verses to select them. The bar at the top then lets you bookmark '
        'or highlight them, add a note to a single verse, or copy them. '
        'Press Esc to cancel the selection.',
  ),
  HowItWorksEntry(
    'Search',
    'Search looks through every verse of the Bible you choose and takes you '
        'straight to the result. Earlier searches are kept for next time.',
  ),
  HowItWorksEntry(
    'History',
    'History lists the chapters you read and the searches you made, so you '
        'can pick up where you stopped.',
  ),
  HowItWorksEntry(
    'Bookmarks and Notes',
    'Everything you bookmark or write a note on is collected under '
        'Bookmarks and Notes in the sidebar, across all your Bibles.',
  ),
  HowItWorksEntry(
    'Scripture Opener',
    'Scripture Opener in the title bar opens a passage by typing its book, '
        'chapter and verse. Add several passages to a queue and open them '
        'one after another.',
  ),
  HowItWorksEntry(
    'Scripture lists',
    'Scriptures in the sidebar keeps lists of passages you reuse, such as a '
        'sermon outline. Press Play on a list to step through its verses '
        'with the queue bar at the bottom.',
  ),
  HowItWorksEntry(
    'Managing Bibles',
    'Add, remove or choose your main translation from Settings and Bibles, '
        'or from Choose Bible in the title bar.',
  ),
];
