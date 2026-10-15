// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_module.dart';

/// Keyboard focus for one module (SongLib or BibleLib) of the home screen.
///
/// Both modules stay alive side by side, so this claims keyboard focus when
/// [module] is switched to. The home screen takes focus away from the module
/// that is switched away from, so its shortcuts stop receiving keys.
class ModuleFocus extends StatefulWidget {
  const ModuleFocus({
    super.key,
    required this.module,
    required this.child,
    this.onKeyEvent,
  });

  final AppModule module;
  final Widget child;
  final FocusOnKeyEventCallback? onKeyEvent;

  @override
  State<ModuleFocus> createState() => _ModuleFocusState();
}

class _ModuleFocusState extends State<ModuleFocus> {
  final _node = FocusNode(debugLabel: 'ModuleFocus');
  bool _active = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = HomeModuleScope.maybeOf(context)?.current;
    final active = current == null || current == widget.module;
    if (active && !_active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _node.requestFocus();
      });
    }
    _active = active;
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      autofocus: true,
      onKeyEvent: widget.onKeyEvent,
      child: widget.child,
    );
  }
}
