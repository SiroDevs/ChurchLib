# Welcome to ChurchLib - Desktop

ChurchLib combines both [SongLib](https://sirodevs.com/songlib) and [BibleLib](https://sirodevs.com/biblelib) into one super app for your desktop: Windows, Linux, MacOS

## Overview

ChurchLib combines SongLib and BibleLib into one desktop app for church use: a songbook/hymns library and a multi-translation Bible reader, sharing one local database and one setup flow. This Flutter-based application is designed so you don't have to worry about being online once you've set up the app on your device.

## Screenshots

<table>
    <tr>
        <td>
            <image src="./screenshots/image1.png"/>
        </td>
        <td>
            <image src="./screenshots/image2.png"/>
        </td>
    </tr>
    <tr>
        <td>
            SongLib on the App
        </td>
        <td>
            BibleLib on the App
        </td>
    </tr>
</table>

## Getting Started

Follow this guide to set up and run ChurchLib:

### Setting Up ChurchLib:

1. **Install Flutter and Dependencies:** Ensure Flutter is installed on your system. Download the Flutter SDK from the official website and set up your preferred IDE (e.g., Android Studio or Visual Studio Code) with the Flutter plugin.

2. **Clone the Repository:** Clone the ChurchLib repository from GitHub using Git:

   ```bash
   git clone git@github.com:SiroDevs/ChurchLib.git
   ```

3. **Install Packages:** Navigate to the project directory and run:

   ```bash
   flutter pub get
   ```

### Running ChurchLib:

1. **Device Setup:** Connect an emulator or physical device to your development environment. Check connected devices:

   ```bash
   flutter devices
   ```

2. **Update Dependencies:**

   ```bash
   flutter pub get
   ```

3. **Update Code Generated Files:**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Update Localization Strings:**

   ```bash
   flutter gen-l10n
   ```

5. **Running ChurchLib:**
   ```bash
   flutter run --flavor develop -t lib/main_dev.dart --no-tree-shake-icons
   ```

### Building ChurchLib

1. **Windows:**

   ```
   flutter build windows --target=lib/main.dart --no-tree-shake-icons
   ```

2. **MacOS:**

   ```
   flutter build macos -t lib/main.dart --no-tree-shake-icons
   ```

   Install create-dmg

   ```
   brew install create-dmg
   ```

   Generate DMG

   ```
   create-dmg \
   --volname "ChurchLib" \
   --window-pos 200 120 \
   --window-size 800 400 \
   --icon-size 100 \
   --icon "ChurchLib.app" 200 190 \
   --hide-extension "ChurchLib.app" \
   --app-drop-link 600 185 \
   "dist/macos/churchlib_1.0.0.dmg" \
   "build/macos/Build/Products/Release/ChurchLib.app"
   ```

3. **Linux:**

   Generate the build

   ```
   flutter build linux -t lib/main.dart --no-tree-shake-icons
   ```

   Create a deb package

   ```
   flutter_distributor package --platform linux --targets deb
   ```

   Or an rpm package

   ```
   flutter_distributor package --platform linux --targets rpm
   ```

Congratulations! You've successfully set up and run or built ChurchLib. Explore the codebase, make modifications, and contribute to creating a seamless experience for the users. Happy coding!
