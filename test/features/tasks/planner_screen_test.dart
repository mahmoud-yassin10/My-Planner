import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/features/planner/application/planner_controller.dart';
import 'package:momentum_os/features/planner/domain/planner_models.dart';
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
    expect(find.text('No scheduled items for this day.'), findsOneWidget);
    expect(find.byKey(const ValueKey('createTaskButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('createEventButton')), findsOneWidget);
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
        entityTags: [
          EntityTag(
            id: 'entity-tag-1',
            entityType: 'task',
            entityId: 'task-1',
            tagId: 'tag-1',
            createdAt: now,
          ),
        ],
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
        noteLinks: [
          NoteLink(
            id: 'note-link-1',
            noteId: 'note-1',
            entityType: 'task',
            entityId: 'task-1',
            relationshipType: 'related',
            createdAt: now,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();

    expect(find.text('Task A'), findsOneWidget);
    expect(find.text('Tag A'), findsOneWidget);
    expect(find.text('Status: inbox; 1 tags, 1 notes'), findsOneWidget);
    expect(find.text('Used on 1 records'), findsOneWidget);
    expect(find.byTooltip('Edit Task A'), findsOneWidget);
    expect(find.byTooltip('Archive Task A'), findsOneWidget);
    expect(find.byKey(const ValueKey('tagFirstTaskButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('linkFirstNoteButton')), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('plannerTaskCoreContent')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('Note A'), findsOneWidget);
    expect(find.text('Note; linked to 1 records'), findsOneWidget);
  });

  testWidgets('Planner screen exposes restore actions for archived records', (
    tester,
  ) async {
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
            archivedAt: now,
          ),
        ],
      ),
    );

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();

    expect(find.text('Archived task'), findsOneWidget);
    expect(find.byTooltip('Restore Task A'), findsOneWidget);
  });

  testWidgets('Planner screen renders schedule tabs and planner records', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 24, 9);

    await _pumpPlannerScreen(
      tester,
      TaskCoreSnapshot(
        tasks: [
          TaskItem(
            id: 'task-1',
            title: 'Scheduled Task',
            status: TaskStatus.planned,
            priority: TaskPriority.medium,
            energyRequirement: TaskEnergyRequirement.normal,
            scheduledStartAt: now,
            scheduledEndAt: now.add(const Duration(hours: 1)),
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
      plannerSnapshot: PlannerSnapshot(
        events: [
          PlannerEvent(
            id: 'event-1',
            title: 'Event A',
            kind: PlannerEventKind.event,
            startsAt: now,
            endsAt: now.add(const Duration(hours: 1)),
            isAllDay: false,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        timeBlocks: [
          TimeBlock(
            id: 'block-1',
            title: 'Focus Block',
            kind: TimeBlockKind.focus,
            startsAt: now.add(const Duration(hours: 2)),
            endsAt: now.add(const Duration(hours: 3)),
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
    );

    expect(find.text('Day'), findsWidgets);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Event A'), findsOneWidget);
    expect(find.text('Focus Block'), findsOneWidget);
    expect(find.text('Scheduled Task'), findsOneWidget);
  });
}

Future<void> _pumpPlannerScreen(
  WidgetTester tester,
  TaskCoreSnapshot snapshot, {
  PlannerSnapshot plannerSnapshot = const PlannerSnapshot(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskCoreSnapshotProvider.overrideWith((ref) => Stream.value(snapshot)),
        plannerSnapshotProvider.overrideWith(
          (ref) => Stream.value(plannerSnapshot),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: PlannerScreen())),
    ),
  );
  await tester.pumpAndSettle();
}
