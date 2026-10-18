// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../common/utils/formatting/app_util.dart';
import '../../../common/widgets/app_intents.dart';
import '../../../common/widgets/list_items/search_book_item.dart';
import '../../../common/widgets/list_items/search_song_item.dart';
import '../../../core/theme/theme_styles.dart';
import '../../../data/models/song/songbook.dart';
import '../../../data/models/song/songext.dart';
import '../../home/main/shell/app_module.dart';
import '../../home/main/shell/module_focus.dart';
import '../../presentation/presentation_controller.dart';
import '../../home/song_search/bloc/song_search_bloc.dart';
import '../../home/song_search/ui/song_search_screen.dart';

part 'widgets/song_viewer.dart';
part 'widgets/list_widgets.dart';

class SongsScreen extends StatefulWidget {
  final HomeScreenState parent;

  const SongsScreen({super.key, required this.parent});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  late SongSearchBloc bloc;
  late HomeScreenState parent;

  @override
  void initState() {
    super.initState();
    parent = widget.parent;
    bloc = context.read<SongSearchBloc>();
  }

  Future<void> onSongSelect(SongExt song, bool shouldOpen) async {
    parent.selectSong(song);
    if (shouldOpen) parent.presentSelected();
  }

  Future<void> onSongOpen() => parent.presentSelected();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) {
        final outline = Theme.of(context).colorScheme.outlineVariant;
        var bigScreenView = ListenableBuilder(
          listenable: PresentationController.instance,
          builder: (context, _) => Row(
          children: [
            Column(
              children: [
                BooksList(
                  books: parent.books,
                  selectedBook: parent.selectedBook,
                ),
                SongsList(
                  selectedSong: parent.selectedSong,
                  songs: parent.filtered,
                  onTap: onSongSelect,
                  isBigScreen: true,
                ).expanded(),
              ],
            )
                .decorated(
                  border: Border(right: BorderSide(color: outline)),
                )
                .expanded(),
            if (!PresentationController.instance.active)
              SongViewer(song: parent.selectedSong).expanded(),
          ],
          ),
        );
        return Shortcuts(
          shortcuts: <ShortcutActivator, Intent>{
            CharacterActivator('s'): SearchIntent(),
            SingleActivator(LogicalKeyboardKey.enter): OpenIntent(),
            SingleActivator(LogicalKeyboardKey.escape): CloseIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              SearchIntent: CallbackAction<SearchIntent>(
                onInvoke: (intent) => parent.searchFocus.requestFocus(),
              ),
              OpenIntent: CallbackAction<OpenIntent>(
                onInvoke: (intent) => onSongOpen(),
              ),
            },
            child: ModuleFocus(
              module: AppModule.songlib,
              onKeyEvent: (node, event) {
                logger('Key pressed: ${event.logicalKey.keyLabel}');
                return KeyEventResult.ignored;
              },
              child: bigScreenView,
            ),
          ),
        );
      },
    );
  }
}
