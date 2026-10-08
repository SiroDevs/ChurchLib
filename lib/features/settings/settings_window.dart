// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../common/windows/window_frame.dart';
import '../home/main/shell/app_module.dart';
import '../home/main/shell/shell_nav_item.dart';
import 'settings_sections.dart';

class SettingsWindow extends StatefulWidget {
  const SettingsWindow({super.key, required this.module});

  final AppModule module;

  @override
  State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  late final sections = settingsSectionsFor(widget.module);
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: WindowAppBar(
        icon: Icons.settings,
        title: '${widget.module.label} settings',
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 230,
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              border: Border(right: BorderSide(color: scheme.outlineVariant)),
            ),
            child: ListView(
              children: [
                for (var i = 0; i < sections.length; i++)
                  ShellNavItem(
                    sections[i].icon,
                    sections[i].label,
                    isSelected: i == _selected,
                    onPressed: () => setState(() => _selected = i),
                  ),
              ],
            ),
          ),
          Expanded(
            child: sections[_selected].scrolls
                ? ListView(
                    key: ValueKey(_selected),
                    padding: const EdgeInsets.all(16),
                    children: [sections[_selected].builder(context)],
                  )
                : sections[_selected].builder(context),
          ),
        ],
      ),
    );
  }
}
