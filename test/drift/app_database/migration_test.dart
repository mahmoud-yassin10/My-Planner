// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v7.dart' as v7;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
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

  test('migration from v1 to v7 preserves settings and metadata', () async {
    const updatedAt = '2026-06-24T00:00:00.000Z';
    const oldAppSettingsData = <v1.AppSettingsData>[
      v1.AppSettingsData(
        key: 'themeMode',
        value: 'system',
        updatedAt: updatedAt,
      ),
    ];
    const expectedNewAppSettingsData = <v7.AppSettingsData>[
      v7.AppSettingsData(
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
      newVersion: 7,
      createOld: v1.DatabaseAtV1.new,
      createNew: v7.DatabaseAtV7.new,
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
        expect(metadata.single.value, '7');
      },
    );
  });
}
