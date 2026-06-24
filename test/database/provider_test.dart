import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/preferences/drift_settings_repository.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/features/goals/data/drift_hierarchy_repository.dart';
import 'package:momentum_os/features/goals/domain/hierarchy_repository.dart';
import 'package:momentum_os/features/planner/data/drift_planner_repository.dart';
import 'package:momentum_os/features/planner/domain/planner_repository.dart';
import 'package:momentum_os/features/spaces/data/drift_spaces_repository.dart';
import 'package:momentum_os/features/spaces/domain/spaces_repository.dart';
import 'package:momentum_os/features/templates/data/drift_template_repository.dart';
import 'package:momentum_os/features/templates/domain/template_repository.dart';
import 'package:momentum_os/features/tasks/data/drift_task_core_repository.dart';
import 'package:momentum_os/features/tasks/domain/task_core_repository.dart';
import 'package:momentum_os/shared/repositories/settings_repository.dart';

void main() {
  test('settings repository provider exposes the interface boundary', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        utcClockProvider.overrideWithValue(
          FixedUtcClock(DateTime.utc(2026, 6, 24)),
        ),
        appLoggerProvider.overrideWithValue(AppLogger(sink: (_) {})),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(settingsRepositoryProvider);

    expect(repository, isA<SettingsRepository>());
    expect(repository, isA<DriftSettingsRepository>());
    expect(await repository.current(), AppSettingsPreferences.defaults);
  });

  test(
    'hierarchy repository provider exposes the interface boundary',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          idServiceProvider.overrideWithValue(FixedIdService(['area-1'])),
          utcClockProvider.overrideWithValue(
            FixedUtcClock(DateTime.utc(2026, 6, 24)),
          ),
          appLoggerProvider.overrideWithValue(AppLogger(sink: (_) {})),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(hierarchyRepositoryProvider);

      expect(repository, isA<HierarchyRepository>());
      expect(repository, isA<DriftHierarchyRepository>());
      expect((await repository.current()).isEmpty, isTrue);
    },
  );

  test(
    'task core repository provider exposes the interface boundary',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          idServiceProvider.overrideWithValue(FixedIdService(['task-1'])),
          utcClockProvider.overrideWithValue(
            FixedUtcClock(DateTime.utc(2026, 6, 24)),
          ),
          appLoggerProvider.overrideWithValue(AppLogger(sink: (_) {})),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(taskCoreRepositoryProvider);

      expect(repository, isA<TaskCoreRepository>());
      expect(repository, isA<DriftTaskCoreRepository>());
      expect((await repository.current()).isEmpty, isTrue);
    },
  );

  test('planner repository provider exposes the interface boundary', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        idServiceProvider.overrideWithValue(FixedIdService(['event-1'])),
        utcClockProvider.overrideWithValue(
          FixedUtcClock(DateTime.utc(2026, 6, 24)),
        ),
        appLoggerProvider.overrideWithValue(AppLogger(sink: (_) {})),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(plannerRepositoryProvider);

    expect(repository, isA<PlannerRepository>());
    expect(repository, isA<DriftPlannerRepository>());
    expect((await repository.current()).isEmpty, isTrue);
  });

  test('spaces repository provider exposes the interface boundary', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        idServiceProvider.overrideWithValue(FixedIdService(['space-1'])),
        utcClockProvider.overrideWithValue(
          FixedUtcClock(DateTime.utc(2026, 6, 24)),
        ),
        appLoggerProvider.overrideWithValue(AppLogger(sink: (_) {})),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(spacesRepositoryProvider);

    expect(repository, isA<SpacesRepository>());
    expect(repository, isA<DriftSpacesRepository>());
    expect((await repository.current()).isEmpty, isTrue);
  });

  test('template repository provider exposes the interface boundary', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        idServiceProvider.overrideWithValue(FixedIdService(['template-1'])),
        utcClockProvider.overrideWithValue(
          FixedUtcClock(DateTime.utc(2026, 6, 24)),
        ),
        appLoggerProvider.overrideWithValue(AppLogger(sink: (_) {})),
      ],
    );
    addTearDown(container.dispose);

    final repository = container.read(templateRepositoryProvider);

    expect(repository, isA<TemplateRepository>());
    expect(repository, isA<DriftTemplateRepository>());
    final snapshot = await repository.current();
    expect(snapshot.definitions, isNotEmpty);
    expect(snapshot.installations, isEmpty);
  });
}
