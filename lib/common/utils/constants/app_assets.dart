class AppAssets {
  AppAssets._();

  static const assetsImages = 'assets/images';
  static const assetsIcons = 'assets/icons';

  static const String iconApp = '$assetsIcons/app_icon.png';
  static const String iconProject = '$assetsIcons/project.png';
  static const String iconSonglib = '$assetsIcons/songlib.png';
  static const String iconBiblelib = '$assetsIcons/biblelib.png';
  static const String imgCar = '$assetsIcons/car.png';
  static const String imgCase = '$assetsIcons/case.png';
  static const String imgTractor = '$assetsIcons/tructor.png';
  static const String noImage = '$assetsImages/no-photo.png';
  static const String imgMessage = '$assetsIcons/messages.png';
  static const String imgProfile = '$assetsIcons/profile.png';
  static const String imgZeroState = '$assetsImages/empty.png';
  static const String imgConstruction = '$assetsImages/construction.png';
  static const String imgHeaderFooter = '$assetsImages/header_footer.png';

  static const String imgBg = '$assetsImages/bg.jpg';
  static const String imgBgBw = '$assetsImages/bgBW.jpg';

  /// Splash backgrounds. One is picked at random on every launch (never the
  /// same one twice in a row) — see `SplashScreen`. Drop a new image into
  /// `assets/images` and add it here to include it in the rotation.
  static const List<String> splashBackgrounds = [
    '$assetsImages/bridge.jpg',
    '$assetsImages/eagle.jpg',
    '$assetsImages/field.jpg',
    '$assetsImages/flowers.jpg',
    '$assetsImages/green.jpg',
    '$assetsImages/quite-time.jpg',
    '$assetsImages/river.jpg',
    '$assetsImages/road.jpg',
    '$assetsImages/tower.jpg',
    '$assetsImages/vogr.jpg',
    '$assetsImages/water.jpg',
    '$assetsImages/wayside.jpg',
    '$assetsImages/wheat.jpg',
    '$assetsImages/woods.jpg',
  ];
}
