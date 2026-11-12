/// Removes whitespace and normalizes a license value to uppercase.
String normalizeLicenseInput(String value) =>
    value.replaceAll(RegExp(r'\s'), '').toUpperCase();
