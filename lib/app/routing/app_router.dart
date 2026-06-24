import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/goals/presentation/goals_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/planner/presentation/planner_screen.dart';
import '../../features/spaces/presentation/spaces_screen.dart';
import '../shell/adaptive_app_shell.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _plannerNavigatorKey = GlobalKey<NavigatorState>();
final _spacesNavigatorKey = GlobalKey<NavigatorState>();
final _goalsNavigatorKey = GlobalKey<NavigatorState>();
final _insightsNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePaths.root,
    routes: [
      GoRoute(
        path: AppRoutePaths.root,
        name: AppRouteNames.root,
        redirect: (context, state) => AppRoutePaths.home,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveAppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _plannerNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.planner,
                name: AppRouteNames.planner,
                builder: (context, state) => const PlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _spacesNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.spaces,
                name: AppRouteNames.spaces,
                builder: (context, state) => const SpacesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _goalsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.goals,
                name: AppRouteNames.goals,
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _insightsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutePaths.insights,
                name: AppRouteNames.insights,
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
