// Project imports:
import 'app_module.dart';
import '../../../../l10n/gen/app_localizations.dart';

class HowItWorksEntry {
  const HowItWorksEntry(this.title, this.body);

  final String title;
  final String body;
}

List<HowItWorksEntry> howItWorksFor(AppModule module, AppLocalizations l10n) =>
    switch (module) {
      AppModule.songlib => [
        HowItWorksEntry(l10n.songHowFindTitle, l10n.songHowFindBody),
        HowItWorksEntry(l10n.songHowReadTitle, l10n.songHowReadBody),
        HowItWorksEntry(l10n.songHowPresentTitle, l10n.songHowPresentBody),
        HowItWorksEntry(l10n.songHowKeysTitle, l10n.songHowKeysBody),
        HowItWorksEntry(l10n.songHowQuickTitle, l10n.songHowQuickBody),
        HowItWorksEntry(l10n.songHowLikesTitle, l10n.songHowLikesBody),
        HowItWorksEntry(l10n.songHowBooksTitle, l10n.songHowBooksBody),
      ],
      AppModule.biblelib => [
        HowItWorksEntry(l10n.bibleHowReadingTitle, l10n.bibleHowReadingBody),
        HowItWorksEntry(l10n.bibleHowTextTitle, l10n.bibleHowTextBody),
        HowItWorksEntry(l10n.bibleHowParallelTitle, l10n.bibleHowParallelBody),
        HowItWorksEntry(l10n.bibleHowSelectTitle, l10n.bibleHowSelectBody),
        HowItWorksEntry(l10n.bibleHowSearchTitle, l10n.bibleHowSearchBody),
        HowItWorksEntry(l10n.bibleHowHistoryTitle, l10n.bibleHowHistoryBody),
        HowItWorksEntry(
          l10n.bibleHowBookmarksTitle,
          l10n.bibleHowBookmarksBody,
        ),
        HowItWorksEntry(l10n.bibleHowOpenerTitle, l10n.bibleHowOpenerBody),
        HowItWorksEntry(l10n.bibleHowListsTitle, l10n.bibleHowListsBody),
        HowItWorksEntry(l10n.bibleHowManageTitle, l10n.bibleHowManageBody),
      ],
    };
