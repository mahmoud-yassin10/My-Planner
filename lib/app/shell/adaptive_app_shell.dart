import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_theme.dart';
import 'app_destination.dart';
import 'quick_add_sheet.dart';

class AdaptiveAppShell extends StatelessWidget {
  const AdaptiveAppShell({super.key, required this.navigationShell});

  static const compactBreakpoint = 700.0;

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompactNavigation = constraints.maxWidth < compactBreakpoint;

        if (useCompactNavigation) {
          return _CompactShell(navigationShell: navigationShell);
        }

        return _WideShell(navigationShell: navigationShell);
      },
    );
  }
}

class _CompactShell extends StatelessWidget {
  const _CompactShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('compactNavigationShell'),
      body: SafeArea(
        child: Column(
          children: [
            const _GlobalActionBar(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('quickAddButton'),
        tooltip: 'Open Quick Add',
        onPressed: () => showQuickAddSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goToBranch,
        destinations: [
          for (final destination in appDestinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
              tooltip: '${destination.label} destination',
            ),
        ],
      ),
    );
  }

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _WideShell extends StatelessWidget {
  const _WideShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('wideNavigationShell'),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('quickAddButton'),
        tooltip: 'Open Quick Add',
        onPressed: () => showQuickAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Quick Add'),
      ),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goToBranch,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final destination in appDestinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x1,
                    ),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  const _GlobalActionBar(),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _GlobalActionBar extends StatelessWidget {
  const _GlobalActionBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _GlobalActionButton(
              tooltip: 'Open AI Copilot',
              icon: Icons.auto_awesome_outlined,
              path: AppRoutePaths.ai,
            ),
            _GlobalActionButton(
              tooltip: 'Open Global Search',
              icon: Icons.search,
              path: AppRoutePaths.search,
            ),
            _GlobalActionButton(
              tooltip: 'Open Notification Inbox',
              icon: Icons.notifications_outlined,
              path: AppRoutePaths.notifications,
            ),
            _GlobalActionButton(
              tooltip: 'Open Settings',
              icon: Icons.settings_outlined,
              path: AppRoutePaths.settings,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalActionButton extends StatelessWidget {
  const _GlobalActionButton({
    required this.tooltip,
    required this.icon,
    required this.path,
  });

  final String tooltip;
  final IconData icon;
  final String path;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: () => context.go(path),
    );
  }
}
