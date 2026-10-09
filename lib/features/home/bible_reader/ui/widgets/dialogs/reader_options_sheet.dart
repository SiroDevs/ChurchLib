// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../../../common/utils/reader_utils.dart';
import '../../../../../../core/di/injectable.dart';
import '../../../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../../../domain/repos/pref_repo.dart';
import '../../../cubit/bible_reader_cubit.dart';

Future<void> showReaderOptionsSheet(BuildContext context) {
  final cubit = context.read<BibleReaderCubit>();
  final themeBloc = context.read<ThemeBloc>();
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: AnimationStyle.noAnimation,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: themeBloc),
      ],
      child: const _OptionsContent(),
    ),
  );
}

class _OptionsContent extends StatefulWidget {
  const _OptionsContent();

  @override
  State<_OptionsContent> createState() => _OptionsContentState();
}

class _OptionsContentState extends State<_OptionsContent> {
  late ThemeMode _mode = getIt<PrefRepo>().getThemeMode();

  void _setTheme(ThemeMode mode) {
    getIt<PrefRepo>().updateThemeMode(mode);
    context.read<ThemeBloc>().add(ThemeModeChanged(mode));
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final label = text.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return SafeArea(
      child: BlocBuilder<BibleReaderCubit, BibleReaderState>(
        builder: (context, state) {
          final cubit = context.read<BibleReaderCubit>();
          final bibles = state.savedBibles.where((b) => b.isDownloaded).length;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Options', style: text.titleLarge),
                const SizedBox(height: 18),
                Text('Theme', style: label),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto, size: 18),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode, size: 18),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode, size: 18),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => _setTheme(s.first),
                ),
                const SizedBox(height: 22),
                Text('Font size: ${state.fontSize}', style: label),
                Row(
                  children: [
                    const Text('Aa', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: state.fontSize
                            .clamp(readerMinFontSize, readerMaxFontSize)
                            .toDouble(),
                        min: readerMinFontSize.toDouble(),
                        max: readerMaxFontSize.toDouble(),
                        divisions: (readerMaxFontSize - readerMinFontSize) ~/ 2,
                        label: '${state.fontSize}',
                        onChanged: (v) => cubit.setFontSize(v.round()),
                      ),
                    ),
                    const Text('Aa', style: TextStyle(fontSize: 26)),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Multi-Bible reader'),
                  subtitle: Text(
                    bibles > 1
                        ? 'Show your other Bibles under each verse'
                        : 'Download another Bible to use this',
                  ),
                  value: state.multiBibleReaderEnabled,
                  onChanged: bibles > 1
                      ? (v) => cubit.setMultiBibleReaderEnabled(v)
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
