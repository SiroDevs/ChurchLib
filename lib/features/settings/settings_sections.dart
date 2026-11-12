// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../home/main/shell/app_module.dart';
import '../../l10n/gen/app_localizations.dart';
import '../license/ui/widgets/license_section.dart';
import 'sections/appearance_section.dart';
import 'sections/biblelib_sections.dart';
import 'sections/general_section.dart';
import 'sections/songlib_sections.dart';

class SettingsNode {
  const SettingsNode.group(this.id, this.label, this.icon, this.children)
    : builder = null,
      scrolls = true;

  const SettingsNode.leaf(
    this.id,
    this.label,
    this.icon,
    WidgetBuilder this.builder, {
    this.scrolls = true,
  }) : children = const [];

  final String id;
  final String label;
  final IconData icon;
  final WidgetBuilder? builder;
  final bool scrolls;
  final List<SettingsNode> children;

  bool get isGroup => builder == null;
}

List<SettingsNode> settingsTree({
  required bool songlibEnabled,
  required bool biblelibEnabled,
  required AppLocalizations l10n,
}) => [
  SettingsNode.leaf(
    'appearance',
    l10n.appearanceTitle,
    Icons.color_lens_outlined,
    (_) => const AppearanceSection(),
  ),
  SettingsNode.leaf(
    'license',
    l10n.licenseTitle,
    Icons.verified_outlined,
    (_) => const LicenseSection(),
  ),
  if (songlibEnabled)
    SettingsNode.group(
      AppModule.songlib.name,
      AppModule.songlib.label,
      Icons.library_music_outlined,
      [
        SettingsNode.leaf(
          'songlib/presentation',
          l10n.presentationNavTitle,
          Icons.slideshow,
          (_) => const PresentationSection(),
        ),
      ],
    ),
  if (biblelibEnabled)
    SettingsNode.group(
      AppModule.biblelib.name,
      AppModule.biblelib.label,
      Icons.menu_book_outlined,
      [
        SettingsNode.leaf(
          'biblelib/bibles',
          l10n.biblesNavTitle,
          Icons.menu_book_outlined,
          (_) => const BiblesSection(),
          scrolls: false,
        ),
      ],
    ),
  SettingsNode.leaf(
    'general',
    l10n.generalTitle,
    Icons.church_outlined,
    (_) => const GeneralSection(),
  ),
];

Iterable<SettingsNode> settingsLeaves(List<SettingsNode> tree) sync* {
  for (final node in tree) {
    if (node.isGroup) {
      yield* settingsLeaves(node.children);
    } else {
      yield node;
    }
  }
}
