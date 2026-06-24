import 'package:flutter/material.dart';

import '../routing/app_routes.dart';

class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

const appDestinations = [
  AppDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    path: AppRoutePaths.home,
  ),
  AppDestination(
    label: 'Planner',
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today,
    path: AppRoutePaths.planner,
  ),
  AppDestination(
    label: 'Spaces',
    icon: Icons.dashboard_customize_outlined,
    selectedIcon: Icons.dashboard_customize,
    path: AppRoutePaths.spaces,
  ),
  AppDestination(
    label: 'Goals',
    icon: Icons.flag_outlined,
    selectedIcon: Icons.flag,
    path: AppRoutePaths.goals,
  ),
  AppDestination(
    label: 'Insights',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
    path: AppRoutePaths.insights,
  ),
];
