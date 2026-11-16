# ChurchLib

ChurchLib is a Flutter desktop app that brings [SongLib](https://sirodevs.com/songlib) and [BibleLib](https://sirodevs.com/biblelib) together for church services. It runs on Windows, macOS, and Linux and keeps downloaded songbooks and Bible translations available offline.

## What it does

- **SongLib:** browse and search songs by title, number, alias, or lyrics; manage selected songbooks and liked songs; copy, share, and present lyrics.
- **BibleLib:** read downloaded translations, search scripture, compare parallel translations, and manage bookmarks, highlights, notes, reading history, and scripture lists.
- **Presentation:** present songs or Bible passages on an extended audience display, or use full-screen mode when audience mode is disabled, the display is mirrored, or no extended display is available.
- **Local storage:** keeps downloaded content and reader data on the device so the main library features work offline after setup.
- **Localization:** English and Swahili, with English as the default language.

## Screenshots

| SongLib | BibleLib |
|:--:|:--:|
| ![SongLib screen](screenshots/image1.png) | ![BibleLib screen](screenshots/image2.png) |

## Main packages

Runtime dependencies are declared in [`pubspec.yaml`](pubspec.yaml). These are the main packages and their roles:

| Area | Packages | Role in ChurchLib |
|---|---|---|
| App framework | `flutter`, `flutter_localizations`, `intl` | Desktop UI, localized strings, and date/number formatting. |
| State and routing | `flutter_bloc`, `equatable`, `freezed_annotation`, `go_router` | Feature state, value equality, generated state types, and navigation. |
| Dependency injection | `get_it`, `injectable` | Register and retrieve app services and repositories. |
| Local data | `froom`, `sqflite`, `shared_preferences`, `path`, `path_provider`, `json_annotation` | SQLite models and queries, user preferences, local paths, and JSON model definitions. |
| Network | `http`, `connectivity_plus` | Fetch song and Bible data, check connectivity, and handle update or license requests. |
| Desktop integration | `multiview_desktop`, `device_info_plus`, `flutter_platform_alert` | Multi-window audience display, device details, and native platform alerts. |
| Interface | `styled_widget`, `card_swiper`, `skeleton_loader`, `percent_indicator`, `textstyle_extensions`, `dartx` | Widget composition, swipeable content, loading states, progress indicators, and text/layout helpers. |
| Licensing and updates | `crypto`, `cryptography`, `package_info_plus`, `url_launcher`, `timeago` | Device identifiers, license verification, app version checks, links, and relative dates. |
| Export and sharing | `pdf`, `share_plus` | Create PDF output and share song content. |

Development dependencies include `build_runner`, `froom_generator`, `json_serializable`, `freezed`, and `injectable_generator` for generated code; `flutter_lints` for static analysis; `flutter_test` for tests; and `import_sorter` for import organization.

Some packages declared in `pubspec.yaml` currently have no direct import under `lib/` or `test/`: `context_menus`, `cupertino_icons`, `flutter_svg`, `nativeapi_flutter`, `permission_handler`, `rxdart`, `sizer`, and `wakelock_plus`. They may support platform or future integrations; check their usage before removing them.

## Development setup

Requirements: Flutter with Dart SDK `3.13.5` or newer in the `3.x` range, plus the desktop build tools for your operating system.

```bash
git clone git@github.com:SiroDevs/ChurchLib.git
cd ChurchLib
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Run the production configuration:

```bash
flutter run -t lib/main.dart
```

Run the staging configuration:

```bash
flutter run -t lib/main_stg.dart
```

Run the project tests with:

```bash
flutter test
```

## Build

Build the production desktop app for your platform:

```bash
flutter build windows -t lib/main.dart --no-tree-shake-icons
flutter build macos -t lib/main.dart --no-tree-shake-icons
flutter build linux -t lib/main.dart --no-tree-shake-icons
```

Only run the build command for the platform you are targeting. Linux packages can be produced with [`flutter_distributor`](https://pub.dev/packages/flutter_distributor) when it is installed.
