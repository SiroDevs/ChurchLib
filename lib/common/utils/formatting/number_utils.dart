/// Returns whether a string can be parsed as a number.
bool isNumeric(String value) => double.tryParse(value) != null;
