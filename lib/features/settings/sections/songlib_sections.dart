// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../common/constants/pref_constants.dart';
import '../../../core/di/injectable.dart';
import '../../../domain/repos/pref_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../settings_card.dart';

class PresentationSection extends StatefulWidget {
  const PresentationSection({super.key});

  @override
  State<PresentationSection> createState() => _PresentationSectionState();
}

class _PresentationSectionState extends State<PresentationSection> {
  final _prefRepo = getIt<PrefRepo>();
  late bool _slideVertical, _showVerses;

  @override
  void initState() {
    super.initState();
    _slideVertical = _prefRepo.getPrefBool(PrefConstants.slideVerticalKey);
    _showVerses = _prefRepo.getPrefBool(PrefConstants.presenterVersesKey);
  }

  void _update(bool value) {
    _prefRepo.setPrefBool(PrefConstants.slideVerticalKey, value);
    setState(() => _slideVertical = value);
  }

  void _updateVerses(bool value) {
    _prefRepo.setPrefBool(PrefConstants.presenterVersesKey, value);
    setState(() => _showVerses = value);
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
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Verses panel'),
          subtitle: const Text(
            'Show every verse of the song beside the slides while presenting',
          ),
          trailing: Switch(value: _showVerses, onChanged: _updateVerses),
          onTap: () => _updateVerses(!_showVerses),
        ),
      ],
    );
  }
}
