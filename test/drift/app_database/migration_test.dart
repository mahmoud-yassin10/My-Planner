// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v1 to v8 preserves settings and metadata', () async {
    const updatedAt = '2026-06-24T00:00:00.000Z';
    const oldAppSettingsData = <v1.AppSettingsData>[
      v1.AppSettingsData(
        key: 'themeMode',
        value: 'system',
        updatedAt: updatedAt,
      ),
    ];
    const expectedNewAppSettingsData = <v8.AppSettingsData>[
      v8.AppSettingsData(
        key: 'themeMode',
        value: 'system',
        updatedAt: updatedAt,
      ),
    ];

    const oldSchemaMetadataData = <v1.SchemaMetadataData>[
      v1.SchemaMetadataData(
        key: 'schemaVersion',
        value: '1',
        updatedAt: updatedAt,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 8,
      createOld: v1.DatabaseAtV1.new,
      createNew: v8.DatabaseAtV8.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.appSettings, oldAppSettingsData);
        batch.insertAll(oldDb.schemaMetadata, oldSchemaMetadataData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewAppSettingsData,
          await newDb.select(newDb.appSettings).get(),
        );
        final metadata = await newDb.select(newDb.schemaMetadata).get();
        expect(metadata, hasLength(1));
        expect(metadata.single.key, 'schemaVersion');
        expect(metadata.single.value, '8');
      },
    );
  });

  test('migration from v7 to v8 preserves existing template data', () async {
    const timestamp = '2026-06-24T00:00:00.000Z';
    const oldInstallations = <v7.TemplateInstallationsData>[
      v7.TemplateInstallationsData(
        id: 'template-installation-1',
        templateKey: 'generic-template',
        templateVersion: '1',
        installedAt: timestamp,
        updatedAt: timestamp,
        configurationSnapshotJson: '{}',
        status: 'installed',
      ),
    ];
    const expectedInstallations = <v8.TemplateInstallationsData>[
      v8.TemplateInstallationsData(
        id: 'template-installation-1',
        templateKey: 'generic-template',
        templateVersion: '1',
        installedAt: timestamp,
        updatedAt: timestamp,
        configurationSnapshotJson: '{}',
        status: 'installed',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: 8,
      createOld: v7.DatabaseAtV7.new,
      createNew: v8.DatabaseAtV8.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.templateInstallations, oldInstallations);
      },
      validateItems: (newDb) async {
        expect(
          expectedInstallations,
          await newDb.select(newDb.templateInstallations).get(),
        );
        expect(await newDb.select(newDb.reminderRules).get(), isEmpty);
        expect(await newDb.select(newDb.notificationInbox).get(), isEmpty);
      },
    );
  });
}
