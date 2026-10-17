// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../common/widgets/app_intents.dart';

/// Keyboard shortcuts of the song presenter.
///
/// Esc closes, up / down move between slides, left / right move to the
/// previous / next song in the songbook, 1-7 jump to a verse, C / L jump to
/// the chorus / last slide, - and = make the text smaller / bigger.
final Map<ShortcutActivator, Intent> presentorShortcuts =
    <ShortcutActivator, Intent>{
  const SingleActivator(LogicalKeyboardKey.escape): const CloseIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowUp): const PreviousIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowLeft): const PreviousSongIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowDown): const NextIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowRight): const NextSongIntent(),
  for (final key in smallerFontKeys) key: const SmallerFontIntent(),
  for (final key in biggerFontKeys) key: const BiggerFontIntent(),
  const SingleActivator(LogicalKeyboardKey.digit1): const SlideNumberIntent(1),
  const SingleActivator(LogicalKeyboardKey.digit2): const SlideNumberIntent(2),
  const SingleActivator(LogicalKeyboardKey.digit3): const SlideNumberIntent(3),
  const SingleActivator(LogicalKeyboardKey.digit4): const SlideNumberIntent(4),
  const SingleActivator(LogicalKeyboardKey.digit5): const SlideNumberIntent(5),
  const SingleActivator(LogicalKeyboardKey.digit6): const SlideNumberIntent(6),
  const SingleActivator(LogicalKeyboardKey.digit7): const SlideNumberIntent(7),
  const SingleActivator(LogicalKeyboardKey.numpad1): const SlideNumberIntent(1),
  const SingleActivator(LogicalKeyboardKey.numpad2): const SlideNumberIntent(2),
  const SingleActivator(LogicalKeyboardKey.numpad3): const SlideNumberIntent(3),
  const SingleActivator(LogicalKeyboardKey.numpad4): const SlideNumberIntent(4),
  const SingleActivator(LogicalKeyboardKey.numpad5): const SlideNumberIntent(5),
  const SingleActivator(LogicalKeyboardKey.numpad6): const SlideNumberIntent(6),
  const SingleActivator(LogicalKeyboardKey.numpad7): const SlideNumberIntent(7),
  const CharacterActivator('c'): const SlideLetterIntent('C'),
  const CharacterActivator('l'): const SlideLetterIntent('L'),
};
