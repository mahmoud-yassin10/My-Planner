import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';

void main() {
  test('database opens, reports schema version 1, and closes', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.verifyReady();

    expect(database.schemaVersion, appDatabaseSchemaVersion);
  });

  test('fresh database creation includes Phase 2 foundation tables', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .get();

    expect(tables.map((row) => row.data['name']), contains('app_settings'));
    expect(tables.map((row) => row.data['name']), contains('schema_metadata'));
  });

  test('foreign keys are enabled for database connections', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    expect(await database.foreignKeysEnabled(), isTrue);
  });

  test('schema metadata stores the current schema version', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.verifyReady();
    final row = await (database.select(
      database.schemaMetadata,
    )..where((table) => table.key.equals('schemaVersion'))).getSingle();

    expect(row.value, appDatabaseSchemaVersion.toString());
    expect(row.updatedAt.isUtc, isTrue);
  });

  test('migration snapshot for version 1 is checked in and current enough', () {
    final schemaFile = File('drift_schemas/app_database/drift_schema_v1.json');

    expect(schemaFile.existsSync(), isTrue);

    final schema = jsonDecode(schemaFile.readAsStringSync()) as Map;

    expect(
      schemaFile.path,
      contains('drift_schema_v$appDatabaseSchemaVersion'),
    );
    expect(schema['_meta'], isA<Map>());
    expect(schema.toString(), contains('app_settings'));
    expect(schema.toString(), contains('schema_metadata'));
  });
}
