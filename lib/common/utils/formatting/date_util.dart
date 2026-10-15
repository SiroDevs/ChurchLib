// Dart imports:
import 'dart:core';

// Package imports:
import 'package:intl/intl.dart';

String dateNow() {
  return DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
}

String getIso8601Date() {
  final now = DateTime.now().toUtc();
  return '${now.toIso8601String()}Z';
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(now.toUtc());
}

String getCurrentDayDate({String separator = '-', bool reverse = false}) {
  if (reverse) {
    return DateFormat('yyyy${separator}MM${separator}dd')
        .format(DateTime.now());
  } else {
    return DateFormat('dd${separator}MM${separator}yyyy')
        .format(DateTime.now());
  }
}

String formatDateOutput(DateTime datevalue, {bool outputDob = false}) {
  if (outputDob) {
    String formattedDate =
        "${datevalue.year}${datevalue.month.toString().padLeft(2, '0')}${datevalue.day.toString().padLeft(2, '0')}";
    return '${formattedDate}000000';
  } else {
    String formattedDate =
        "${datevalue.day.toString().padLeft(2, '0')}/${datevalue.month.toString().padLeft(2, '0')}/${datevalue.year}";
    return formattedDate;
  }
}

String filesDateTimeStamp() {
  return DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
}

int timeStamp() {
  return DateTime.timestamp().millisecondsSinceEpoch;
}

String dateToString(DateTime dateValue) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateValue);
}

String dateFormatter(String date) {
  String day = date.substring(6, 8);
  String month = date.substring(4, 6);
  String year = date.substring(0, 4);
  switch (month) {
    case 'O1':
      month = 'Jan';
    case 'O2':
      month = 'Feb';
    case '03':
      month = 'Mar';
    case '04':
      month = 'Apr';
    case '05':
      month = 'May';
    case '06':
      month = 'Jun';
    case '07':
      month = 'Jul';
    case '08':
      month = 'Aug';
    case '09':
      month = 'Sep';
    case '10':
      month = 'Oct';
    case '11':
      month = 'Nov';
    case '12':
      month = 'Dec';
    default:
      month = DateFormat('MMM').format(DateTime.now());
  }
  return '$day-$month-$year';
}

