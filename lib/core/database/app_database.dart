import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'app_database.steps.dart';

part 'app_database.g.dart';

const appDatabaseSchemaVersion = 6;

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

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get areaId => text().nullable().references(Areas, #id)();
  TextColumn get goalId => text().nullable().references(Goals, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  TextColumn get milestoneId => text().nullable().references(Milestones, #id)();
  TextColumn get parentTaskId => text().nullable().references(Tasks, #id)();
  TextColumn get status => text()();
  TextColumn get priority => text()();
  TextColumn get energyRequirement => text()();
  IntColumn get estimatedDurationMinutes => integer().nullable()();
  IntColumn get actualDurationMinutes => integer().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get scheduledStartAt => dateTime().nullable()();
  DateTimeColumn get scheduledEndAt => dateTime().nullable()();
  TextColumn get preferredTimeOfDay => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('EntityTagRow')
class EntityTags extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get tagId => text().references(Tags, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get contentFormat => text()();
  BoolColumn get isPinned => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('NoteLinkRow')
class NoteLinks extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get relationshipType => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PlannerEventRow')
class PlannerEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get kind => text()();
  DateTimeColumn get startsAt => dateTime()();
  DateTimeColumn get endsAt => dateTime()();
  BoolColumn get isAllDay => boolean()();
  TextColumn get location => text().nullable()();
  TextColumn get meetingUrl => text().nullable()();
  TextColumn get linkedTaskId => text().nullable().references(Tasks, #id)();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get reminderPolicy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TimeBlockRow')
class TimeBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get kind => text()();
  DateTimeColumn get startsAt => dateTime()();
  DateTimeColumn get endsAt => dateTime()();
  TextColumn get linkedTaskId => text().nullable().references(Tasks, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FocusSessionRow')
class FocusSessions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().nullable().references(Tasks, #id)();
  IntColumn get plannedDurationMinutes => integer()();
  IntColumn get actualDurationMinutes => integer().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceRow')
class Spaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get iconKey => text().nullable()();
  IntColumn get colorValue => integer().nullable()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceRecordTypeRow')
class SpaceRecordTypes extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceFieldRow')
class SpaceFields extends Table {
  TextColumn get id => text()();
  TextColumn get recordTypeId => text().references(SpaceRecordTypes, #id)();
  TextColumn get name => text()();
  TextColumn get fieldKey => text()();
  TextColumn get fieldType => text()();
  BoolColumn get isRequired => boolean()();
  IntColumn get sortOrder => integer()();
  TextColumn get optionsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceStatusRow')
class SpaceStatuses extends Table {
  TextColumn get id => text()();
  TextColumn get recordTypeId => text().references(SpaceRecordTypes, #id)();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().nullable()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isDefault => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceRecordRow')
class SpaceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get recordTypeId => text().references(SpaceRecordTypes, #id)();
  TextColumn get title => text()();
  TextColumn get statusId => text().nullable().references(SpaceStatuses, #id)();
  TextColumn get fieldsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceRecordLinkRow')
class SpaceRecordLinks extends Table {
  TextColumn get id => text()();
  TextColumn get sourceRecordId => text().references(SpaceRecords, #id)();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get relationshipType => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceSavedFilterRow')
class SpaceSavedFilters extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get name => text()();
  TextColumn get filterJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SpaceSavedViewRow')
class SpaceSavedViews extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get name => text()();
  TextColumn get viewType => text()();
  TextColumn get configJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AppSettings,
    SchemaMetadata,
    Areas,
    Goals,
    Projects,
    Milestones,
    Tasks,
    Tags,
    EntityTags,
    Notes,
    NoteLinks,
    PlannerEvents,
    TimeBlocks,
    FocusSessions,
    Spaces,
    SpaceRecordTypes,
    SpaceFields,
    SpaceStatuses,
    SpaceRecords,
    SpaceRecordLinks,
    SpaceSavedFilters,
    SpaceSavedViews,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static const latestSchemaVersion = 6;

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
          from2To3: (migrator, schema) async {
            await migrator.createTable(schema.tasks);
            await migrator.createTable(schema.tags);
            await migrator.createTable(schema.entityTags);
            await migrator.createTable(schema.notes);
            await migrator.createTable(schema.noteLinks);
          },
          from3To4: (migrator, schema) async {
            await migrator.createTable(schema.plannerEvents);
            await migrator.createTable(schema.timeBlocks);
          },
          from4To5: (migrator, schema) async {
            await migrator.createTable(schema.focusSessions);
          },
          from5To6: (migrator, schema) async {
            await migrator.createTable(schema.spaces);
            await migrator.createTable(schema.spaceRecordTypes);
            await migrator.createTable(schema.spaceFields);
            await migrator.createTable(schema.spaceStatuses);
            await migrator.createTable(schema.spaceRecords);
            await migrator.createTable(schema.spaceRecordLinks);
            await migrator.createTable(schema.spaceSavedFilters);
            await migrator.createTable(schema.spaceSavedViews);
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
