import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

const _expectedTables = <String>{
  'app_settings',
  'schema_metadata',
  'areas',
  'goals',
  'projects',
  'milestones',
  'tasks',
  'tags',
  'entity_tags',
  'notes',
  'note_links',
  'planner_events',
  'time_blocks',
  'focus_sessions',
  'spaces',
  'space_record_types',
  'space_fields',
  'space_statuses',
  'space_records',
  'space_record_links',
  'space_saved_filters',
  'space_saved_views',
  'template_installations',
  'reminder_rules',
  'notification_inbox',
};

const _notificationIndexes = <String>{
  'idx_reminder_rules_enabled_scheduled_at',
  'idx_reminder_rules_owner',
  'idx_notification_inbox_unread',
  'idx_notification_inbox_owner',
  'idx_notification_inbox_schedule_delivery',
};

void main() {
  test('database opens, reports current schema version, and closes', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    await database.verifyReady();

    expect(database.schemaVersion, appDatabaseSchemaVersion);
  });

  test('fresh database contains all tables through schema version 8', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    final rows = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((row) => row.data['name'] as String).toSet();

    expect(names, containsAll(_expectedTables));
  });

  test('notification indexes and reminder foreign key are created', () async {
    final database = AppDatabase.inMemory();
    addTearDown(database.close);

    final indexRows = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final indexNames = indexRows
        .map((row) => row.data['name'] as String)
        .toSet();

    expect(indexNames, containsAll(_notificationIndexes));

    final foreignKeys = await database
        .customSelect("PRAGMA foreign_key_list('notification_inbox')")
        .get();

    expect(
      foreignKeys.any(
        (row) =>
            row.data['table'] == 'reminder_rules' &&
            row.data['from'] == 'reminder_rule_id' &&
            row.data['to'] == 'id' &&
            row.data['on_delete'] == 'SET NULL',
      ),
      isTrue,
    );
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

  test('migration from version 1 creates all current tables', () async {
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

    final rows = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((row) => row.data['name'] as String).toSet();

    expect(names, containsAll(_expectedTables));
  });

  test('current migration snapshot contains notification schema', () {
    final versionOneSchema = File(
      'drift_schemas/app_database/drift_schema_v1.json',
    );
    final currentSchema = File(
      'drift_schemas/app_database/drift_schema_v$appDatabaseSchemaVersion.json',
    );

    expect(versionOneSchema.existsSync(), isTrue);
    expect(currentSchema.existsSync(), isTrue);

    final schema = jsonDecode(currentSchema.readAsStringSync()).toString();

    for (final table in _expectedTables) {
      expect(schema, contains(table));
    }
    for (final index in _notificationIndexes) {
      expect(schema, contains(index));
    }
  });
}
