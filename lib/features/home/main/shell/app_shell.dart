import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../../common/windows/open_windows.dart';
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../domain/repos/pref_repo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../license/ui/license_banner.dart';
import 'app_module.dart';
import 'how_it_works_sheet.dart';
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: kShellSidebarWidth,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    border: Border(right: divider),
                  ),
                  child: _Sidebar(module: module, items: sidebarItems),
                ),
                body.expanded(),
              ],
            )
                .expanded(),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppSwitcher(module: module).alignment(Alignment.centerLeft)
              .padding(horizontal: 10)
              .constrained(width: kShellSidebarWidth),
          titleBar.expanded(),
        ],
      )
          .constrained(minHeight: 56),
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
        Row(
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
        )
            .padding(left: 6, top: 4, right: 12, bottom: 4)
            .decorated(
              color: ThemeColors.primary.withValues(alpha: .85),
              borderRadius: BorderRadius.circular(8),
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
  const _Sidebar({required this.module, required this.items});

  final AppModule module;
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
        ListView(
          padding: const EdgeInsets.only(top: 6),
          children: items,
        )
            .expanded(),
        const LicenseBanner(),
        divider,
        ShellNavItem(
          Icons.help_outline,
          'How it works',
          onPressed: () => showHowItWorks(context, module),
        ),
        ShellNavItem(
          isDark ? Icons.light_mode : Icons.dark_mode,
          isDark ? 'Light mode' : 'Dark mode',
          onPressed: () => _toggleTheme(context, isDark),
        ),
        divider,
        ShellNavItem(
          Icons.settings,
          l10n.settingsTitle,
          onPressed: () => openSettings(context, module),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
