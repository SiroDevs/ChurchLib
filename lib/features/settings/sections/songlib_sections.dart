// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../common/utils/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../settings_actions.dart';
import '../settings_card.dart';

class SongbooksSection extends StatelessWidget {
  const SongbooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingCard(
      title: l10n.collectionTitle,
      widgets: [
        ListTile(
          leading: const Icon(Icons.library_books),
          title: Text(l10n.reselectSongbooks),
          subtitle: Text(l10n.reselectSongbooksDesc),
          onTap: SettingsActions(context).resetSongLib,
        ),
      ],
    );
  }
}

class PresentationSection extends StatefulWidget {
  const PresentationSection({super.key});

  @override
  State<PresentationSection> createState() => _PresentationSectionState();
}

class _PresentationSectionState extends State<PresentationSection> {
  final _prefRepo = getIt<PrefRepo>();
  late bool _slideVertical;

  @override
  void initState() {
    super.initState();
    _slideVertical = _prefRepo.getPrefBool(PrefConstants.slideVerticalKey);
  }

  void _update(bool value) {
    _prefRepo.setPrefBool(PrefConstants.slideVerticalKey, value);
    setState(() => _slideVertical = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingCard(
      title: l10n.presentationTitle,
      widgets: [
        ListTile(
          leading: const Icon(Icons.slideshow),
          title: Text(l10n.songPresentation),
          subtitle: Text(l10n.songPresentationDesc),
          trailing: Switch(value: _slideVertical, onChanged: _update),
          onTap: () => _update(!_slideVertical),
        ),
      ],
    );
  }
}
