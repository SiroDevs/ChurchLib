// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../home/main/shell/app_module.dart';
import 'sections/appearance_section.dart';
import 'sections/biblelib_sections.dart';
import 'sections/general_section.dart';
import 'sections/songlib_sections.dart';

class SettingsSection {
  const SettingsSection(
    this.label,
    this.icon,
    this.builder, {
    this.scrolls = true,
  });

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
  final bool scrolls;
}

List<SettingsSection> settingsSectionsFor(AppModule module) => [
      SettingsSection(
        'Appearance',
        Icons.color_lens_outlined,
        (_) => const AppearanceSection(),
      ),
      ...switch (module) {
        AppModule.songlib => [
            SettingsSection(
              'Songbooks',
              Icons.library_books_outlined,
              (_) => const SongbooksSection(),
            ),
            SettingsSection(
              'Presentation',
              Icons.slideshow,
              (_) => const PresentationSection(),
            ),
          ],
        AppModule.biblelib => [
            SettingsSection(
              'Bibles',
              Icons.menu_book_outlined,
              (_) => const BiblesSection(),
              scrolls: false,
            ),
            SettingsSection(
              'BibleLib data',
              Icons.restart_alt,
              (_) => const BibleDataSection(),
            ),
          ],
      },
      SettingsSection(
        'ChurchLib',
        Icons.church_outlined,
        (_) => const GeneralSection(),
      ),
    ];
