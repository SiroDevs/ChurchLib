import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

import '../../../common/constants/pref_constants.dart';
import '../../../common/utils/display/app_window.dart';
import '../../../core/di/injectable.dart';
import '../../../domain/repos/pref_repo.dart';
import 'debounced_screen_listener.dart';
import 'presentation_displays.dart';
import 'presentation_session.dart';
import '../ui/audience_screen.dart';

export 'presentation_session.dart';

class PresentationController extends ChangeNotifier
    with ScreenListener, DebouncedScreenListener {
  PresentationController._();

  static final instance = PresentationController._();

  final session = ValueNotifier<PresentationSession?>(null);
  final activeSlideIndex = ValueNotifier<int>(0);
  final blackout = ValueNotifier<bool>(false);
  final scale = ValueNotifier<double>(1);
  final align = ValueNotifier<TextAlign>(TextAlign.left);
  int? _audienceWindowId;
  bool _active = false;
  bool _listeningForDisplays = false;
  bool _windowOpening = false;
  String? _windowTitle;
  int _windowRequestId = 0;

  bool get active => _active;

  bool get _hasSecondDisplay => PresentationDisplays.extended.isNotEmpty;

  bool get audienceModeEnabled =>
      !getIt<PrefRepo>().getPrefBool(PrefConstants.audienceModeDisabledKey);

  bool get hasExtendedDisplay => audienceModeEnabled && _hasSecondDisplay;

  List<Display> get _secondaryDisplays => PresentationDisplays.extended;

  void _listenForDisplayChanges() {
    if (_listeningForDisplays || !hasExtendedDisplay) return;
    _listeningForDisplays = true;
    MultiViewDesktop.screen.addListener(this);
  }

  void _stopListeningForDisplayChanges() {
    if (!_listeningForDisplays) return;
    _listeningForDisplays = false;
    MultiViewDesktop.screen.removeListener(this);
  }

  @override
  void onScreenChanged() {
    if (_active && !hasExtendedDisplay) {
      _active = false;
      _stopListeningForDisplayChanges();
      _closeWindow();
      AppWindow.setFullScreen(true);
    } else if (_active) {
      _openWindow();
    }
    notifyListeners();
  }

  Size get previewSize {
    return PresentationDisplays.previewSize;
  }

  void setWindowTitle(String value) {
    if (_windowTitle == value) return;
    _windowTitle = value;
    final viewId = _audienceWindowId;
    if (viewId != null) MultiViewDesktop.fromId(viewId).setTitle(value);
  }

  void present(PresentationSession next, {int at = 0}) {
    session.value = next;
    activeSlideIndex.value = at;
    blackout.value = false;
    start();
  }

  void select(int slideIndex) {
    final slideCount = session.value?.items.length ?? 0;
    if (slideIndex >= 0 && slideIndex < slideCount) {
      activeSlideIndex.value = slideIndex;
    }
  }

  void toggleBlackout() => blackout.value = !blackout.value;

  void clearBlackout() => blackout.value = false;

  void resize(double delta) =>
      scale.value = (scale.value + delta).clamp(0.5, 2.0).toDouble();

  void resetScale() => scale.value = 1;

  void cycleAlign() => align.value = switch (align.value) {
    TextAlign.left => TextAlign.center,
    TextAlign.center => TextAlign.right,
    _ => TextAlign.left,
  };

  void toggle() => _active ? stop() : start();

  void setAudienceModeEnabled(bool enabled) {
    getIt<PrefRepo>().setPrefBool(
      PrefConstants.audienceModeDisabledKey,
      !enabled,
    );
    if (!enabled && _active) {
      stop();
    } else {
      notifyListeners();
    }
  }

  void start() {
    if (!hasExtendedDisplay) return;
    _active = true;
    _listenForDisplayChanges();
    _openWindow();
    notifyListeners();
  }

  void stop() {
    _active = false;
    clearBlackout();
    _stopListeningForDisplayChanges();
    _closeWindow();
    notifyListeners();
  }

  void _openWindow() {
    final displays = _secondaryDisplays;
    if (_audienceWindowId != null || _windowOpening || displays.isEmpty) return;
    final requestId = ++_windowRequestId;
    _windowOpening = true;
    unawaited(_createAudienceWindow(displays.first, requestId));
  }

  Future<void> _createAudienceWindow(Display display, int requestId) async {
    try {
      final viewId = await openWindow(
        (context, viewId) {
          if (_audienceWindowId == viewId) return const AudienceWindow();
          _audienceWindowId = viewId;
          final audienceWindow = MultiViewDesktop.fromId(viewId);
          final bounds = display.physicalBounds;
          if (bounds != null) {
            audienceWindow.setPhysicalBounds(bounds);
          } else if (display.visiblePosition != null) {
            unawaited(audienceWindow.setPosition(display.visiblePosition!));
          }
          return const AudienceWindow();
        },
        options: WindowOptions(
          alignment: Alignment.topLeft,
          fullScreen: true,
          size: display.size,
          title: _windowTitle ?? 'ChurchLib',
          titleBarStyle: TitleBarStyle.hidden,
          windowButtonVisibility: false,
        ),
      );
      if (requestId != _windowRequestId || !_active) {
        if (_audienceWindowId == viewId) {
          _audienceWindowId = null;
          await MultiViewDesktop.fromId(viewId).closeWindow();
        }
        return;
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Could not open the audience window: $error');
    } finally {
      _windowOpening = false;
      if (_active && requestId != _windowRequestId) _openWindow();
    }
  }

  void onAudienceWindowClosed(int viewId) {
    if (_audienceWindowId != viewId) return;
    _audienceWindowId = null;
    _windowRequestId++;
    _active = false;
    _stopListeningForDisplayChanges();
    notifyListeners();
  }

  void _closeWindow() {
    _windowRequestId++;
    final viewId = _audienceWindowId;
    _audienceWindowId = null;
    if (viewId != null) unawaited(_destroyAudienceWindow(viewId));
    notifyListeners();
  }

  Future<void> _destroyAudienceWindow(int viewId) async {
    try {
      await MultiViewDesktop.fromId(viewId).closeWindow();
    } catch (error) {
      debugPrint('Could not close the audience window: $error');
    }
  }
}
