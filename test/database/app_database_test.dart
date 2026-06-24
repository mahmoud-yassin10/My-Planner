import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('database opens, reports current schema version, and closes', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.verifyReady();

    expect(database.schemaVersion, appDatabaseSchemaVersion);
  });

  test(
    'fresh database creation includes foundation, productivity-core, and planner tables',
    () async {
      final database = AppDatabase.inMemory();
      addTearDown(database.close);

      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          )
          .get();

      expect(tables.map((row) => row.data['name']), contains('app_settings'));
      expect(
        tables.map((row) => row.data['name']),
        contains('schema_metadata'),
      );
      expect(tables.map((row) => row.data['name']), contains('areas'));
      expect(tables.map((row) => row.data['name']), contains('goals'));
      expect(tables.map((row) => row.data['name']), contains('projects'));
      expect(tables.map((row) => row.data['name']), contains('milestones'));
      expect(tables.map((row) => row.data['name']), contains('tasks'));
      expect(tables.map((row) => row.data['name']), contains('tags'));
      expect(tables.map((row) => row.data['name']), contains('entity_tags'));
      expect(tables.map((row) => row.data['name']), contains('notes'));
      expect(tables.map((row) => row.data['name']), contains('note_links'));
      expect(tables.map((row) => row.data['name']), contains('planner_events'));
      expect(tables.map((row) => row.data['name']), contains('time_blocks'));
    },
  );

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

  test('migration from version 1 creates planner foundation tables', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'momentum_os_migration_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final file = File('${tempDirectory.path}/migration.sqlite');
    final legacy = sqlite.sqlite3.open(file.path);
    legacy
      ..execute(
        'CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL)',
      )
      ..execute(
        'CREATE TABLE schema_metadata (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL)',
      )
      ..execute('PRAGMA user_version = 1')
      ..close();

    final database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    await database.verifyReady();

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .get();

    expect(tables.map((row) => row.data['name']), contains('areas'));
    expect(tables.map((row) => row.data['name']), contains('goals'));
    expect(tables.map((row) => row.data['name']), contains('projects'));
    expect(tables.map((row) => row.data['name']), contains('milestones'));
    expect(tables.map((row) => row.data['name']), contains('tasks'));
    expect(tables.map((row) => row.data['name']), contains('tags'));
    expect(tables.map((row) => row.data['name']), contains('entity_tags'));
    expect(tables.map((row) => row.data['name']), contains('notes'));
    expect(tables.map((row) => row.data['name']), contains('note_links'));
    expect(tables.map((row) => row.data['name']), contains('planner_events'));
    expect(tables.map((row) => row.data['name']), contains('time_blocks'));
  });

  test(
    'migration snapshots for version 1 and current version are checked in',
    () {
      final versionOneSchema = File(
        'drift_schemas/app_database/drift_schema_v1.json',
      );
      final currentSchema = File(
        'drift_schemas/app_database/drift_schema_v$appDatabaseSchemaVersion.json',
      );

      expect(versionOneSchema.existsSync(), isTrue);
      expect(currentSchema.existsSync(), isTrue);

      final schema = jsonDecode(currentSchema.readAsStringSync()) as Map;

      expect(
        currentSchema.path,
        contains('drift_schema_v$appDatabaseSchemaVersion'),
      );
      expect(schema['_meta'], isA<Map>());
      expect(schema.toString(), contains('app_settings'));
      expect(schema.toString(), contains('schema_metadata'));
      expect(schema.toString(), contains('areas'));
      expect(schema.toString(), contains('goals'));
      expect(schema.toString(), contains('projects'));
      expect(schema.toString(), contains('milestones'));
      expect(schema.toString(), contains('tasks'));
      expect(schema.toString(), contains('tags'));
      expect(schema.toString(), contains('entity_tags'));
      expect(schema.toString(), contains('notes'));
      expect(schema.toString(), contains('note_links'));
      expect(schema.toString(), contains('planner_events'));
      expect(schema.toString(), contains('time_blocks'));
    },
  );
}
