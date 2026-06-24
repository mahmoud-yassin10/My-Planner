import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/features/templates/data/bundled_template_definitions.dart';
import 'package:momentum_os/features/templates/data/drift_template_repository.dart';
import 'package:momentum_os/features/templates/domain/template_models.dart';

void main() {
  test('bundled descriptors cover planned template categories safely', () {
    expect(bundledTemplateDefinitions.map((definition) => definition.key), [
      'freelancing_crm',
      'finance',
      'opportunities',
      'learning',
      'competitive_programming',
      'machine_learning',
      'university',
      'fitness',
      'reading',
      'content_creation',
    ]);

    for (final definition in bundledTemplateDefinitions) {
      expect(definition.version, '1.0.0');
      expect(definition.configurationJson, isNot(contains('records":')));
      expect(definition.configurationJson, isNot(contains('exampleRecords')));
      expect(definition.configurationJson, isNot(contains('demoData')));
    }
  });

  test('installing bundled descriptors records metadata only', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);
    final repository = DriftTemplateRepository(
      database: database,
      idService: FixedIdService(['install-1']),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 9)),
      logger: AppLogger(sink: (_) {}),
      definitions: bundledTemplateDefinitions,
    );

    await repository.installTemplate(
      const TemplateInstallRequest(templateKey: 'finance'),
    );

    expect(
      await database.select(database.templateInstallations).get(),
      hasLength(1),
    );
    expect(await database.select(database.spaces).get(), isEmpty);
    expect(await database.select(database.tasks).get(), isEmpty);
    expect(await database.select(database.notes).get(), isEmpty);
  });
}
