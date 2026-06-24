import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/persistence_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/services/id_service.dart';
import '../../../core/services/utc_clock.dart';
import '../domain/task_core_models.dart';
import '../domain/task_core_repository.dart';

class DriftTaskCoreRepository implements TaskCoreRepository {
  const DriftTaskCoreRepository({
    required AppDatabase database,
    required IdService idService,
    required UtcClock clock,
    required AppLogger logger,
  }) : this._(database, idService, clock, logger);

  const DriftTaskCoreRepository._(
    this._database,
    this._idService,
    this._clock,
    this._logger,
  );

  final AppDatabase _database;
  final IdService _idService;
  final UtcClock _clock;
  final AppLogger _logger;

  @override
  Future<TaskCoreSnapshot> current() async {
    try {
      return _snapshot();
    } catch (error, stackTrace) {
      _logFailure('current', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read task core data.');
    }
  }

  @override
  Stream<TaskCoreSnapshot> watchTaskCore() async* {
    yield await current();
    yield* _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.tasks,
            _database.tags,
            _database.entityTags,
            _database.notes,
            _database.noteLinks,
          },
        )
        .watch()
        .skip(1)
        .asyncMap((_) => current())
        .handleError((Object error, StackTrace stackTrace) {
          _logFailure('watchTaskCore', error, stackTrace);
          throw const PersistenceReadFailure('Unable to watch task core data.');
        });
  }

  @override
  Future<TaskItem> createTask(TaskDraft draft) async {
    final cleaned = await _validateTaskDraft(draft);
    final now = _clock.now();
    final task = TaskItem(
      id: _idService.newId(),
      title: cleaned.title,
      description: cleaned.description,
      areaId: cleaned.areaId,
      goalId: cleaned.goalId,
      projectId: cleaned.projectId,
      milestoneId: cleaned.milestoneId,
      parentTaskId: cleaned.parentTaskId,
      status: cleaned.status,
      priority: cleaned.priority,
      energyRequirement: cleaned.energyRequirement,
      estimatedDurationMinutes: cleaned.estimatedDurationMinutes,
      actualDurationMinutes: cleaned.actualDurationMinutes,
      dueAt: _utcOrNull(cleaned.dueAt),
      scheduledStartAt: _utcOrNull(cleaned.scheduledStartAt),
      scheduledEndAt: _utcOrNull(cleaned.scheduledEndAt),
      preferredTimeOfDay: cleaned.preferredTimeOfDay,
      completedAt: _utcOrNull(cleaned.completedAt),
      notes: cleaned.notes,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database.into(_database.tasks).insert(_taskCompanion(task));
      return task;
    } catch (error, stackTrace) {
      _logFailure('createTask', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create task.');
    }
  }

  @override
  Future<TaskItem> updateTask(String id, TaskDraft draft) async {
    final previous = await _taskById(id);
    final cleaned = await _validateTaskDraft(draft, existingTaskId: id);
    final task = TaskItem(
      id: id,
      title: cleaned.title,
      description: cleaned.description,
      areaId: cleaned.areaId,
      goalId: cleaned.goalId,
      projectId: cleaned.projectId,
      milestoneId: cleaned.milestoneId,
      parentTaskId: cleaned.parentTaskId,
      status: cleaned.status,
      priority: cleaned.priority,
      energyRequirement: cleaned.energyRequirement,
      estimatedDurationMinutes: cleaned.estimatedDurationMinutes,
      actualDurationMinutes: cleaned.actualDurationMinutes,
      dueAt: _utcOrNull(cleaned.dueAt),
      scheduledStartAt: _utcOrNull(cleaned.scheduledStartAt),
      scheduledEndAt: _utcOrNull(cleaned.scheduledEndAt),
      preferredTimeOfDay: cleaned.preferredTimeOfDay,
      completedAt: _utcOrNull(cleaned.completedAt),
      notes: cleaned.notes,
      createdAt: previous.createdAt,
      updatedAt: _clock.now(),
      archivedAt: previous.archivedAt,
    );

    try {
      await (_database.update(
        _database.tasks,
      )..where((table) => table.id.equals(id))).write(_taskUpdate(task));
      return task;
    } catch (error, stackTrace) {
      _logFailure('updateTask', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update task.');
    }
  }

  @override
  Future<void> completeTask(String id) async {
    try {
      final now = _clock.now();
      final count =
          await (_database.update(
            _database.tasks,
          )..where((table) => table.id.equals(id))).write(
            TasksCompanion(
              status: Value(TaskStatus.completed.name),
              completedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      if (count == 0) {
        throw const PersistenceWriteFailure('Task was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure('completeTask', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to complete task.');
    }
  }

  @override
  Future<void> archiveTask(String id) => _setArchive(
    operation: 'archiveTask',
    tableName: 'tasks',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreTask(String id) => _setArchive(
    operation: 'restoreTask',
    tableName: 'tasks',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteTask(String id) => _delete(
    operation: 'deleteTask',
    tableName: 'tasks',
    delete: () => (_database.delete(
      _database.tasks,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<Tag> createTag(TagDraft draft) async {
    final name = _requiredText(draft.name, 'Tag name');
    final now = _clock.now();
    final tag = Tag(
      id: _idService.newId(),
      name: name,
      colorValue: draft.colorValue,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.tags)
          .insert(
            TagsCompanion.insert(
              id: tag.id,
              name: tag.name,
              colorValue: Value(tag.colorValue),
              createdAt: tag.createdAt,
              updatedAt: tag.updatedAt,
              archivedAt: const Value(null),
            ),
          );
      return tag;
    } catch (error, stackTrace) {
      _logFailure('createTag', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create tag.');
    }
  }

  @override
  Future<void> archiveTag(String id) => _setArchive(
    operation: 'archiveTag',
    tableName: 'tags',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> deleteTag(String id) => _delete(
    operation: 'deleteTag',
    tableName: 'tags',
    delete: () => (_database.delete(
      _database.tags,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<EntityTag> tagEntity({
    required String entityType,
    required String entityId,
    required String tagId,
  }) async {
    final now = _clock.now();
    final entityTag = EntityTag(
      id: _idService.newId(),
      entityType: _requiredText(entityType, 'Entity type'),
      entityId: _requiredText(entityId, 'Entity id'),
      tagId: _requiredText(tagId, 'Tag id'),
      createdAt: now,
    );

    try {
      await _database
          .into(_database.entityTags)
          .insert(
            EntityTagsCompanion.insert(
              id: entityTag.id,
              entityType: entityTag.entityType,
              entityId: entityTag.entityId,
              tagId: entityTag.tagId,
              createdAt: entityTag.createdAt,
            ),
          );
      return entityTag;
    } catch (error, stackTrace) {
      _logFailure('tagEntity', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to tag entity.');
    }
  }

  @override
  Future<Note> createNote(NoteDraft draft) async {
    final title = _requiredText(draft.title, 'Note title');
    final content = draft.content.trim();
    final now = _clock.now();
    final note = Note(
      id: _idService.newId(),
      title: title,
      content: content,
      contentFormat: draft.contentFormat,
      isPinned: draft.isPinned,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.notes)
          .insert(
            NotesCompanion.insert(
              id: note.id,
              title: note.title,
              content: note.content,
              contentFormat: note.contentFormat.name,
              isPinned: note.isPinned,
              createdAt: note.createdAt,
              updatedAt: note.updatedAt,
              archivedAt: const Value(null),
            ),
          );
      return note;
    } catch (error, stackTrace) {
      _logFailure('createNote', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create note.');
    }
  }

  @override
  Future<void> archiveNote(String id) => _setArchive(
    operation: 'archiveNote',
    tableName: 'notes',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> deleteNote(String id) => _delete(
    operation: 'deleteNote',
    tableName: 'notes',
    delete: () => (_database.delete(
      _database.notes,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<NoteLink> linkNote({
    required String noteId,
    required String entityType,
    required String entityId,
    String relationshipType = 'related',
  }) async {
    final now = _clock.now();
    final link = NoteLink(
      id: _idService.newId(),
      noteId: _requiredText(noteId, 'Note id'),
      entityType: _requiredText(entityType, 'Entity type'),
      entityId: _requiredText(entityId, 'Entity id'),
      relationshipType: _requiredText(relationshipType, 'Relationship type'),
      createdAt: now,
    );

    try {
      await _database
          .into(_database.noteLinks)
          .insert(
            NoteLinksCompanion.insert(
              id: link.id,
              noteId: link.noteId,
              entityType: link.entityType,
              entityId: link.entityId,
              relationshipType: link.relationshipType,
              createdAt: link.createdAt,
            ),
          );
      return link;
    } catch (error, stackTrace) {
      _logFailure('linkNote', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to link note.');
    }
  }

  Future<TaskCoreSnapshot> _snapshot() async {
    final tasks = await (_database.select(
      _database.tasks,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
    final tags = await (_database.select(
      _database.tags,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).get();
    final entityTags = await _database.select(_database.entityTags).get();
    final notes = await (_database.select(
      _database.notes,
    )..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])).get();
    final noteLinks = await _database.select(_database.noteLinks).get();

    return TaskCoreSnapshot(
      tasks: tasks.map(_taskFromRow).toList(),
      tags: tags.map(_tagFromRow).toList(),
      entityTags: entityTags.map(_entityTagFromRow).toList(),
      notes: notes.map(_noteFromRow).toList(),
      noteLinks: noteLinks.map(_noteLinkFromRow).toList(),
    );
  }

  Future<TaskItem> _taskById(String id) async {
    try {
      final row = await (_database.select(
        _database.tasks,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw const PersistenceReadFailure('Task was not found.');
      }
      return _taskFromRow(row);
    } catch (error, stackTrace) {
      _logFailure('readTask', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read task.');
    }
  }

  Future<TaskDraft> _validateTaskDraft(
    TaskDraft draft, {
    String? existingTaskId,
  }) async {
    final title = _requiredText(draft.title, 'Task title');
    if (draft.parentTaskId != null && draft.parentTaskId == existingTaskId) {
      throw const PersistenceValidationFailure(
        'A task cannot be its own parent.',
      );
    }
    if (existingTaskId != null && draft.parentTaskId != null) {
      await _validateTaskParentDoesNotCreateCycle(
        existingTaskId,
        draft.parentTaskId!,
      );
    }
    _validateDuration(draft.estimatedDurationMinutes, 'estimatedDuration');
    _validateDuration(draft.actualDurationMinutes, 'actualDuration');
    if (draft.scheduledStartAt != null &&
        draft.scheduledEndAt != null &&
        draft.scheduledEndAt!.isBefore(draft.scheduledStartAt!)) {
      throw const PersistenceValidationFailure(
        'Scheduled end must not be before scheduled start.',
      );
    }

    return TaskDraft(
      title: title,
      description: _optionalText(draft.description),
      areaId: _optionalText(draft.areaId),
      goalId: _optionalText(draft.goalId),
      projectId: _optionalText(draft.projectId),
      milestoneId: _optionalText(draft.milestoneId),
      parentTaskId: _optionalText(draft.parentTaskId),
      status: draft.status,
      priority: draft.priority,
      energyRequirement: draft.energyRequirement,
      estimatedDurationMinutes: draft.estimatedDurationMinutes,
      actualDurationMinutes: draft.actualDurationMinutes,
      dueAt: _utcOrNull(draft.dueAt),
      scheduledStartAt: _utcOrNull(draft.scheduledStartAt),
      scheduledEndAt: _utcOrNull(draft.scheduledEndAt),
      preferredTimeOfDay: _optionalText(draft.preferredTimeOfDay),
      completedAt: _utcOrNull(draft.completedAt),
      notes: _optionalText(draft.notes),
    );
  }

  Future<void> _validateTaskParentDoesNotCreateCycle(
    String taskId,
    String parentTaskId,
  ) async {
    var currentParentId = parentTaskId;
    while (true) {
      if (currentParentId == taskId) {
        throw const PersistenceValidationFailure(
          'Task hierarchy cannot contain cycles.',
        );
      }
      final parent = await (_database.select(
        _database.tasks,
      )..where((table) => table.id.equals(currentParentId))).getSingleOrNull();
      if (parent?.parentTaskId == null) {
        return;
      }
      currentParentId = parent!.parentTaskId!;
    }
  }

  Future<void> _setArchive({
    required String operation,
    required String tableName,
    required String id,
    required DateTime? archivedAt,
  }) async {
    try {
      final updatedAt = _clock.now();
      final sql = archivedAt == null
          ? 'UPDATE $tableName SET archived_at = NULL, updated_at = ? WHERE id = ?'
          : 'UPDATE $tableName SET archived_at = ?, updated_at = ? WHERE id = ?';
      final variables = archivedAt == null
          ? [Variable<DateTime>(updatedAt), Variable<String>(id)]
          : [
              Variable<DateTime>(archivedAt),
              Variable<DateTime>(updatedAt),
              Variable<String>(id),
            ];
      final count = await _database.customUpdate(
        sql,
        variables: variables,
        updates: {
          switch (tableName) {
            'tasks' => _database.tasks,
            'tags' => _database.tags,
            'notes' => _database.notes,
            _ => throw ArgumentError.value(tableName, 'tableName'),
          },
        },
      );
      if (count == 0) {
        throw const PersistenceWriteFailure('Record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update archive state.');
    }
  }

  Future<void> _delete({
    required String operation,
    required String tableName,
    required Future<int> Function() delete,
  }) async {
    try {
      final count = await delete();
      if (count == 0) {
        throw const PersistenceWriteFailure('Record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw PersistenceWriteFailure('Unable to delete $tableName record.');
    }
  }

  TasksCompanion _taskCompanion(TaskItem task) {
    return TasksCompanion.insert(
      id: task.id,
      title: task.title,
      description: Value(task.description),
      areaId: Value(task.areaId),
      goalId: Value(task.goalId),
      projectId: Value(task.projectId),
      milestoneId: Value(task.milestoneId),
      parentTaskId: Value(task.parentTaskId),
      status: task.status.name,
      priority: task.priority.name,
      energyRequirement: task.energyRequirement.name,
      estimatedDurationMinutes: Value(task.estimatedDurationMinutes),
      actualDurationMinutes: Value(task.actualDurationMinutes),
      dueAt: Value(task.dueAt),
      scheduledStartAt: Value(task.scheduledStartAt),
      scheduledEndAt: Value(task.scheduledEndAt),
      preferredTimeOfDay: Value(task.preferredTimeOfDay),
      completedAt: Value(task.completedAt),
      notes: Value(task.notes),
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      archivedAt: const Value(null),
    );
  }

  TasksCompanion _taskUpdate(TaskItem task) {
    return TasksCompanion(
      title: Value(task.title),
      description: Value(task.description),
      areaId: Value(task.areaId),
      goalId: Value(task.goalId),
      projectId: Value(task.projectId),
      milestoneId: Value(task.milestoneId),
      parentTaskId: Value(task.parentTaskId),
      status: Value(task.status.name),
      priority: Value(task.priority.name),
      energyRequirement: Value(task.energyRequirement.name),
      estimatedDurationMinutes: Value(task.estimatedDurationMinutes),
      actualDurationMinutes: Value(task.actualDurationMinutes),
      dueAt: Value(task.dueAt),
      scheduledStartAt: Value(task.scheduledStartAt),
      scheduledEndAt: Value(task.scheduledEndAt),
      preferredTimeOfDay: Value(task.preferredTimeOfDay),
      completedAt: Value(task.completedAt),
      notes: Value(task.notes),
      updatedAt: Value(task.updatedAt),
      archivedAt: Value(task.archivedAt),
    );
  }

  TaskItem _taskFromRow(TaskRow row) {
    return TaskItem(
      id: row.id,
      title: row.title,
      description: row.description,
      areaId: row.areaId,
      goalId: row.goalId,
      projectId: row.projectId,
      milestoneId: row.milestoneId,
      parentTaskId: row.parentTaskId,
      status: _enumValue(TaskStatus.values, row.status, TaskStatus.inbox),
      priority: _enumValue(
        TaskPriority.values,
        row.priority,
        TaskPriority.medium,
      ),
      energyRequirement: _enumValue(
        TaskEnergyRequirement.values,
        row.energyRequirement,
        TaskEnergyRequirement.normal,
      ),
      estimatedDurationMinutes: row.estimatedDurationMinutes,
      actualDurationMinutes: row.actualDurationMinutes,
      dueAt: row.dueAt,
      scheduledStartAt: row.scheduledStartAt,
      scheduledEndAt: row.scheduledEndAt,
      preferredTimeOfDay: row.preferredTimeOfDay,
      completedAt: row.completedAt,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  Tag _tagFromRow(TagRow row) => Tag(
    id: row.id,
    name: row.name,
    colorValue: row.colorValue,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    archivedAt: row.archivedAt,
  );

  EntityTag _entityTagFromRow(EntityTagRow row) => EntityTag(
    id: row.id,
    entityType: row.entityType,
    entityId: row.entityId,
    tagId: row.tagId,
    createdAt: row.createdAt,
  );

  Note _noteFromRow(NoteRow row) => Note(
    id: row.id,
    title: row.title,
    content: row.content,
    contentFormat: _enumValue(
      NoteContentFormat.values,
      row.contentFormat,
      NoteContentFormat.plainText,
    ),
    isPinned: row.isPinned,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    archivedAt: row.archivedAt,
  );

  NoteLink _noteLinkFromRow(NoteLinkRow row) => NoteLink(
    id: row.id,
    noteId: row.noteId,
    entityType: row.entityType,
    entityId: row.entityId,
    relationshipType: row.relationshipType,
    createdAt: row.createdAt,
  );

  String _requiredText(String value, String label) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw PersistenceValidationFailure('$label must not be empty.');
    }
    return trimmed;
  }

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  DateTime? _utcOrNull(DateTime? value) => value?.toUtc();

  void _validateDuration(int? value, String label) {
    if (value != null && value < 0) {
      throw PersistenceValidationFailure('$label must not be negative.');
    }
  }

  T _enumValue<T extends Enum>(List<T> values, String name, T fallback) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }

  void _logFailure(String operation, Object error, StackTrace stackTrace) {
    _logger.error(
      'taskCoreRepository',
      operation,
      'Task core repository operation failed.',
      metadata: {'errorType': error.runtimeType.toString()},
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final taskCoreRepositoryProvider = Provider<TaskCoreRepository>((ref) {
  return DriftTaskCoreRepository(
    database: ref.watch(appDatabaseProvider),
    idService: ref.watch(idServiceProvider),
    clock: ref.watch(utcClockProvider),
    logger: ref.watch(appLoggerProvider),
  );
});
