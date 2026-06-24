import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/errors/persistence_failure.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/features/tasks/data/drift_task_core_repository.dart';
import 'package:momentum_os/features/tasks/domain/task_core_models.dart';

void main() {
  late AppDatabase database;
  late List<AppLogRecord> records;
  late DriftTaskCoreRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    records = <AppLogRecord>[];
    repository = DriftTaskCoreRepository(
      database: database,
      idService: FixedIdService([
        'task-1',
        'task-2',
        'tag-1',
        'entity-tag-1',
        'note-1',
        'note-link-1',
      ]),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 9)),
      logger: AppLogger(sink: records.add),
    );
  });

  tearDown(() => database.close());

  test(
    'creates tasks, subtasks, tags, entity tags, notes, and links',
    () async {
      final task = await repository.createTask(
        const TaskDraft(title: 'Task A'),
      );
      final subtask = await repository.createTask(
        TaskDraft(title: 'Task B', parentTaskId: task.id),
      );
      final tag = await repository.createTag(const TagDraft(name: 'Tag A'));
      final entityTag = await repository.tagEntity(
        entityType: 'task',
        entityId: task.id,
        tagId: tag.id,
      );
      final note = await repository.createNote(
        const NoteDraft(title: 'Note A', content: 'Generic note'),
      );
      final link = await repository.linkNote(
        noteId: note.id,
        entityType: 'task',
        entityId: task.id,
      );

      final snapshot = await repository.current();

      expect(task.id, 'task-1');
      expect(subtask.parentTaskId, task.id);
      expect(entityTag.tagId, tag.id);
      expect(link.noteId, note.id);
      expect(snapshot.tasks, hasLength(2));
      expect(snapshot.tags.single.name, 'Tag A');
      expect(snapshot.notes.single.title, 'Note A');
      expect(snapshot.tasks.first.createdAt.isUtc, isTrue);
    },
  );

  test('completes, archives, restores, and deletes tasks', () async {
    final task = await repository.createTask(const TaskDraft(title: 'Task A'));

    await repository.completeTask(task.id);
    expect((await repository.current()).tasks.single.isCompleted, isTrue);

    await repository.archiveTask(task.id);
    expect((await repository.current()).tasks.single.isArchived, isTrue);

    await repository.restoreTask(task.id);
    expect((await repository.current()).tasks.single.isArchived, isFalse);

    await repository.deleteTask(task.id);
    expect((await repository.current()).tasks, isEmpty);
  });

  test('rejects task hierarchy cycles', () async {
    final parent = await repository.createTask(
      const TaskDraft(title: 'Task A'),
    );
    final child = await repository.createTask(
      TaskDraft(title: 'Task B', parentTaskId: parent.id),
    );

    await expectLater(
      repository.updateTask(
        parent.id,
        TaskDraft(title: 'Task A', parentTaskId: child.id),
      ),
      throwsA(isA<PersistenceValidationFailure>()),
    );
  });

  test('translates foreign key failures at the repository boundary', () async {
    await expectLater(
      repository.tagEntity(
        entityType: 'task',
        entityId: 'task-1',
        tagId: 'missing-tag',
      ),
      throwsA(isA<PersistenceWriteFailure>()),
    );

    expect(records.single.operation, 'tagEntity');
    expect(records.single.error, isNotNull);
    expect(records.single.stackTrace, isNotNull);
  });
}
