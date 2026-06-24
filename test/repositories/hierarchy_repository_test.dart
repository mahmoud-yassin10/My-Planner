import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/errors/persistence_failure.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/features/goals/data/drift_hierarchy_repository.dart';
import 'package:momentum_os/features/goals/domain/hierarchy_models.dart';

void main() {
  late AppDatabase database;
  late List<AppLogRecord> records;
  late DriftHierarchyRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    records = <AppLogRecord>[];
    repository = DriftHierarchyRepository(
      database: database,
      idService: FixedIdService([
        'area-1',
        'goal-1',
        'project-1',
        'milestone-1',
        'goal-2',
      ]),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 8)),
      logger: AppLogger(sink: records.add),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'creates areas, goals, projects, and milestones with stable IDs',
    () async {
      final area = await repository.createArea(const AreaDraft(name: 'Area'));
      final goal = await repository.createGoal(
        GoalDraft(title: 'Goal', areaId: area.id),
      );
      final project = await repository.createProject(
        ProjectDraft(title: 'Project', areaId: area.id, goalId: goal.id),
      );
      final milestone = await repository.createMilestone(
        MilestoneDraft(title: 'Milestone', projectId: project.id),
      );

      final snapshot = await repository.current();

      expect(area.id, 'area-1');
      expect(goal.id, 'goal-1');
      expect(project.id, 'project-1');
      expect(milestone.id, 'milestone-1');
      expect(snapshot.areas.single.name, 'Area');
      expect(snapshot.goals.single.areaId, area.id);
      expect(snapshot.projects.single.goalId, goal.id);
      expect(snapshot.milestones.single.projectId, project.id);
      expect(snapshot.areas.single.createdAt.isUtc, isTrue);
    },
  );

  test('watches hierarchy updates', () async {
    final values = <HierarchySnapshot>[];
    final subscription = repository.watchHierarchy().listen(values.add);
    addTearDown(subscription.cancel);

    await Future<void>.delayed(Duration.zero);
    await repository.createArea(const AreaDraft(name: 'Area'));
    await Future<void>.delayed(Duration.zero);

    expect(values.first.isEmpty, isTrue);
    expect(values.last.areas.single.name, 'Area');
  });

  test('archives, restores, and deletes records explicitly', () async {
    final area = await repository.createArea(const AreaDraft(name: 'Area'));

    await repository.archiveArea(area.id);
    expect((await repository.current()).areas.single.isArchived, isTrue);

    await repository.restoreArea(area.id);
    expect((await repository.current()).areas.single.isArchived, isFalse);

    await repository.deleteArea(area.id);
    expect((await repository.current()).areas, isEmpty);
  });

  test('rejects milestones without exactly one owner', () async {
    await expectLater(
      repository.createMilestone(const MilestoneDraft(title: 'Milestone')),
      throwsA(isA<PersistenceValidationFailure>()),
    );
  });

  test('rejects goal hierarchy cycles', () async {
    final parent = await repository.createGoal(
      const GoalDraft(title: 'Parent'),
    );
    final child = await repository.createGoal(
      GoalDraft(title: 'Child', parentGoalId: parent.id),
    );

    await expectLater(
      repository.updateGoal(
        parent.id,
        GoalDraft(title: 'Parent', parentGoalId: child.id),
      ),
      throwsA(isA<PersistenceValidationFailure>()),
    );
  });

  test('translates foreign key failures at the repository boundary', () async {
    await expectLater(
      repository.createGoal(
        const GoalDraft(title: 'Goal', areaId: 'missing-area'),
      ),
      throwsA(isA<PersistenceWriteFailure>()),
    );

    expect(records.single.operation, 'createGoal');
    expect(records.single.metadata['errorType'], isNotNull);
    expect(records.single.error, isNotNull);
    expect(records.single.stackTrace, isNotNull);
  });
}
