// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keys that make text smaller: - (also on the numpad).
final List<ShortcutActivator> smallerFontKeys = [
  const SingleActivator(LogicalKeyboardKey.minus),
  const SingleActivator(LogicalKeyboardKey.numpadSubtract),
];

/// Keys that make text bigger: = (and + / numpad +, so no Shift is needed).
final List<ShortcutActivator> biggerFontKeys = [
  const SingleActivator(LogicalKeyboardKey.equal),
  const SingleActivator(LogicalKeyboardKey.numpadAdd),
  const CharacterActivator('+'),
];

class SlideNumberIntent extends Intent {
  final int slideNumber;
  const SlideNumberIntent(this.slideNumber);
}

class SlideLetterIntent extends Intent {
  final String letter;
  const SlideLetterIntent(this.letter);
}

class CloseIntent extends Intent {
  const CloseIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class PreviousIntent extends Intent {
  const PreviousIntent();
}

class NextSongIntent extends Intent {
  const NextSongIntent();
}

class PreviousSongIntent extends Intent {
  const PreviousSongIntent();
}

class BiggerFontIntent extends Intent {
  const BiggerFontIntent();
}

class SmallerFontIntent extends Intent {
  const SmallerFontIntent();
}

class InfoIntent extends Intent {
  const InfoIntent();
}

class  SearchIntent extends Intent {
  const SearchIntent();
}

class  OpenIntent extends Intent {
  const OpenIntent();
}
