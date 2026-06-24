import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/persistence_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/services/id_service.dart';
import '../../../core/services/utc_clock.dart';
import '../domain/planner_models.dart';
import '../domain/planner_repository.dart';

class DriftPlannerRepository implements PlannerRepository {
  const DriftPlannerRepository({
    required AppDatabase database,
    required IdService idService,
    required UtcClock clock,
    required AppLogger logger,
  }) : this._(database, idService, clock, logger);

  const DriftPlannerRepository._(
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
  Future<PlannerSnapshot> current() async {
    try {
      return _snapshot();
    } catch (error, stackTrace) {
      _logFailure('current', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read planner schedule.');
    }
  }

  @override
  Stream<PlannerSnapshot> watchPlanner() async* {
    yield await current();
    yield* _database
        .customSelect(
          'SELECT 1',
          readsFrom: {_database.plannerEvents, _database.timeBlocks},
        )
        .watch()
        .skip(1)
        .asyncMap((_) => current())
        .handleError((Object error, StackTrace stackTrace) {
          _logFailure('watchPlanner', error, stackTrace);
          throw const PersistenceReadFailure('Unable to watch planner data.');
        });
  }

  @override
  Future<PlannerEvent> createEvent(PlannerEventDraft draft) async {
    final cleaned = _validateEventDraft(draft);
    final now = _clock.now();
    final event = PlannerEvent(
      id: _idService.newId(),
      title: cleaned.title,
      description: cleaned.description,
      kind: cleaned.kind,
      startsAt: cleaned.startsAt,
      endsAt: cleaned.endsAt,
      isAllDay: cleaned.isAllDay,
      location: cleaned.location,
      meetingUrl: cleaned.meetingUrl,
      linkedTaskId: cleaned.linkedTaskId,
      recurrenceRule: cleaned.recurrenceRule,
      reminderPolicy: cleaned.reminderPolicy,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.plannerEvents)
          .insert(_eventCompanion(event));
      return event;
    } catch (error, stackTrace) {
      _logFailure('createEvent', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create planner event.');
    }
  }

  @override
  Future<PlannerEvent> updateEvent(String id, PlannerEventDraft draft) async {
    final previous = await _eventById(id);
    final cleaned = _validateEventDraft(draft);
    final event = PlannerEvent(
      id: id,
      title: cleaned.title,
      description: cleaned.description,
      kind: cleaned.kind,
      startsAt: cleaned.startsAt,
      endsAt: cleaned.endsAt,
      isAllDay: cleaned.isAllDay,
      location: cleaned.location,
      meetingUrl: cleaned.meetingUrl,
      linkedTaskId: cleaned.linkedTaskId,
      recurrenceRule: cleaned.recurrenceRule,
      reminderPolicy: cleaned.reminderPolicy,
      createdAt: previous.createdAt,
      updatedAt: _clock.now(),
      archivedAt: previous.archivedAt,
    );

    try {
      await (_database.update(
        _database.plannerEvents,
      )..where((table) => table.id.equals(id))).write(_eventUpdate(event));
      return event;
    } catch (error, stackTrace) {
      _logFailure('updateEvent', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update planner event.');
    }
  }

  @override
  Future<void> archiveEvent(String id) => _setArchive(
    operation: 'archiveEvent',
    tableName: 'planner_events',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreEvent(String id) => _setArchive(
    operation: 'restoreEvent',
    tableName: 'planner_events',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteEvent(String id) => _delete(
    operation: 'deleteEvent',
    tableName: 'planner_events',
    delete: () => (_database.delete(
      _database.plannerEvents,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<TimeBlock> createTimeBlock(TimeBlockDraft draft) async {
    final cleaned = _validateTimeBlockDraft(draft);
    final now = _clock.now();
    final block = TimeBlock(
      id: _idService.newId(),
      title: cleaned.title,
      kind: cleaned.kind,
      startsAt: cleaned.startsAt,
      endsAt: cleaned.endsAt,
      linkedTaskId: cleaned.linkedTaskId,
      notes: cleaned.notes,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.timeBlocks)
          .insert(_timeBlockCompanion(block));
      return block;
    } catch (error, stackTrace) {
      _logFailure('createTimeBlock', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create time block.');
    }
  }

  @override
  Future<TimeBlock> updateTimeBlock(String id, TimeBlockDraft draft) async {
    final previous = await _timeBlockById(id);
    final cleaned = _validateTimeBlockDraft(draft);
    final block = TimeBlock(
      id: id,
      title: cleaned.title,
      kind: cleaned.kind,
      startsAt: cleaned.startsAt,
      endsAt: cleaned.endsAt,
      linkedTaskId: cleaned.linkedTaskId,
      notes: cleaned.notes,
      createdAt: previous.createdAt,
      updatedAt: _clock.now(),
      archivedAt: previous.archivedAt,
    );

    try {
      await (_database.update(
        _database.timeBlocks,
      )..where((table) => table.id.equals(id))).write(_timeBlockUpdate(block));
      return block;
    } catch (error, stackTrace) {
      _logFailure('updateTimeBlock', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update time block.');
    }
  }

  @override
  Future<void> archiveTimeBlock(String id) => _setArchive(
    operation: 'archiveTimeBlock',
    tableName: 'time_blocks',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreTimeBlock(String id) => _setArchive(
    operation: 'restoreTimeBlock',
    tableName: 'time_blocks',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteTimeBlock(String id) => _delete(
    operation: 'deleteTimeBlock',
    tableName: 'time_blocks',
    delete: () => (_database.delete(
      _database.timeBlocks,
    )..where((table) => table.id.equals(id))).go(),
  );

  Future<PlannerSnapshot> _snapshot() async {
    final events =
        await (_database.select(_database.plannerEvents)..orderBy([
              (table) => OrderingTerm.asc(table.startsAt),
              (table) => OrderingTerm.asc(table.title),
            ]))
            .get();
    final blocks =
        await (_database.select(_database.timeBlocks)..orderBy([
              (table) => OrderingTerm.asc(table.startsAt),
              (table) => OrderingTerm.asc(table.title),
            ]))
            .get();

    return PlannerSnapshot(
      events: events.map(_eventFromRow).toList(),
      timeBlocks: blocks.map(_timeBlockFromRow).toList(),
    );
  }

  Future<PlannerEvent> _eventById(String id) async {
    try {
      final row = await (_database.select(
        _database.plannerEvents,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw const PersistenceReadFailure('Planner event was not found.');
      }
      return _eventFromRow(row);
    } catch (error, stackTrace) {
      _logFailure('readEvent', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read planner event.');
    }
  }

  Future<TimeBlock> _timeBlockById(String id) async {
    try {
      final row = await (_database.select(
        _database.timeBlocks,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw const PersistenceReadFailure('Time block was not found.');
      }
      return _timeBlockFromRow(row);
    } catch (error, stackTrace) {
      _logFailure('readTimeBlock', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read time block.');
    }
  }

  PlannerEventDraft _validateEventDraft(PlannerEventDraft draft) {
    final title = _requiredText(draft.title, 'Event title');
    _validateDateRange(draft.startsAt, draft.endsAt);
    return PlannerEventDraft(
      title: title,
      description: _optionalText(draft.description),
      kind: draft.kind,
      startsAt: draft.startsAt.toUtc(),
      endsAt: draft.endsAt.toUtc(),
      isAllDay: draft.isAllDay,
      location: _optionalText(draft.location),
      meetingUrl: _optionalText(draft.meetingUrl),
      linkedTaskId: _optionalText(draft.linkedTaskId),
      recurrenceRule: _optionalText(draft.recurrenceRule),
      reminderPolicy: _optionalText(draft.reminderPolicy),
    );
  }

  TimeBlockDraft _validateTimeBlockDraft(TimeBlockDraft draft) {
    final title = _requiredText(draft.title, 'Time block title');
    _validateDateRange(draft.startsAt, draft.endsAt);
    return TimeBlockDraft(
      title: title,
      kind: draft.kind,
      startsAt: draft.startsAt.toUtc(),
      endsAt: draft.endsAt.toUtc(),
      linkedTaskId: _optionalText(draft.linkedTaskId),
      notes: _optionalText(draft.notes),
    );
  }

  void _validateDateRange(DateTime startsAt, DateTime endsAt) {
    if (!endsAt.isAfter(startsAt)) {
      throw const PersistenceValidationFailure(
        'Schedule end must be after start.',
      );
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
            'planner_events' => _database.plannerEvents,
            'time_blocks' => _database.timeBlocks,
            _ => throw ArgumentError.value(tableName, 'tableName'),
          },
        },
      );
      if (count == 0) {
        throw const PersistenceWriteFailure('Planner record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw const PersistenceWriteFailure(
        'Unable to update planner archive state.',
      );
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
        throw const PersistenceWriteFailure('Planner record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw PersistenceWriteFailure('Unable to delete $tableName record.');
    }
  }

  PlannerEventsCompanion _eventCompanion(PlannerEvent event) {
    return PlannerEventsCompanion.insert(
      id: event.id,
      title: event.title,
      description: Value(event.description),
      kind: event.kind.name,
      startsAt: event.startsAt,
      endsAt: event.endsAt,
      isAllDay: event.isAllDay,
      location: Value(event.location),
      meetingUrl: Value(event.meetingUrl),
      linkedTaskId: Value(event.linkedTaskId),
      recurrenceRule: Value(event.recurrenceRule),
      reminderPolicy: Value(event.reminderPolicy),
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      archivedAt: Value(event.archivedAt),
    );
  }

  PlannerEventsCompanion _eventUpdate(PlannerEvent event) {
    return PlannerEventsCompanion(
      title: Value(event.title),
      description: Value(event.description),
      kind: Value(event.kind.name),
      startsAt: Value(event.startsAt),
      endsAt: Value(event.endsAt),
      isAllDay: Value(event.isAllDay),
      location: Value(event.location),
      meetingUrl: Value(event.meetingUrl),
      linkedTaskId: Value(event.linkedTaskId),
      recurrenceRule: Value(event.recurrenceRule),
      reminderPolicy: Value(event.reminderPolicy),
      updatedAt: Value(event.updatedAt),
      archivedAt: Value(event.archivedAt),
    );
  }

  TimeBlocksCompanion _timeBlockCompanion(TimeBlock block) {
    return TimeBlocksCompanion.insert(
      id: block.id,
      title: block.title,
      kind: block.kind.name,
      startsAt: block.startsAt,
      endsAt: block.endsAt,
      linkedTaskId: Value(block.linkedTaskId),
      notes: Value(block.notes),
      createdAt: block.createdAt,
      updatedAt: block.updatedAt,
      archivedAt: Value(block.archivedAt),
    );
  }

  TimeBlocksCompanion _timeBlockUpdate(TimeBlock block) {
    return TimeBlocksCompanion(
      title: Value(block.title),
      kind: Value(block.kind.name),
      startsAt: Value(block.startsAt),
      endsAt: Value(block.endsAt),
      linkedTaskId: Value(block.linkedTaskId),
      notes: Value(block.notes),
      updatedAt: Value(block.updatedAt),
      archivedAt: Value(block.archivedAt),
    );
  }

  PlannerEvent _eventFromRow(PlannerEventRow row) {
    return PlannerEvent(
      id: row.id,
      title: row.title,
      description: row.description,
      kind: _enumValue(
        PlannerEventKind.values,
        row.kind,
        PlannerEventKind.event,
      ),
      startsAt: row.startsAt,
      endsAt: row.endsAt,
      isAllDay: row.isAllDay,
      location: row.location,
      meetingUrl: row.meetingUrl,
      linkedTaskId: row.linkedTaskId,
      recurrenceRule: row.recurrenceRule,
      reminderPolicy: row.reminderPolicy,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  TimeBlock _timeBlockFromRow(TimeBlockRow row) {
    return TimeBlock(
      id: row.id,
      title: row.title,
      kind: _enumValue(TimeBlockKind.values, row.kind, TimeBlockKind.focus),
      startsAt: row.startsAt,
      endsAt: row.endsAt,
      linkedTaskId: row.linkedTaskId,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

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
      'plannerRepository',
      operation,
      'Planner repository operation failed.',
      metadata: {'errorType': error.runtimeType.toString()},
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return DriftPlannerRepository(
    database: ref.watch(appDatabaseProvider),
    idService: ref.watch(idServiceProvider),
    clock: ref.watch(utcClockProvider),
    logger: ref.watch(appLoggerProvider),
  );
});
