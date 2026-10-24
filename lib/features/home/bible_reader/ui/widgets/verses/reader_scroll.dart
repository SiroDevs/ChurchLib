// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../cubit/bible_reader_cubit.dart';
import 'reader_auto_scroll.dart';

/// Scrolling the chapter by verse or by arrow key, and reporting which verse
/// is at the top so the reading position can be restored.
mixin ReaderScrollMixin<T extends StatefulWidget>
    on State<T>, ReaderAutoScrollMixin<T> {
  final viewportKey = GlobalKey();
  final verseKeys = <String, GlobalKey>{};
  Timer? _reportTimer;

  void disposeScrollReport() => _reportTimer?.cancel();

  GlobalKey keyFor(String verseId) =>
      verseKeys.putIfAbsent(verseId, () => GlobalKey());

  void scrollToVerse(String verseId, {bool retry = true}) {
    final ctx = verseKeys[verseId]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, alignment: 0.02, duration: Duration.zero);
    } else if (retry) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scrollToVerse(verseId, retry: false),
      );
    }
  }

  void scrollBy(double delta) {
    if (!scrollController.hasClients) return;
    stopAutoScroll();
    final position = scrollController.position;
    final target = math.min(
      position.maxScrollExtent,
      math.max(position.minScrollExtent, position.pixels + delta),
    );
    scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  void scheduleScrollReport() {
    _reportTimer?.cancel();
    _reportTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final cubit = context.read<BibleReaderCubit>();
      final viewport = viewportKey.currentContext?.findRenderObject();
      if (viewport is! RenderBox || !viewport.attached) return;
      final top = viewport.localToGlobal(Offset.zero).dy;
      for (final v in cubit.state.verses) {
        final box = verseKeys[v.verseId]?.currentContext?.findRenderObject();
        if (box is! RenderBox || !box.attached) continue;
        final dy = box.localToGlobal(Offset.zero).dy;
        if (dy + box.size.height > top + 4) {
          cubit.onVerseScrollPositionChanged(v.verseId, v.number);
          return;
        }
      }
    });
  }
}
