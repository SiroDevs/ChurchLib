// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../../../l10n/app_localizations.dart';
import 'app_module.dart';
import 'settings_window.dart';
import 'shell_nav_item.dart';

const double kShellSidebarWidth = 250;

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.module,
    required this.titleBar,
    required this.sidebarItems,
    required this.body,
  });

  final AppModule module;
  final Widget titleBar;
  final List<Widget> sidebarItems;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = BorderSide(color: scheme.outlineVariant, width: 1);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(module: module, titleBar: titleBar),
            Divider(height: 1, color: scheme.outlineVariant),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: kShellSidebarWidth,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      border: Border(right: divider),
                    ),
                    child: _Sidebar(items: sidebarItems),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.module, required this.titleBar});

  final AppModule module;
  final Widget titleBar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
        return Material(
      color: scheme.secondaryContainer,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: kShellSidebarWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppSwitcher(module: module),
                ),
              ),
            ),
            Expanded(child: titleBar),
          ],
        ),
      ),
    );
  }
}

class AppSwitcher extends StatelessWidget {
  const AppSwitcher({super.key, required this.module});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    final scope = HomeModuleScope.maybeOf(context);
    final others = (scope?.enabled ?? const <AppModule>[])
        .where((m) => m != module)
        .toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
          decoration: BoxDecoration(
            color: ThemeColors.primary.withValues(alpha: .85),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(module.icon, width: 26, height: 26),
              const SizedBox(width: 8),
              Text(
                module.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        for (final other in others)
          Tooltip(
            message: 'Switch to ${other.label}',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => scope!.onSwitch(other),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(other.icon, width: 28, height: 28),
              ),
            ),
          ),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.items});

  final List<Widget> items;

  void _toggleTheme(BuildContext context, bool isDark) {
    final mode = isDark ? ThemeMode.light : ThemeMode.dark;
    getIt<PrefRepo>().updateThemeMode(mode);
    context.read<ThemeBloc>().add(ThemeModeChanged(mode));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );

    return Column(
      children: [
        const SizedBox(height: 6),
        ...items,
        const Spacer(),
        divider,
        ShellNavItem(
          isDark ? Icons.light_mode : Icons.dark_mode,
          isDark ? 'Light mode' : 'Dark mode',
          onPressed: () => _toggleTheme(context, isDark),
        ),
        divider,
        ShellNavItem(
          Icons.settings,
          l10n.settingsTitle,
          onPressed: () => showSettingsWindow(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
