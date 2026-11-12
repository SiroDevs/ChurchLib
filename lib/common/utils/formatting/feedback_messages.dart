// Project imports:
import '../../../l10n/gen/app_localizations.dart';

/// Converts a service error code to its localized message.
String feedbackMessage(String code, AppLocalizations l10n) => switch (code) {
  '0' => l10n.labelError0,
  '404' => l10n.labelError404,
  '500' => l10n.labelError500,
  '504' => l10n.labelError504,
  '999' => l10n.labelError999,
  '1000' => l10n.labelError1000,
  _ => code,
};
