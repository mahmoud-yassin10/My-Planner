import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/errors/persistence_failure.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/features/planner/data/drift_planner_repository.dart';
import 'package:momentum_os/features/planner/domain/planner_models.dart';
import 'package:momentum_os/features/tasks/data/drift_task_core_repository.dart';
import 'package:momentum_os/features/tasks/domain/task_core_models.dart';

void main() {
  late AppDatabase database;
  late List<AppLogRecord> records;
  late DriftPlannerRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    records = <AppLogRecord>[];
    repository = DriftPlannerRepository(
      database: database,
      idService: FixedIdService(['event-1', 'block-1']),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 8)),
      logger: AppLogger(sink: records.add),
    );
  });

  tearDown(() => database.close());

  test('creates events and time blocks with stable IDs', () async {
    final startsAt = DateTime.utc(2026, 6, 24, 9);

    final event = await repository.createEvent(
      PlannerEventDraft(
        title: 'Event A',
        kind: PlannerEventKind.meeting,
        startsAt: startsAt,
        endsAt: startsAt.add(const Duration(hours: 1)),
        recurrenceRule: 'contract:none',
        reminderPolicy: 'contract:none',
      ),
    );
    final block = await repository.createTimeBlock(
      TimeBlockDraft(
        title: 'Focus Block',
        startsAt: startsAt.add(const Duration(hours: 2)),
        endsAt: startsAt.add(const Duration(hours: 3)),
      ),
    );

    final snapshot = await repository.current();

    expect(event.id, 'event-1');
    expect(event.kind, PlannerEventKind.meeting);
    expect(event.recurrenceRule, 'contract:none');
    expect(block.id, 'block-1');
    expect(snapshot.events.single.title, 'Event A');
    expect(snapshot.timeBlocks.single.title, 'Focus Block');
    expect(snapshot.events.single.createdAt.isUtc, isTrue);
  });

  test('updates, archives, restores, and deletes planner records', () async {
    final startsAt = DateTime.utc(2026, 6, 24, 9);
    final event = await repository.createEvent(
      PlannerEventDraft(
        title: 'Event A',
        startsAt: startsAt,
        endsAt: startsAt.add(const Duration(hours: 1)),
      ),
    );
    final block = await repository.createTimeBlock(
      TimeBlockDraft(
        title: 'Block A',
        startsAt: startsAt.add(const Duration(hours: 2)),
        endsAt: startsAt.add(const Duration(hours: 3)),
      ),
    );

    await repository.updateEvent(
      event.id,
      PlannerEventDraft(
        title: 'Event B',
        startsAt: startsAt,
        endsAt: startsAt.add(const Duration(hours: 1)),
      ),
    );
    await repository.updateTimeBlock(
      block.id,
      TimeBlockDraft(
        title: 'Block B',
        startsAt: startsAt.add(const Duration(hours: 2)),
        endsAt: startsAt.add(const Duration(hours: 3)),
      ),
    );
    await repository.archiveEvent(event.id);
    await repository.archiveTimeBlock(block.id);
    await repository.restoreEvent(event.id);
    await repository.restoreTimeBlock(block.id);

    final snapshot = await repository.current();
    expect(snapshot.events.single.title, 'Event B');
    expect(snapshot.events.single.isArchived, isFalse);
    expect(snapshot.timeBlocks.single.title, 'Block B');
    expect(snapshot.timeBlocks.single.isArchived, isFalse);

    await repository.deleteEvent(event.id);
    await repository.deleteTimeBlock(block.id);
    expect((await repository.current()).isEmpty, isTrue);
  });

  test('rejects invalid schedule ranges', () async {
    final startsAt = DateTime.utc(2026, 6, 24, 9);

    await expectLater(
      repository.createEvent(
        PlannerEventDraft(
          title: 'Invalid',
          startsAt: startsAt,
          endsAt: startsAt,
        ),
      ),
      throwsA(isA<PersistenceValidationFailure>()),
    );
  });

  test('translates foreign key failures at the repository boundary', () async {
    final startsAt = DateTime.utc(2026, 6, 24, 9);

    await expectLater(
      repository.createEvent(
        PlannerEventDraft(
          title: 'Linked event',
          startsAt: startsAt,
          endsAt: startsAt.add(const Duration(hours: 1)),
          linkedTaskId: 'missing-task',
        ),
      ),
      throwsA(isA<PersistenceWriteFailure>()),
    );

    expect(records.single.operation, 'createEvent');
    expect(records.single.error, isNotNull);
    expect(records.single.stackTrace, isNotNull);
  });

  test('detects conflicts and free windows from schedule items', () {
    final startsAt = DateTime.utc(2026, 6, 24, 9);
    final snapshot = PlannerSnapshot(
      events: [
        PlannerEvent(
          id: 'event-1',
          title: 'Event A',
          kind: PlannerEventKind.event,
          startsAt: startsAt,
          endsAt: startsAt.add(const Duration(hours: 2)),
          isAllDay: false,
          createdAt: startsAt,
          updatedAt: startsAt,
        ),
      ],
      timeBlocks: [
        TimeBlock(
          id: 'block-1',
          title: 'Block A',
          kind: TimeBlockKind.focus,
          startsAt: startsAt.add(const Duration(hours: 1)),
          endsAt: startsAt.add(const Duration(hours: 3)),
          createdAt: startsAt,
          updatedAt: startsAt,
        ),
      ],
    );

    final items = plannerScheduleItems(snapshot);
    final conflicts = detectScheduleConflicts(items);
    final freeWindows = findFreeWindows(
      items: items,
      startsAt: DateTime.utc(2026, 6, 24, 8),
      endsAt: DateTime.utc(2026, 6, 24, 18),
      minimumMinutes: 60,
    );

    expect(conflicts, hasLength(1));
    expect(freeWindows.first.startsAt, DateTime.utc(2026, 6, 24, 8));
    expect(freeWindows.last.startsAt, DateTime.utc(2026, 6, 24, 12));
  });

  test('planner events can link to existing tasks', () async {
    final taskRepository = DriftTaskCoreRepository(
      database: database,
      idService: FixedIdService(['task-1']),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 8)),
      logger: AppLogger(sink: records.add),
    );
    final task = await taskRepository.createTask(
      const TaskDraft(title: 'Task A'),
    );
    final startsAt = DateTime.utc(2026, 6, 24, 9);

    final event = await repository.createEvent(
      PlannerEventDraft(
        title: 'Task event',
        startsAt: startsAt,
        endsAt: startsAt.add(const Duration(hours: 1)),
        linkedTaskId: task.id,
      ),
    );

    expect(event.linkedTaskId, task.id);
  });
}
