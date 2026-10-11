import 'package:flutter/material.dart';

import '../../common/utils/constants/pref_constants.dart';
import '../../common/windows/window_frame.dart';
import '../../core/di/injectable.dart';
import '../../domain/repos/pref_repo.dart';
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
  late final List<SettingsNode> _tree;
  late final List<SettingsNode> _leaves;
  late final Set<String> _expanded;
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    final prefs = getIt<PrefRepo>();
    _tree = settingsTree(
      songlibEnabled: prefs.getPrefBool(PrefConstants.songlibModuleEnabledKey),
      biblelibEnabled: prefs.getPrefBool(
        PrefConstants.biblelibModuleEnabledKey,
      ),
    );
    _leaves = settingsLeaves(_tree).toList();
    _expanded = {
      for (final node in _tree)
        if (node.isGroup) node.id,
    };

    _selectedId = 'appearance';
  }

  SettingsNode get _selected => _leaves.firstWhere(
    (n) => n.id == _selectedId,
    orElse: () => _leaves.first,
  );

  void _toggle(String id) => setState(() {
    if (!_expanded.remove(id)) _expanded.add(id);
  });

  Widget _navItem(SettingsNode node, {double indent = 0}) {
    if (node.isGroup) {
      final open = _expanded.contains(node.id);
      return Column(
        children: [
          ShellNavItem(
            node.icon,
            node.label,
            onPressed: () => _toggle(node.id),
            trailing: Icon(
              open ? Icons.expand_less : Icons.expand_more,
              size: 20,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.topCenter,
            child: open
                ? Column(
                    children: [
                      for (final child in node.children)
                        _navItem(child, indent: 18),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      );
    }
    return ShellNavItem(
      node.icon,
      node.label,
      indent: indent,
      isSelected: node.id == _selected.id,
      onPressed: () => setState(() => _selectedId = node.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selected;
    return Scaffold(
      appBar: const WindowAppBar(icon: Icons.settings, title: 'ChurchLib Settings'),
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
            child: ListView(children: [for (final n in _tree) _navItem(n)]),
          ),
          Expanded(
            child: selected.scrolls
                ? ListView(
                    key: ValueKey(selected.id),
                    padding: const EdgeInsets.all(16),
                    children: [selected.builder!(context)],
                  )
                : KeyedSubtree(
                    key: ValueKey(selected.id),
                    child: selected.builder!(context),
                  ),
          ),
        ],
      ),
    );
  }
}
