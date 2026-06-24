import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/features/planner/presentation/planner_screen.dart';
import 'package:momentum_os/features/tasks/application/task_core_controller.dart';
import 'package:momentum_os/features/tasks/domain/task_core_models.dart';

void main() {
  testWidgets('Planner screen renders the empty task-core state', (
    tester,
  ) async {
    await _pumpPlannerScreen(tester, const TaskCoreSnapshot());

    expect(
      find.byKey(const ValueKey('plannerDestinationTitle')),
      findsOneWidget,
    );
    expect(find.text('No task-core records yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('createTaskButton')), findsOneWidget);
  });

  testWidgets('Planner screen renders task-core content', (tester) async {
    final now = DateTime.utc(2026, 6, 24);

    await _pumpPlannerScreen(
      tester,
      TaskCoreSnapshot(
        tasks: [
          TaskItem(
            id: 'task-1',
            title: 'Task A',
            status: TaskStatus.inbox,
            priority: TaskPriority.medium,
            energyRequirement: TaskEnergyRequirement.normal,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        tags: [Tag(id: 'tag-1', name: 'Tag A', createdAt: now, updatedAt: now)],
        notes: [
          Note(
            id: 'note-1',
            title: 'Note A',
            content: '',
            contentFormat: NoteContentFormat.plainText,
            isPinned: false,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
    );

    expect(find.text('Task A'), findsOneWidget);
    expect(find.text('Tag A'), findsOneWidget);
    expect(find.text('Note A'), findsOneWidget);
  });
}

Future<void> _pumpPlannerScreen(
  WidgetTester tester,
  TaskCoreSnapshot snapshot,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskCoreSnapshotProvider.overrideWith((ref) => Stream.value(snapshot)),
      ],
      child: const MaterialApp(home: Scaffold(body: PlannerScreen())),
    ),
  );
  await tester.pump();
}
