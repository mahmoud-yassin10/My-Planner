import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'app_database.steps.dart';

part 'app_database.g.dart';

const appDatabaseSchemaVersion = AppDatabase.latestSchemaVersion;

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('SchemaMetadataRow')
class SchemaMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('AreaRow')
class Areas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get iconKey => text().nullable()();
  IntColumn get colorValue => integer().nullable()();
  TextColumn get status => text()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get areaId => text().nullable().references(Areas, #id)();
  TextColumn get parentGoalId => text().nullable().references(Goals, #id)();
  TextColumn get goalType => text().nullable()();
  TextColumn get timeHorizon => text().nullable()();
  TextColumn get measurementType => text().nullable()();
  RealColumn get targetValue => real().nullable()();
  RealColumn get currentValue => real().nullable()();
  TextColumn get unit => text().nullable()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get deadlineAt => dateTime().nullable()();
  IntColumn get priority => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get motivation => text().nullable()();
  TextColumn get reviewFrequency => text().nullable()();
  DateTimeColumn get lastReviewAt => dateTime().nullable()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get customFieldsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get areaId => text().nullable().references(Areas, #id)();
  TextColumn get goalId => text().nullable().references(Goals, #id)();
  TextColumn get status => text()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get deadlineAt => dateTime().nullable()();
  RealColumn get progress => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get customFieldsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MilestoneRow')
class Milestones extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get goalId => text().nullable().references(Goals, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  DateTimeColumn get dueAt => dateTime().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [AppSettings, SchemaMetadata, Areas, Goals, Projects, Milestones],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static const latestSchemaVersion = 2;

  factory AppDatabase.production() => AppDatabase(openProductionDatabase());

  factory AppDatabase.inMemory() {
    return AppDatabase(NativeDatabase.memory(setup: _enableForeignKeys));
  }

  @override
  int get schemaVersion => latestSchemaVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        await stepByStep(
          from1To2: (migrator, schema) async {
            await migrator.createTable(schema.areas);
            await migrator.createTable(schema.goals);
            await migrator.createTable(schema.projects);
            await migrator.createTable(schema.milestones);
          },
        )(migrator, from, to);
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await into(schemaMetadata).insertOnConflictUpdate(
          SchemaMetadataCompanion.insert(
            key: 'schemaVersion',
            value: schemaVersion.toString(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      },
    );
  }

  Future<void> verifyReady() async {
    await customSelect('SELECT 1').getSingle();
  }

  Future<bool> foreignKeysEnabled() async {
    final result = await customSelect('PRAGMA foreign_keys').getSingle();
    return result.data.values.single == 1;
  }
}

LazyDatabase openProductionDatabase() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'momentum_os.sqlite'));

    return NativeDatabase.createInBackground(file, setup: _enableForeignKeys);
  });
}

void _enableForeignKeys(sqlite.Database database) {
  database.execute('PRAGMA foreign_keys = ON');
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.production();
  ref.onDispose(database.close);
  return database;
});
