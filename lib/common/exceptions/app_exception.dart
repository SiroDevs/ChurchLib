class AppException implements Exception {
  AppException([
    this.message = "",
    this.debugString = "",
  ]);

  final String message;

  final String debugString;

  @override
  String toString() {
    return "$message $debugString";
  }
}
