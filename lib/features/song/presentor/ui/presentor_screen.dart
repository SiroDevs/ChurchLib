// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widget/styled_widget.dart';

// Project imports:
import '../../../../common/constants/pref_constants.dart';
import '../../../../common/utils/display/app_window.dart';
import '../../../../common/utils/formatting/app_util.dart';
import '../../../../common/widgets/action/fab_widget.dart';
import '../../../../common/widgets/action/full_screen_button.dart';
import '../../../../common/widgets/app_intents.dart';
import '../../../../common/widgets/presentor/presentation_scaffold.dart';
import '../../../../common/widgets/presentor/slide_container.dart';
import '../../../../common/widgets/state/custom_snackbar.dart';
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/models.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/presentor_bloc.dart';
import '../utils/presentor_shortcuts.dart';
import '../utils/presentor_utils.dart';
import '../utils/slide_utils.dart';

part 'widgets/fab_widget.dart';
part 'widgets/verses_panel.dart';
part 'presentor_details.dart';
part 'widgets/presentor_slide.dart';

class PresentorScreen extends StatefulWidget {
  final SongExt song;
  final SongBook book;
  final List<SongExt> songs;

  const PresentorScreen({
    super.key,
    required this.song,
    required this.book,
    required this.songs,
  });

  @override
  State<PresentorScreen> createState() => PresentorScreenState();
}

class PresentorScreenState extends State<PresentorScreen> {
  late AppLocalizations l10n;
  late SongExt song;
  late String songTitle, songBook;
  bool hasChorus = false, likeChanged = false, slideVertical = true;
  late bool showVerses;
  final activeSlide = ValueNotifier<int>(0);
  final detailsKey = GlobalKey<PresentorDetailsState>();
  late final List<SongExt> bookSongs;

  @override
  void initState() {
    super.initState();
    showVerses = getIt<PrefRepo>().getPrefBool(
      PrefConstants.presenterVersesKey,
    );
    // Presenting fills the screen; leaving full screen (F11) leaves the
    // presenter, the way Esc and the back button do.
    AppWindow.fullScreen.addListener(_onFullScreenChanged);
    AppWindow.setFullScreen(true);
    song = widget.song;
    hasChorus = song.content.contains("CHORUS");
    songTitle = songItemTitle(song.songNo, widget.song.title);
    songBook = refineTitle(song.songbook);
    bookSongs = _songsOfBook();
  }

  List<SongExt> _songsOfBook() {
    final list = widget.songs.where((s) => s.book == widget.song.book).toList()
      ..sort((a, b) => a.songNo.compareTo(b.songNo));
    return list.any((s) => s.rid == widget.song.rid) ? list : [widget.song];
  }

  void changeSong(int step, PresentorBloc bloc) {
    final index = bookSongs.indexWhere((s) => s.rid == song.rid);
    final target = index + step;
    if (index < 0 || target < 0 || target >= bookSongs.length) return;
    final next = bookSongs[target];
    setState(() {
      song = next;
      hasChorus = next.content.contains("CHORUS");
      songTitle = songItemTitle(next.songNo, next.title);
      songBook = refineTitle(next.songbook);
    });
    detailsKey.currentState?.resetForSong();
    bloc.add(LoadSong(next));
  }

  @override
  void dispose() {
    AppWindow.fullScreen.removeListener(_onFullScreenChanged);
    activeSlide.dispose();
    AppWindow.setFullScreen(false);
    super.dispose();
  }

  void _onFullScreenChanged() {
    if (!AppWindow.fullScreen.value && mounted) {
      Navigator.of(context).pop(likeChanged);
    }
  }

  void _toggleVerses() {
    setState(() => showVerses = !showVerses);
    // Remembered, so the panel stays the way the user left it.
    getIt<PrefRepo>().setPrefBool(PrefConstants.presenterVersesKey, showVerses);
    // The button takes keyboard focus; give it back so the arrow keys, - and
    // = keep working on the slides.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => detailsKey.currentState?.focusNode.requestFocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => PresentorBloc()..add(LoadSong(widget.song)),
      child: BlocConsumer<PresentorBloc, PresentorState>(
        listener: (context, state) {
          if (state is PresentorFailureState) {
            CustomSnackbar.show(context, feedbackMessage(state.feedback, l10n));
          } else if (state is PresentorLikedState) {
            setState(() {
              song.liked = !song.liked;
              likeChanged = true;
            });
            if (state.liked) {
              CustomSnackbar.show(context, l10n.songLiked, isSuccess: true);
            } else {
              CustomSnackbar.show(context, l10n.songDisliked);
            }
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) {
                return;
              }
              if (context.mounted) {
                Navigator.of(context).pop(likeChanged);
              }
            },
            child: PresentationScaffold(
              title: songTitle,
              subtitle: songBook,
              onBack: () => Navigator.of(context).pop(likeChanged),
              actions: [
                IconButton(
                  tooltip: showVerses ? 'Hide verses' : 'Show verses',
                  isSelected: showVerses,
                  onPressed: _toggleVerses,
                  icon: const Icon(Icons.list),
                ),
                const FullScreenButton(),
              ],
              body: PresentorDetails(key: detailsKey, parent: this),
              endPanel: showVerses
                  ? PresentorVersesPanel(
                      key: ValueKey(song.rid),
                      song: song,
                      hasChorus: hasChorus,
                      activeSlide: activeSlide,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
