import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/errors/persistence_failure.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/features/spaces/data/drift_spaces_repository.dart';
import 'package:momentum_os/features/spaces/domain/spaces_models.dart';

void main() {
  late AppDatabase database;
  late List<AppLogRecord> records;
  late DriftSpacesRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    records = <AppLogRecord>[];
    repository = DriftSpacesRepository(
      database: database,
      idService: FixedIdService([
        'space-1',
        'record-type-1',
        'field-1',
        'status-1',
        'record-1',
        'record-link-1',
        'filter-1',
        'view-1',
        'record-2',
      ]),
      clock: FixedUtcClock(DateTime.utc(2026, 6, 24, 9)),
      logger: AppLogger(sink: records.add),
    );
  });

  tearDown(() => database.close());

  test(
    'creates Spaces definitions, records, relationships, filters, and views',
    () async {
      final space = await repository.createSpace(
        const SpaceDraft(name: 'Space A', description: 'Generic records'),
      );
      final recordType = await repository.createRecordType(
        SpaceRecordTypeDraft(spaceId: space.id, name: 'Record Type A'),
      );
      final field = await repository.createField(
        SpaceFieldDraft(
          recordTypeId: recordType.id,
          name: 'Field A',
          fieldKey: 'field_a',
          fieldType: SpaceFieldType.text,
          isRequired: true,
        ),
      );
      final status = await repository.createStatus(
        SpaceStatusDraft(
          recordTypeId: recordType.id,
          name: 'Status A',
          isDefault: true,
        ),
      );
      final record = await repository.createRecord(
        SpaceRecordDraft(
          recordTypeId: recordType.id,
          title: 'Record A',
          statusId: status.id,
          fieldsJson: '{"field_a":"Value A"}',
        ),
      );
      final link = await repository.linkRecord(
        SpaceRecordLinkDraft(
          sourceRecordId: record.id,
          targetType: 'task',
          targetId: 'task-1',
        ),
      );
      final filter = await repository.createSavedFilter(
        SpaceSavedFilterDraft(spaceId: space.id, name: 'Filter A'),
      );
      final view = await repository.createSavedView(
        SpaceSavedViewDraft(spaceId: space.id, name: 'View A'),
      );

      final snapshot = await repository.current();

      expect(space.id, 'space-1');
      expect(recordType.id, 'record-type-1');
      expect(field.fieldKey, 'field_a');
      expect(status.isDefault, isTrue);
      expect(record.fieldsJson, '{"field_a":"Value A"}');
      expect(link.sourceRecordId, record.id);
      expect(filter.filterJson, '{}');
      expect(view.viewType, SpaceViewType.list);
      expect(snapshot.spaces, hasLength(1));
      expect(snapshot.recordTypes, hasLength(1));
      expect(snapshot.fields, hasLength(1));
      expect(snapshot.statuses, hasLength(1));
      expect(snapshot.records, hasLength(1));
      expect(snapshot.links, hasLength(1));
      expect(snapshot.filters, hasLength(1));
      expect(snapshot.views, hasLength(1));
      expect(snapshot.spaces.single.createdAt.isUtc, isTrue);
    },
  );

  test('watches normal Spaces updates', () async {
    final updates = <SpacesSnapshot>[];
    final subscription = repository.watchSpaces().listen(updates.add);
    addTearDown(subscription.cancel);

    await Future<void>.delayed(Duration.zero);
    await repository.createSpace(const SpaceDraft(name: 'Space A'));
    await Future<void>.delayed(Duration.zero);

    expect(updates.first.isEmpty, isTrue);
    expect(updates.last.spaces.single.name, 'Space A');
  });

  test('rejects invalid field keys and field values', () async {
    final space = await repository.createSpace(
      const SpaceDraft(name: 'Space A'),
    );
    final recordType = await repository.createRecordType(
      SpaceRecordTypeDraft(spaceId: space.id, name: 'Record Type A'),
    );

    await expectLater(
      repository.createField(
        SpaceFieldDraft(
          recordTypeId: recordType.id,
          name: 'Bad Key',
          fieldKey: 'Bad Key',
          fieldType: SpaceFieldType.text,
        ),
      ),
      throwsA(isA<PersistenceValidationFailure>()),
    );

    await repository.createField(
      SpaceFieldDraft(
        recordTypeId: recordType.id,
        name: 'Amount',
        fieldKey: 'amount',
        fieldType: SpaceFieldType.number,
        isRequired: true,
      ),
    );

    await expectLater(
      repository.createRecord(
        SpaceRecordDraft(
          recordTypeId: recordType.id,
          title: 'Record A',
          fieldsJson: '{"amount":"not a number"}',
        ),
      ),
      throwsA(isA<PersistenceValidationFailure>()),
    );
  });

  test('translates foreign key failures at the repository boundary', () async {
    await expectLater(
      repository.createRecordType(
        const SpaceRecordTypeDraft(
          spaceId: 'missing-space',
          name: 'Record Type A',
        ),
      ),
      throwsA(isA<PersistenceWriteFailure>()),
    );

    expect(records.single.operation, 'createRecordType');
    expect(records.single.message, 'Spaces repository operation failed.');
    expect(records.single.metadata['errorType'], isNotEmpty);
    expect(records.single.error, isNotNull);
    expect(records.single.stackTrace, isNotNull);
  });
}
