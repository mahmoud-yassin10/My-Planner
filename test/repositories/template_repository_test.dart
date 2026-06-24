import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/errors/persistence_failure.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/features/templates/data/drift_template_repository.dart';
import 'package:momentum_os/features/templates/domain/template_models.dart';

void main() {
  late AppDatabase database;
  late List<AppLogRecord> records;
  late DriftTemplateRepository repository;

  const definition = TemplateDefinition(
    key: 'generic_template',
    name: 'Generic template',
    description: 'Reusable configuration descriptor.',
    version: '1.0.0',
    configurationJson: '{"spaces":[]}',
  );

  setUp(() {
    database = AppDatabase.inMemory();
    records = <AppLogRecord>[];
    repository = DriftTemplateRepository(
      database: database,
      idService: FixedIdService(['template-installation-1']),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 9)),
      logger: AppLogger(sink: records.add),
      definitions: const [definition],
    );
  });

  tearDown(() => database.close());

  test('lists definitions and supports zero installed templates', () async {
    final snapshot = await repository.current();

    expect(snapshot.definitions.single.key, 'generic_template');
    expect(snapshot.installations, isEmpty);
    expect(snapshot.isInstalled('generic_template'), isFalse);
  });

  test('installs template metadata without creating records', () async {
    final installation = await repository.installTemplate(
      const TemplateInstallRequest(templateKey: 'generic_template'),
    );

    final snapshot = await repository.current();
    final areaRows = await database.select(database.areas).get();
    final spaceRows = await database.select(database.spaces).get();

    expect(installation.id, 'template-installation-1');
    expect(installation.templateVersion, '1.0.0');
    expect(installation.status, TemplateInstallationStatus.installed);
    expect(snapshot.isInstalled('generic_template'), isTrue);
    expect(areaRows, isEmpty);
    expect(spaceRows, isEmpty);
  });

  test('rejects duplicate installs and missing definitions', () async {
    await repository.installTemplate(
      const TemplateInstallRequest(templateKey: 'generic_template'),
    );

    await expectLater(
      repository.installTemplate(
        const TemplateInstallRequest(templateKey: 'generic_template'),
      ),
      throwsA(isA<PersistenceValidationFailure>()),
    );

    await expectLater(
      repository.installTemplate(
        const TemplateInstallRequest(templateKey: 'missing_template'),
      ),
      throwsA(isA<PersistenceValidationFailure>()),
    );
  });

  test('records uninstall choices without export files', () async {
    await repository.installTemplate(
      const TemplateInstallRequest(templateKey: 'generic_template'),
    );

    final uninstalled = await repository.uninstallTemplate(
      const TemplateUninstallRequest(
        templateKey: 'generic_template',
        choice: TemplateUninstallChoice.preserveRecords,
      ),
    );

    final snapshot = await repository.current();

    expect(uninstalled.status, TemplateInstallationStatus.uninstalled);
    expect(
      uninstalled.uninstallChoice,
      TemplateUninstallChoice.preserveRecords,
    );
    expect(uninstalled.uninstalledAt, isNotNull);
    expect(snapshot.isInstalled('generic_template'), isFalse);
  });

  test('rejects unsafe template definitions', () async {
    final unsafe = DriftTemplateRepository(
      database: database,
      idService: FixedIdService(['unsafe-template-installation']),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 9)),
      logger: AppLogger(sink: records.add),
      definitions: const [
        TemplateDefinition(
          key: 'unsafe_template',
          name: 'Unsafe template',
          description: 'Contains unsupported example records.',
          version: '1.0.0',
          configurationJson: '{"spaces":[{"records":[]}]}',
        ),
      ],
    );

    await expectLater(unsafe.current(), throwsA(isA<PersistenceReadFailure>()));

    expect(records.single.operation, 'current');
    expect(records.single.error, isNotNull);
  });
}
