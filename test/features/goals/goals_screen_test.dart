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
            areaId: 'area-1',
            status: GoalStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        projects: [
          Project(
            id: 'project-1',
            title: 'Project A',
            areaId: 'area-1',
            goalId: 'goal-1',
            status: ProjectStatus.planned,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        milestones: [
          Milestone(
            id: 'milestone-1',
            title: 'Milestone A',
            goalId: 'goal-1',
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
    expect(find.text('1 goals, 1 projects'), findsOneWidget);
    expect(
      find.text('Status: active; 1 projects, 1 milestones'),
      findsOneWidget,
    );
    expect(find.byTooltip('Edit Goal A'), findsOneWidget);
    expect(find.byTooltip('Archive Goal A'), findsOneWidget);
  });

  testWidgets('Goals screen exposes restore actions for archived records', (
    tester,
  ) async {
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
            archivedAt: now,
          ),
        ],
      ),
    );

    expect(find.text('Archived area'), findsOneWidget);
    expect(find.byTooltip('Restore Area A'), findsOneWidget);
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
