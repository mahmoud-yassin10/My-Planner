import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/persistence_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/services/id_service.dart';
import '../../../core/services/utc_clock.dart';
import '../domain/hierarchy_models.dart';
import '../domain/hierarchy_repository.dart';

class DriftHierarchyRepository implements HierarchyRepository {
  const DriftHierarchyRepository({
    required AppDatabase database,
    required IdService idService,
    required UtcClock clock,
    required AppLogger logger,
  }) : this._(database, idService, clock, logger);

  const DriftHierarchyRepository._(
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
  Future<HierarchySnapshot> current() async {
    try {
      return _snapshot();
    } catch (error, stackTrace) {
      _logFailure('current', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read hierarchy data.');
    }
  }

  @override
  Stream<HierarchySnapshot> watchHierarchy() async* {
    yield await current();

    yield* _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.areas,
            _database.goals,
            _database.projects,
            _database.milestones,
          },
        )
        .watch()
        .skip(1)
        .asyncMap((_) => current())
        .handleError((Object error, StackTrace stackTrace) {
          _logFailure('watchHierarchy', error, stackTrace);
          throw const PersistenceReadFailure('Unable to watch hierarchy data.');
        });
  }

  @override
  Future<Area> createArea(AreaDraft draft) async {
    final cleaned = _validateAreaDraft(draft);
    final now = _clock.now();
    final area = Area(
      id: _idService.newId(),
      name: cleaned.name,
      description: cleaned.description,
      iconKey: cleaned.iconKey,
      colorValue: cleaned.colorValue,
      status: cleaned.status,
      sortOrder: cleaned.sortOrder,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database.into(_database.areas).insert(_areaCompanion(area));
      return area;
    } catch (error, stackTrace) {
      _logFailure('createArea', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create area.');
    }
  }

  @override
  Future<Area> updateArea(String id, AreaDraft draft) async {
    final cleaned = _validateAreaDraft(draft);
    final previous = await _areaById(id);
    final area = Area(
      id: id,
      name: cleaned.name,
      description: cleaned.description,
      iconKey: cleaned.iconKey,
      colorValue: cleaned.colorValue,
      status: cleaned.status,
      sortOrder: cleaned.sortOrder,
      createdAt: previous.createdAt,
      updatedAt: _clock.now(),
      archivedAt: previous.archivedAt,
    );

    try {
      await (_database.update(
        _database.areas,
      )..where((table) => table.id.equals(id))).write(_areaUpdate(area));
      return area;
    } catch (error, stackTrace) {
      _logFailure('updateArea', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update area.');
    }
  }

  @override
  Future<void> archiveArea(String id) => _setArchive(
    operation: 'archiveArea',
    tableName: 'areas',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreArea(String id) => _setArchive(
    operation: 'restoreArea',
    tableName: 'areas',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteArea(String id) {
    return _delete(
      operation: 'deleteArea',
      tableName: 'areas',
      delete: () => (_database.delete(
        _database.areas,
      )..where((table) => table.id.equals(id))).go(),
    );
  }

  @override
  Future<Goal> createGoal(GoalDraft draft) async {
    final cleaned = await _validateGoalDraft(draft);
    final now = _clock.now();
    final goal = Goal(
      id: _idService.newId(),
      title: cleaned.title,
      description: cleaned.description,
      areaId: cleaned.areaId,
      parentGoalId: cleaned.parentGoalId,
      goalType: cleaned.goalType,
      timeHorizon: cleaned.timeHorizon,
      measurementType: cleaned.measurementType,
      targetValue: cleaned.targetValue,
      currentValue: cleaned.currentValue,
      unit: cleaned.unit,
      startAt: _utcOrNull(cleaned.startAt),
      deadlineAt: _utcOrNull(cleaned.deadlineAt),
      priority: cleaned.priority,
      status: cleaned.status,
      motivation: cleaned.motivation,
      reviewFrequency: cleaned.reviewFrequency,
      lastReviewAt: _utcOrNull(cleaned.lastReviewAt),
      nextReviewAt: _utcOrNull(cleaned.nextReviewAt),
      notes: cleaned.notes,
      customFieldsJson: cleaned.customFieldsJson,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database.into(_database.goals).insert(_goalCompanion(goal));
      return goal;
    } catch (error, stackTrace) {
      _logFailure('createGoal', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create goal.');
    }
  }

  @override
  Future<Goal> updateGoal(String id, GoalDraft draft) async {
    final previous = await _goalById(id);
    final cleaned = await _validateGoalDraft(draft, existingGoalId: id);
    final goal = Goal(
      id: id,
      title: cleaned.title,
      description: cleaned.description,
      areaId: cleaned.areaId,
      parentGoalId: cleaned.parentGoalId,
      goalType: cleaned.goalType,
      timeHorizon: cleaned.timeHorizon,
      measurementType: cleaned.measurementType,
      targetValue: cleaned.targetValue,
      currentValue: cleaned.currentValue,
      unit: cleaned.unit,
      startAt: _utcOrNull(cleaned.startAt),
      deadlineAt: _utcOrNull(cleaned.deadlineAt),
      priority: cleaned.priority,
      status: cleaned.status,
      motivation: cleaned.motivation,
      reviewFrequency: cleaned.reviewFrequency,
      lastReviewAt: _utcOrNull(cleaned.lastReviewAt),
      nextReviewAt: _utcOrNull(cleaned.nextReviewAt),
      notes: cleaned.notes,
      customFieldsJson: cleaned.customFieldsJson,
      createdAt: previous.createdAt,
      updatedAt: _clock.now(),
      archivedAt: previous.archivedAt,
    );

    try {
      await (_database.update(
        _database.goals,
      )..where((table) => table.id.equals(id))).write(_goalUpdate(goal));
      return goal;
    } catch (error, stackTrace) {
      _logFailure('updateGoal', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update goal.');
    }
  }

  @override
  Future<void> archiveGoal(String id) => _setArchive(
    operation: 'archiveGoal',
    tableName: 'goals',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreGoal(String id) => _setArchive(
    operation: 'restoreGoal',
    tableName: 'goals',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteGoal(String id) {
    return _delete(
      operation: 'deleteGoal',
      tableName: 'goals',
      delete: () => (_database.delete(
        _database.goals,
      )..where((table) => table.id.equals(id))).go(),
    );
  }

  @override
  Future<Project> createProject(ProjectDraft draft) async {
    final cleaned = _validateProjectDraft(draft);
    final now = _clock.now();
    final project = Project(
      id: _idService.newId(),
      title: cleaned.title,
      description: cleaned.description,
      areaId: cleaned.areaId,
      goalId: cleaned.goalId,
      status: cleaned.status,
      startAt: _utcOrNull(cleaned.startAt),
      deadlineAt: _utcOrNull(cleaned.deadlineAt),
      progress: cleaned.progress,
      notes: cleaned.notes,
      customFieldsJson: cleaned.customFieldsJson,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.projects)
          .insert(_projectCompanion(project));
      return project;
    } catch (error, stackTrace) {
      _logFailure('createProject', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create project.');
    }
  }

  @override
  Future<Project> updateProject(String id, ProjectDraft draft) async {
    final previous = await _projectById(id);
    final cleaned = _validateProjectDraft(draft);
    final project = Project(
      id: id,
      title: cleaned.title,
      description: cleaned.description,
      areaId: cleaned.areaId,
      goalId: cleaned.goalId,
      status: cleaned.status,
      startAt: _utcOrNull(cleaned.startAt),
      deadlineAt: _utcOrNull(cleaned.deadlineAt),
      progress: cleaned.progress,
      notes: cleaned.notes,
      customFieldsJson: cleaned.customFieldsJson,
      createdAt: previous.createdAt,
      updatedAt: _clock.now(),
      archivedAt: previous.archivedAt,
    );

    try {
      await (_database.update(
        _database.projects,
      )..where((table) => table.id.equals(id))).write(_projectUpdate(project));
      return project;
    } catch (error, stackTrace) {
      _logFailure('updateProject', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update project.');
    }
  }

  @override
  Future<void> archiveProject(String id) => _setArchive(
    operation: 'archiveProject',
    tableName: 'projects',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreProject(String id) => _setArchive(
    operation: 'restoreProject',
    tableName: 'projects',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteProject(String id) {
    return _delete(
      operation: 'deleteProject',
      tableName: 'projects',
      delete: () => (_database.delete(
        _database.projects,
      )..where((table) => table.id.equals(id))).go(),
    );
  }

  @override
  Future<Milestone> createMilestone(MilestoneDraft draft) async {
    final cleaned = _validateMilestoneDraft(draft);
    final now = _clock.now();
    final milestone = Milestone(
      id: _idService.newId(),
      title: cleaned.title,
      description: cleaned.description,
      goalId: cleaned.goalId,
      projectId: cleaned.projectId,
      dueAt: _utcOrNull(cleaned.dueAt),
      status: cleaned.status,
      completedAt: _utcOrNull(cleaned.completedAt),
      sortOrder: cleaned.sortOrder,
      notes: cleaned.notes,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.milestones)
          .insert(_milestoneCompanion(milestone));
      return milestone;
    } catch (error, stackTrace) {
      _logFailure('createMilestone', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create milestone.');
    }
  }

  @override
  Future<Milestone> updateMilestone(String id, MilestoneDraft draft) async {
    final previous = await _milestoneById(id);
    final cleaned = _validateMilestoneDraft(draft);
    final milestone = Milestone(
      id: id,
      title: cleaned.title,
      description: cleaned.description,
      goalId: cleaned.goalId,
      projectId: cleaned.projectId,
      dueAt: _utcOrNull(cleaned.dueAt),
      status: cleaned.status,
      completedAt: _utcOrNull(cleaned.completedAt),
      sortOrder: cleaned.sortOrder,
      notes: cleaned.notes,
      createdAt: previous.createdAt,
      updatedAt: _clock.now(),
      archivedAt: previous.archivedAt,
    );

    try {
      await (_database.update(_database.milestones)
            ..where((table) => table.id.equals(id)))
          .write(_milestoneUpdate(milestone));
      return milestone;
    } catch (error, stackTrace) {
      _logFailure('updateMilestone', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update milestone.');
    }
  }

  @override
  Future<void> archiveMilestone(String id) => _setArchive(
    operation: 'archiveMilestone',
    tableName: 'milestones',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreMilestone(String id) => _setArchive(
    operation: 'restoreMilestone',
    tableName: 'milestones',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteMilestone(String id) {
    return _delete(
      operation: 'deleteMilestone',
      tableName: 'milestones',
      delete: () => (_database.delete(
        _database.milestones,
      )..where((table) => table.id.equals(id))).go(),
    );
  }

  Future<HierarchySnapshot> _snapshot() async {
    final rows = await Future.wait([
      (_database.select(_database.areas)..orderBy([
            (table) => OrderingTerm.asc(table.sortOrder),
            (table) => OrderingTerm.asc(table.name),
          ]))
          .get(),
      (_database.select(
        _database.goals,
      )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get(),
      (_database.select(
        _database.projects,
      )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get(),
      (_database.select(_database.milestones)..orderBy([
            (table) => OrderingTerm.asc(table.sortOrder),
            (table) => OrderingTerm.asc(table.createdAt),
          ]))
          .get(),
    ]);

    return HierarchySnapshot(
      areas: (rows[0] as List<AreaRow>).map(_areaFromRow).toList(),
      goals: (rows[1] as List<GoalRow>).map(_goalFromRow).toList(),
      projects: (rows[2] as List<ProjectRow>).map(_projectFromRow).toList(),
      milestones: (rows[3] as List<MilestoneRow>)
          .map(_milestoneFromRow)
          .toList(),
    );
  }

  Future<Area> _areaById(String id) async {
    try {
      final row = await (_database.select(
        _database.areas,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw const PersistenceReadFailure('Area was not found.');
      }
      return _areaFromRow(row);
    } catch (error, stackTrace) {
      _logFailure('readArea', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read area.');
    }
  }

  Future<Goal> _goalById(String id) async {
    try {
      final row = await (_database.select(
        _database.goals,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw const PersistenceReadFailure('Goal was not found.');
      }
      return _goalFromRow(row);
    } catch (error, stackTrace) {
      _logFailure('readGoal', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read goal.');
    }
  }

  Future<Project> _projectById(String id) async {
    try {
      final row = await (_database.select(
        _database.projects,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw const PersistenceReadFailure('Project was not found.');
      }
      return _projectFromRow(row);
    } catch (error, stackTrace) {
      _logFailure('readProject', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read project.');
    }
  }

  Future<Milestone> _milestoneById(String id) async {
    try {
      final row = await (_database.select(
        _database.milestones,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        throw const PersistenceReadFailure('Milestone was not found.');
      }
      return _milestoneFromRow(row);
    } catch (error, stackTrace) {
      _logFailure('readMilestone', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read milestone.');
    }
  }

  AreaDraft _validateAreaDraft(AreaDraft draft) {
    final name = _requiredText(draft.name, 'Area name');
    return AreaDraft(
      name: name,
      description: _optionalText(draft.description),
      iconKey: _optionalText(draft.iconKey),
      colorValue: draft.colorValue,
      status: draft.status,
      sortOrder: draft.sortOrder,
    );
  }

  Future<GoalDraft> _validateGoalDraft(
    GoalDraft draft, {
    String? existingGoalId,
  }) async {
    final title = _requiredText(draft.title, 'Goal title');
    if (draft.parentGoalId != null && draft.parentGoalId == existingGoalId) {
      throw const PersistenceValidationFailure(
        'A goal cannot be its own parent.',
      );
    }
    if (existingGoalId != null && draft.parentGoalId != null) {
      await _validateGoalParentDoesNotCreateCycle(
        existingGoalId,
        draft.parentGoalId!,
      );
    }
    _validateDateRange(draft.startAt, draft.deadlineAt);
    _validateNonNegative(draft.targetValue, 'targetValue');
    _validateNonNegative(draft.currentValue, 'currentValue');

    return GoalDraft(
      title: title,
      description: _optionalText(draft.description),
      areaId: _optionalText(draft.areaId),
      parentGoalId: _optionalText(draft.parentGoalId),
      goalType: _optionalText(draft.goalType),
      timeHorizon: _optionalText(draft.timeHorizon),
      measurementType: _optionalText(draft.measurementType),
      targetValue: draft.targetValue,
      currentValue: draft.currentValue,
      unit: _optionalText(draft.unit),
      startAt: _utcOrNull(draft.startAt),
      deadlineAt: _utcOrNull(draft.deadlineAt),
      priority: draft.priority,
      status: draft.status,
      motivation: _optionalText(draft.motivation),
      reviewFrequency: _optionalText(draft.reviewFrequency),
      lastReviewAt: _utcOrNull(draft.lastReviewAt),
      nextReviewAt: _utcOrNull(draft.nextReviewAt),
      notes: _optionalText(draft.notes),
      customFieldsJson: _optionalText(draft.customFieldsJson),
    );
  }

  ProjectDraft _validateProjectDraft(ProjectDraft draft) {
    final title = _requiredText(draft.title, 'Project title');
    _validateDateRange(draft.startAt, draft.deadlineAt);
    if (draft.progress != null &&
        (draft.progress! < 0 || draft.progress! > 1)) {
      throw const PersistenceValidationFailure(
        'Project progress must be between 0 and 1.',
      );
    }

    return ProjectDraft(
      title: title,
      description: _optionalText(draft.description),
      areaId: _optionalText(draft.areaId),
      goalId: _optionalText(draft.goalId),
      status: draft.status,
      startAt: _utcOrNull(draft.startAt),
      deadlineAt: _utcOrNull(draft.deadlineAt),
      progress: draft.progress,
      notes: _optionalText(draft.notes),
      customFieldsJson: _optionalText(draft.customFieldsJson),
    );
  }

  MilestoneDraft _validateMilestoneDraft(MilestoneDraft draft) {
    final title = _requiredText(draft.title, 'Milestone title');
    final hasGoal = _optionalText(draft.goalId) != null;
    final hasProject = _optionalText(draft.projectId) != null;
    if (hasGoal == hasProject) {
      throw const PersistenceValidationFailure(
        'A milestone must belong to exactly one goal or project.',
      );
    }

    return MilestoneDraft(
      title: title,
      description: _optionalText(draft.description),
      goalId: _optionalText(draft.goalId),
      projectId: _optionalText(draft.projectId),
      dueAt: _utcOrNull(draft.dueAt),
      status: draft.status,
      completedAt: _utcOrNull(draft.completedAt),
      sortOrder: draft.sortOrder,
      notes: _optionalText(draft.notes),
    );
  }

  Future<void> _validateGoalParentDoesNotCreateCycle(
    String goalId,
    String parentGoalId,
  ) async {
    var currentParentId = parentGoalId;
    while (true) {
      if (currentParentId == goalId) {
        throw const PersistenceValidationFailure(
          'Goal hierarchy cannot contain cycles.',
        );
      }

      final parent = await (_database.select(
        _database.goals,
      )..where((table) => table.id.equals(currentParentId))).getSingleOrNull();
      if (parent?.parentGoalId == null) {
        return;
      }
      currentParentId = parent!.parentGoalId!;
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
            'areas' => _database.areas,
            'goals' => _database.goals,
            'projects' => _database.projects,
            'milestones' => _database.milestones,
            _ => throw ArgumentError.value(tableName, 'tableName'),
          },
        },
      );
      if (count == 0) {
        throw const PersistenceWriteFailure('Hierarchy record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw const PersistenceWriteFailure(
        'Unable to update archive state for hierarchy record.',
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
        throw const PersistenceWriteFailure('Hierarchy record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw PersistenceWriteFailure('Unable to delete $tableName record.');
    }
  }

  AreasCompanion _areaCompanion(Area area) {
    return AreasCompanion.insert(
      id: area.id,
      name: area.name,
      description: Value(area.description),
      iconKey: Value(area.iconKey),
      colorValue: Value(area.colorValue),
      status: area.status.name,
      sortOrder: area.sortOrder,
      createdAt: area.createdAt,
      updatedAt: area.updatedAt,
      archivedAt: Value(area.archivedAt),
    );
  }

  AreasCompanion _areaUpdate(Area area) {
    return AreasCompanion(
      name: Value(area.name),
      description: Value(area.description),
      iconKey: Value(area.iconKey),
      colorValue: Value(area.colorValue),
      status: Value(area.status.name),
      sortOrder: Value(area.sortOrder),
      updatedAt: Value(area.updatedAt),
      archivedAt: Value(area.archivedAt),
    );
  }

  GoalsCompanion _goalCompanion(Goal goal) {
    return GoalsCompanion.insert(
      id: goal.id,
      title: goal.title,
      description: Value(goal.description),
      areaId: Value(goal.areaId),
      parentGoalId: Value(goal.parentGoalId),
      goalType: Value(goal.goalType),
      timeHorizon: Value(goal.timeHorizon),
      measurementType: Value(goal.measurementType),
      targetValue: Value(goal.targetValue),
      currentValue: Value(goal.currentValue),
      unit: Value(goal.unit),
      startAt: Value(goal.startAt),
      deadlineAt: Value(goal.deadlineAt),
      priority: Value(goal.priority),
      status: goal.status.name,
      motivation: Value(goal.motivation),
      reviewFrequency: Value(goal.reviewFrequency),
      lastReviewAt: Value(goal.lastReviewAt),
      nextReviewAt: Value(goal.nextReviewAt),
      notes: Value(goal.notes),
      customFieldsJson: Value(goal.customFieldsJson),
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
      archivedAt: Value(goal.archivedAt),
    );
  }

  GoalsCompanion _goalUpdate(Goal goal) {
    return GoalsCompanion(
      title: Value(goal.title),
      description: Value(goal.description),
      areaId: Value(goal.areaId),
      parentGoalId: Value(goal.parentGoalId),
      goalType: Value(goal.goalType),
      timeHorizon: Value(goal.timeHorizon),
      measurementType: Value(goal.measurementType),
      targetValue: Value(goal.targetValue),
      currentValue: Value(goal.currentValue),
      unit: Value(goal.unit),
      startAt: Value(goal.startAt),
      deadlineAt: Value(goal.deadlineAt),
      priority: Value(goal.priority),
      status: Value(goal.status.name),
      motivation: Value(goal.motivation),
      reviewFrequency: Value(goal.reviewFrequency),
      lastReviewAt: Value(goal.lastReviewAt),
      nextReviewAt: Value(goal.nextReviewAt),
      notes: Value(goal.notes),
      customFieldsJson: Value(goal.customFieldsJson),
      updatedAt: Value(goal.updatedAt),
      archivedAt: Value(goal.archivedAt),
    );
  }

  ProjectsCompanion _projectCompanion(Project project) {
    return ProjectsCompanion.insert(
      id: project.id,
      title: project.title,
      description: Value(project.description),
      areaId: Value(project.areaId),
      goalId: Value(project.goalId),
      status: project.status.name,
      startAt: Value(project.startAt),
      deadlineAt: Value(project.deadlineAt),
      progress: Value(project.progress),
      notes: Value(project.notes),
      customFieldsJson: Value(project.customFieldsJson),
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      archivedAt: Value(project.archivedAt),
    );
  }

  ProjectsCompanion _projectUpdate(Project project) {
    return ProjectsCompanion(
      title: Value(project.title),
      description: Value(project.description),
      areaId: Value(project.areaId),
      goalId: Value(project.goalId),
      status: Value(project.status.name),
      startAt: Value(project.startAt),
      deadlineAt: Value(project.deadlineAt),
      progress: Value(project.progress),
      notes: Value(project.notes),
      customFieldsJson: Value(project.customFieldsJson),
      updatedAt: Value(project.updatedAt),
      archivedAt: Value(project.archivedAt),
    );
  }

  MilestonesCompanion _milestoneCompanion(Milestone milestone) {
    return MilestonesCompanion.insert(
      id: milestone.id,
      title: milestone.title,
      description: Value(milestone.description),
      goalId: Value(milestone.goalId),
      projectId: Value(milestone.projectId),
      dueAt: Value(milestone.dueAt),
      status: milestone.status.name,
      completedAt: Value(milestone.completedAt),
      sortOrder: milestone.sortOrder,
      notes: Value(milestone.notes),
      createdAt: milestone.createdAt,
      updatedAt: milestone.updatedAt,
      archivedAt: Value(milestone.archivedAt),
    );
  }

  MilestonesCompanion _milestoneUpdate(Milestone milestone) {
    return MilestonesCompanion(
      title: Value(milestone.title),
      description: Value(milestone.description),
      goalId: Value(milestone.goalId),
      projectId: Value(milestone.projectId),
      dueAt: Value(milestone.dueAt),
      status: Value(milestone.status.name),
      completedAt: Value(milestone.completedAt),
      sortOrder: Value(milestone.sortOrder),
      notes: Value(milestone.notes),
      updatedAt: Value(milestone.updatedAt),
      archivedAt: Value(milestone.archivedAt),
    );
  }

  Area _areaFromRow(AreaRow row) {
    return Area(
      id: row.id,
      name: row.name,
      description: row.description,
      iconKey: row.iconKey,
      colorValue: row.colorValue,
      status: _enumValue(AreaStatus.values, row.status, AreaStatus.active),
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  Goal _goalFromRow(GoalRow row) {
    return Goal(
      id: row.id,
      title: row.title,
      description: row.description,
      areaId: row.areaId,
      parentGoalId: row.parentGoalId,
      goalType: row.goalType,
      timeHorizon: row.timeHorizon,
      measurementType: row.measurementType,
      targetValue: row.targetValue,
      currentValue: row.currentValue,
      unit: row.unit,
      startAt: row.startAt,
      deadlineAt: row.deadlineAt,
      priority: row.priority,
      status: _enumValue(GoalStatus.values, row.status, GoalStatus.active),
      motivation: row.motivation,
      reviewFrequency: row.reviewFrequency,
      lastReviewAt: row.lastReviewAt,
      nextReviewAt: row.nextReviewAt,
      notes: row.notes,
      customFieldsJson: row.customFieldsJson,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  Project _projectFromRow(ProjectRow row) {
    return Project(
      id: row.id,
      title: row.title,
      description: row.description,
      areaId: row.areaId,
      goalId: row.goalId,
      status: _enumValue(
        ProjectStatus.values,
        row.status,
        ProjectStatus.planned,
      ),
      startAt: row.startAt,
      deadlineAt: row.deadlineAt,
      progress: row.progress,
      notes: row.notes,
      customFieldsJson: row.customFieldsJson,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  Milestone _milestoneFromRow(MilestoneRow row) {
    return Milestone(
      id: row.id,
      title: row.title,
      description: row.description,
      goalId: row.goalId,
      projectId: row.projectId,
      dueAt: row.dueAt,
      status: _enumValue(
        MilestoneStatus.values,
        row.status,
        MilestoneStatus.planned,
      ),
      completedAt: row.completedAt,
      sortOrder: row.sortOrder,
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

  DateTime? _utcOrNull(DateTime? value) => value?.toUtc();

  void _validateDateRange(DateTime? startAt, DateTime? deadlineAt) {
    if (startAt != null && deadlineAt != null && deadlineAt.isBefore(startAt)) {
      throw const PersistenceValidationFailure(
        'Deadline must not be before start.',
      );
    }
  }

  void _validateNonNegative(double? value, String label) {
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
      'hierarchyRepository',
      operation,
      'Hierarchy repository operation failed.',
      metadata: {'errorType': error.runtimeType.toString()},
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final hierarchyRepositoryProvider = Provider<HierarchyRepository>((ref) {
  return DriftHierarchyRepository(
    database: ref.watch(appDatabaseProvider),
    idService: ref.watch(idServiceProvider),
    clock: ref.watch(utcClockProvider),
    logger: ref.watch(appLoggerProvider),
  );
});
