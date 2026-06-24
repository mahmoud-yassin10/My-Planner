import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/features/goals/application/hierarchy_controller.dart';
import 'package:momentum_os/features/goals/domain/hierarchy_models.dart';
import 'package:momentum_os/features/goals/presentation/goals_screen.dart';

void main() {
  testWidgets('Goals screen renders the empty hierarchy state', (tester) async {
    await _pumpGoalsScreen(tester, const HierarchySnapshot());

    expect(find.byKey(const ValueKey('goalsDestinationTitle')), findsOneWidget);
    expect(find.text('No hierarchy records yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('createAreaButton')), findsOneWidget);
  });

  testWidgets('Goals screen renders hierarchy content', (tester) async {
    final now = DateTime.utc(2026, 6, 24);

    await _pumpGoalsScreen(
      tester,
      HierarchySnapshot(
        areas: [
          Area(
            id: 'area-1',
            name: 'Area A',
            status: AreaStatus.active,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        goals: [
          Goal(
            id: 'goal-1',
            title: 'Goal A',
            status: GoalStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        projects: [
          Project(
            id: 'project-1',
            title: 'Project A',
            status: ProjectStatus.planned,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        milestones: [
          Milestone(
            id: 'milestone-1',
            title: 'Milestone A',
            status: MilestoneStatus.planned,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
    );

    expect(find.text('Area A'), findsOneWidget);
    expect(find.text('Goal A'), findsOneWidget);
    expect(find.text('Project A'), findsOneWidget);
    expect(find.text('Milestone A'), findsOneWidget);
  });
}

Future<void> _pumpGoalsScreen(
  WidgetTester tester,
  HierarchySnapshot snapshot,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hierarchySnapshotProvider.overrideWith((ref) => Stream.value(snapshot)),
      ],
      child: const MaterialApp(home: Scaffold(body: GoalsScreen())),
    ),
  );
  await tester.pump();
}
