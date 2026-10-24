// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/display/app_window.dart';

/// Toggles full screen for the main window (F11 does the same).
class FullScreenButton extends StatelessWidget {
  const FullScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppWindow.fullScreen,
      builder: (context, full, _) => IconButton(
        tooltip: full ? 'Exit full screen (F11)' : 'Full screen (F11)',
        onPressed: AppWindow.toggleFullScreen,
        icon: Icon(full ? Icons.fullscreen_exit : Icons.fullscreen),
      ),
    );
  }
}
