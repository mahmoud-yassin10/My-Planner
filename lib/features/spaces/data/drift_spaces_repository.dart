import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/persistence_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/services/id_service.dart';
import '../../../core/services/utc_clock.dart';
import '../domain/spaces_models.dart';
import '../domain/spaces_repository.dart';

class DriftSpacesRepository implements SpacesRepository {
  const DriftSpacesRepository({
    required AppDatabase database,
    required IdService idService,
    required UtcClock clock,
    required AppLogger logger,
  }) : this._(database, idService, clock, logger);

  const DriftSpacesRepository._(
    this._database,
    this._idService,
    this._clock,
    this._logger,
  );

  final AppDatabase _database;
  final IdService _idService;
  final UtcClock _clock;
  final AppLogger _logger;

  @override
  Future<SpacesSnapshot> current() async {
    try {
      return _snapshot();
    } catch (error, stackTrace) {
      _logFailure('current', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read Spaces data.');
    }
  }

  @override
  Stream<SpacesSnapshot> watchSpaces() async* {
    yield await current();
    yield* _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.spaces,
            _database.spaceRecordTypes,
            _database.spaceFields,
            _database.spaceStatuses,
            _database.spaceRecords,
            _database.spaceRecordLinks,
            _database.spaceSavedFilters,
            _database.spaceSavedViews,
          },
        )
        .watch()
        .skip(1)
        .asyncMap((_) => current())
        .handleError((Object error, StackTrace stackTrace) {
          _logFailure('watchSpaces', error, stackTrace);
          throw const PersistenceReadFailure('Unable to watch Spaces data.');
        });
  }

  @override
  Future<SpaceDefinition> createSpace(SpaceDraft draft) async {
    final now = _clock.now();
    final space = SpaceDefinition(
      id: _idService.newId(),
      name: _requiredText(draft.name, 'Space name'),
      description: _optionalText(draft.description),
      iconKey: _optionalText(draft.iconKey),
      colorValue: draft.colorValue,
      sortOrder: draft.sortOrder,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database.into(_database.spaces).insert(_spaceCompanion(space));
      return space;
    } catch (error, stackTrace) {
      _logFailure('createSpace', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create Space.');
    }
  }

  @override
  Future<void> archiveSpace(String id) => _setArchive(
    operation: 'archiveSpace',
    tableName: 'spaces',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreSpace(String id) => _setArchive(
    operation: 'restoreSpace',
    tableName: 'spaces',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteSpace(String id) => _delete(
    operation: 'deleteSpace',
    tableName: 'spaces',
    delete: () => (_database.delete(
      _database.spaces,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<SpaceRecordType> createRecordType(SpaceRecordTypeDraft draft) async {
    final now = _clock.now();
    final recordType = SpaceRecordType(
      id: _idService.newId(),
      spaceId: _requiredText(draft.spaceId, 'Space id'),
      name: _requiredText(draft.name, 'Record type name'),
      description: _optionalText(draft.description),
      sortOrder: draft.sortOrder,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.spaceRecordTypes)
          .insert(_recordTypeCompanion(recordType));
      return recordType;
    } catch (error, stackTrace) {
      _logFailure('createRecordType', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create record type.');
    }
  }

  @override
  Future<void> archiveRecordType(String id) => _setArchive(
    operation: 'archiveRecordType',
    tableName: 'space_record_types',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreRecordType(String id) => _setArchive(
    operation: 'restoreRecordType',
    tableName: 'space_record_types',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteRecordType(String id) => _delete(
    operation: 'deleteRecordType',
    tableName: 'space_record_types',
    delete: () => (_database.delete(
      _database.spaceRecordTypes,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<SpaceFieldDefinition> createField(SpaceFieldDraft draft) async {
    final now = _clock.now();
    final field = SpaceFieldDefinition(
      id: _idService.newId(),
      recordTypeId: _requiredText(draft.recordTypeId, 'Record type id'),
      name: _requiredText(draft.name, 'Field name'),
      fieldKey: _fieldKey(draft.fieldKey),
      fieldType: draft.fieldType,
      isRequired: draft.isRequired,
      sortOrder: draft.sortOrder,
      optionsJson: _jsonObjectOrArray(draft.optionsJson, 'Field options'),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.spaceFields)
          .insert(_fieldCompanion(field));
      return field;
    } catch (error, stackTrace) {
      _logFailure('createField', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create field.');
    }
  }

  @override
  Future<void> archiveField(String id) => _setArchive(
    operation: 'archiveField',
    tableName: 'space_fields',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreField(String id) => _setArchive(
    operation: 'restoreField',
    tableName: 'space_fields',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteField(String id) => _delete(
    operation: 'deleteField',
    tableName: 'space_fields',
    delete: () => (_database.delete(
      _database.spaceFields,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<SpaceStatusDefinition> createStatus(SpaceStatusDraft draft) async {
    final now = _clock.now();
    final status = SpaceStatusDefinition(
      id: _idService.newId(),
      recordTypeId: _requiredText(draft.recordTypeId, 'Record type id'),
      name: _requiredText(draft.name, 'Status name'),
      colorValue: draft.colorValue,
      sortOrder: draft.sortOrder,
      isDefault: draft.isDefault,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.spaceStatuses)
          .insert(_statusCompanion(status));
      return status;
    } catch (error, stackTrace) {
      _logFailure('createStatus', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create status.');
    }
  }

  @override
  Future<void> archiveStatus(String id) => _setArchive(
    operation: 'archiveStatus',
    tableName: 'space_statuses',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreStatus(String id) => _setArchive(
    operation: 'restoreStatus',
    tableName: 'space_statuses',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteStatus(String id) => _delete(
    operation: 'deleteStatus',
    tableName: 'space_statuses',
    delete: () => (_database.delete(
      _database.spaceStatuses,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<SpaceRecord> createRecord(SpaceRecordDraft draft) async {
    final fields = await _validateRecordFields(
      draft.recordTypeId,
      draft.fieldsJson,
    );
    final now = _clock.now();
    final record = SpaceRecord(
      id: _idService.newId(),
      recordTypeId: _requiredText(draft.recordTypeId, 'Record type id'),
      title: _requiredText(draft.title, 'Record title'),
      statusId: _optionalText(draft.statusId),
      fieldsJson: jsonEncode(fields),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.spaceRecords)
          .insert(_recordCompanion(record));
      return record;
    } catch (error, stackTrace) {
      _logFailure('createRecord', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create Space record.');
    }
  }

  @override
  Future<void> archiveRecord(String id) => _setArchive(
    operation: 'archiveRecord',
    tableName: 'space_records',
    id: id,
    archivedAt: _clock.now(),
  );

  @override
  Future<void> restoreRecord(String id) => _setArchive(
    operation: 'restoreRecord',
    tableName: 'space_records',
    id: id,
    archivedAt: null,
  );

  @override
  Future<void> deleteRecord(String id) => _delete(
    operation: 'deleteRecord',
    tableName: 'space_records',
    delete: () => (_database.delete(
      _database.spaceRecords,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<SpaceRecordLink> linkRecord(SpaceRecordLinkDraft draft) async {
    final now = _clock.now();
    final link = SpaceRecordLink(
      id: _idService.newId(),
      sourceRecordId: _requiredText(draft.sourceRecordId, 'Source record id'),
      targetType: _requiredText(draft.targetType, 'Target type'),
      targetId: _requiredText(draft.targetId, 'Target id'),
      relationshipType: _requiredText(
        draft.relationshipType,
        'Relationship type',
      ),
      createdAt: now,
    );

    try {
      await _database
          .into(_database.spaceRecordLinks)
          .insert(_linkCompanion(link));
      return link;
    } catch (error, stackTrace) {
      _logFailure('linkRecord', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to link Space record.');
    }
  }

  @override
  Future<void> deleteRecordLink(String id) => _delete(
    operation: 'deleteRecordLink',
    tableName: 'space_record_links',
    delete: () => (_database.delete(
      _database.spaceRecordLinks,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<SpaceSavedFilter> createSavedFilter(
    SpaceSavedFilterDraft draft,
  ) async {
    final now = _clock.now();
    final filter = SpaceSavedFilter(
      id: _idService.newId(),
      spaceId: _requiredText(draft.spaceId, 'Space id'),
      name: _requiredText(draft.name, 'Filter name'),
      filterJson: _jsonObject(draft.filterJson, 'Filter'),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.spaceSavedFilters)
          .insert(_filterCompanion(filter));
      return filter;
    } catch (error, stackTrace) {
      _logFailure('createSavedFilter', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create saved filter.');
    }
  }

  @override
  Future<void> deleteSavedFilter(String id) => _delete(
    operation: 'deleteSavedFilter',
    tableName: 'space_saved_filters',
    delete: () => (_database.delete(
      _database.spaceSavedFilters,
    )..where((table) => table.id.equals(id))).go(),
  );

  @override
  Future<SpaceSavedView> createSavedView(SpaceSavedViewDraft draft) async {
    final now = _clock.now();
    final view = SpaceSavedView(
      id: _idService.newId(),
      spaceId: _requiredText(draft.spaceId, 'Space id'),
      name: _requiredText(draft.name, 'View name'),
      viewType: draft.viewType,
      configJson: _viewConfig(draft.configJson),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _database
          .into(_database.spaceSavedViews)
          .insert(_viewCompanion(view));
      return view;
    } catch (error, stackTrace) {
      _logFailure('createSavedView', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to create saved view.');
    }
  }

  @override
  Future<void> deleteSavedView(String id) => _delete(
    operation: 'deleteSavedView',
    tableName: 'space_saved_views',
    delete: () => (_database.delete(
      _database.spaceSavedViews,
    )..where((table) => table.id.equals(id))).go(),
  );

  Future<SpacesSnapshot> _snapshot() async {
    final rows = await Future.wait([
      (_database.select(_database.spaces)..orderBy([
            (table) => OrderingTerm.asc(table.sortOrder),
            (table) => OrderingTerm.asc(table.name),
          ]))
          .get(),
      _database.select(_database.spaceRecordTypes).get(),
      _database.select(_database.spaceFields).get(),
      _database.select(_database.spaceStatuses).get(),
      _database.select(_database.spaceRecords).get(),
      _database.select(_database.spaceRecordLinks).get(),
      _database.select(_database.spaceSavedFilters).get(),
      _database.select(_database.spaceSavedViews).get(),
    ]);

    return SpacesSnapshot(
      spaces: (rows[0] as List<SpaceRow>).map(_spaceFromRow).toList(),
      recordTypes: (rows[1] as List<SpaceRecordTypeRow>)
          .map(_recordTypeFromRow)
          .toList(),
      fields: (rows[2] as List<SpaceFieldRow>).map(_fieldFromRow).toList(),
      statuses: (rows[3] as List<SpaceStatusRow>).map(_statusFromRow).toList(),
      records: (rows[4] as List<SpaceRecordRow>).map(_recordFromRow).toList(),
      links: (rows[5] as List<SpaceRecordLinkRow>).map(_linkFromRow).toList(),
      filters: (rows[6] as List<SpaceSavedFilterRow>)
          .map(_filterFromRow)
          .toList(),
      views: (rows[7] as List<SpaceSavedViewRow>).map(_viewFromRow).toList(),
    );
  }

  Future<Map<String, Object?>> _validateRecordFields(
    String recordTypeId,
    String fieldsJson,
  ) async {
    final decoded = jsonDecode(_jsonObject(fieldsJson, 'Record fields'));
    final values = decoded as Map<String, Object?>;
    final fields = await (_database.select(
      _database.spaceFields,
    )..where((table) => table.recordTypeId.equals(recordTypeId))).get();

    for (final field in fields.map(_fieldFromRow)) {
      final value = values[field.fieldKey];
      if (field.isRequired && value == null) {
        throw PersistenceValidationFailure('${field.name} is required.');
      }
      if (value != null) {
        _validateFieldValue(field, value);
      }
    }
    return values;
  }

  void _validateFieldValue(SpaceFieldDefinition field, Object? value) {
    final valid = switch (field.fieldType) {
      SpaceFieldType.text ||
      SpaceFieldType.url ||
      SpaceFieldType.select => value is String,
      SpaceFieldType.number => value is num,
      SpaceFieldType.checkbox => value is bool,
      SpaceFieldType.date =>
        value is String && DateTime.tryParse(value) != null,
    };
    if (!valid) {
      throw PersistenceValidationFailure(
        '${field.name} has an invalid ${field.fieldType.name} value.',
      );
    }
  }

  Future<void> _setArchive({
    required String operation,
    required String tableName,
    required String id,
    required DateTime? archivedAt,
  }) async {
    try {
      final updatedAt = _clock.now();
      final sql = archivedAt == null
          ? 'UPDATE $tableName SET archived_at = NULL, updated_at = ? WHERE id = ?'
          : 'UPDATE $tableName SET archived_at = ?, updated_at = ? WHERE id = ?';
      final variables = archivedAt == null
          ? [Variable<DateTime>(updatedAt), Variable<String>(id)]
          : [
              Variable<DateTime>(archivedAt),
              Variable<DateTime>(updatedAt),
              Variable<String>(id),
            ];
      final count = await _database.customUpdate(
        sql,
        variables: variables,
        updates: {
          switch (tableName) {
            'spaces' => _database.spaces,
            'space_record_types' => _database.spaceRecordTypes,
            'space_fields' => _database.spaceFields,
            'space_statuses' => _database.spaceStatuses,
            'space_records' => _database.spaceRecords,
            _ => throw ArgumentError.value(tableName, 'tableName'),
          },
        },
      );
      if (count == 0) {
        throw const PersistenceWriteFailure('Record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update archive state.');
    }
  }

  Future<void> _delete({
    required String operation,
    required String tableName,
    required Future<int> Function() delete,
  }) async {
    try {
      final count = await delete();
      if (count == 0) {
        throw const PersistenceWriteFailure('Record was not found.');
      }
    } catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw PersistenceWriteFailure('Unable to delete $tableName record.');
    }
  }

  SpacesCompanion _spaceCompanion(SpaceDefinition space) {
    return SpacesCompanion.insert(
      id: space.id,
      name: space.name,
      description: Value(space.description),
      iconKey: Value(space.iconKey),
      colorValue: Value(space.colorValue),
      sortOrder: space.sortOrder,
      createdAt: space.createdAt,
      updatedAt: space.updatedAt,
      archivedAt: Value(space.archivedAt),
    );
  }

  SpaceRecordTypesCompanion _recordTypeCompanion(SpaceRecordType recordType) {
    return SpaceRecordTypesCompanion.insert(
      id: recordType.id,
      spaceId: recordType.spaceId,
      name: recordType.name,
      description: Value(recordType.description),
      sortOrder: recordType.sortOrder,
      createdAt: recordType.createdAt,
      updatedAt: recordType.updatedAt,
      archivedAt: Value(recordType.archivedAt),
    );
  }

  SpaceFieldsCompanion _fieldCompanion(SpaceFieldDefinition field) {
    return SpaceFieldsCompanion.insert(
      id: field.id,
      recordTypeId: field.recordTypeId,
      name: field.name,
      fieldKey: field.fieldKey,
      fieldType: field.fieldType.name,
      isRequired: field.isRequired,
      sortOrder: field.sortOrder,
      optionsJson: Value(field.optionsJson),
      createdAt: field.createdAt,
      updatedAt: field.updatedAt,
      archivedAt: Value(field.archivedAt),
    );
  }

  SpaceStatusesCompanion _statusCompanion(SpaceStatusDefinition status) {
    return SpaceStatusesCompanion.insert(
      id: status.id,
      recordTypeId: status.recordTypeId,
      name: status.name,
      colorValue: Value(status.colorValue),
      sortOrder: status.sortOrder,
      isDefault: status.isDefault,
      createdAt: status.createdAt,
      updatedAt: status.updatedAt,
      archivedAt: Value(status.archivedAt),
    );
  }

  SpaceRecordsCompanion _recordCompanion(SpaceRecord record) {
    return SpaceRecordsCompanion.insert(
      id: record.id,
      recordTypeId: record.recordTypeId,
      title: record.title,
      statusId: Value(record.statusId),
      fieldsJson: record.fieldsJson,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      archivedAt: Value(record.archivedAt),
    );
  }

  SpaceRecordLinksCompanion _linkCompanion(SpaceRecordLink link) {
    return SpaceRecordLinksCompanion.insert(
      id: link.id,
      sourceRecordId: link.sourceRecordId,
      targetType: link.targetType,
      targetId: link.targetId,
      relationshipType: link.relationshipType,
      createdAt: link.createdAt,
    );
  }

  SpaceSavedFiltersCompanion _filterCompanion(SpaceSavedFilter filter) {
    return SpaceSavedFiltersCompanion.insert(
      id: filter.id,
      spaceId: filter.spaceId,
      name: filter.name,
      filterJson: filter.filterJson,
      createdAt: filter.createdAt,
      updatedAt: filter.updatedAt,
    );
  }

  SpaceSavedViewsCompanion _viewCompanion(SpaceSavedView view) {
    return SpaceSavedViewsCompanion.insert(
      id: view.id,
      spaceId: view.spaceId,
      name: view.name,
      viewType: view.viewType.name,
      configJson: view.configJson,
      createdAt: view.createdAt,
      updatedAt: view.updatedAt,
    );
  }

  SpaceDefinition _spaceFromRow(SpaceRow row) => SpaceDefinition(
    id: row.id,
    name: row.name,
    description: row.description,
    iconKey: row.iconKey,
    colorValue: row.colorValue,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    archivedAt: row.archivedAt,
  );

  SpaceRecordType _recordTypeFromRow(SpaceRecordTypeRow row) => SpaceRecordType(
    id: row.id,
    spaceId: row.spaceId,
    name: row.name,
    description: row.description,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    archivedAt: row.archivedAt,
  );

  SpaceFieldDefinition _fieldFromRow(SpaceFieldRow row) => SpaceFieldDefinition(
    id: row.id,
    recordTypeId: row.recordTypeId,
    name: row.name,
    fieldKey: row.fieldKey,
    fieldType: _enumValue(
      SpaceFieldType.values,
      row.fieldType,
      SpaceFieldType.text,
    ),
    isRequired: row.isRequired,
    sortOrder: row.sortOrder,
    optionsJson: row.optionsJson,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    archivedAt: row.archivedAt,
  );

  SpaceStatusDefinition _statusFromRow(SpaceStatusRow row) {
    return SpaceStatusDefinition(
      id: row.id,
      recordTypeId: row.recordTypeId,
      name: row.name,
      colorValue: row.colorValue,
      sortOrder: row.sortOrder,
      isDefault: row.isDefault,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
    );
  }

  SpaceRecord _recordFromRow(SpaceRecordRow row) => SpaceRecord(
    id: row.id,
    recordTypeId: row.recordTypeId,
    title: row.title,
    statusId: row.statusId,
    fieldsJson: row.fieldsJson,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    archivedAt: row.archivedAt,
  );

  SpaceRecordLink _linkFromRow(SpaceRecordLinkRow row) => SpaceRecordLink(
    id: row.id,
    sourceRecordId: row.sourceRecordId,
    targetType: row.targetType,
    targetId: row.targetId,
    relationshipType: row.relationshipType,
    createdAt: row.createdAt,
  );

  SpaceSavedFilter _filterFromRow(SpaceSavedFilterRow row) => SpaceSavedFilter(
    id: row.id,
    spaceId: row.spaceId,
    name: row.name,
    filterJson: row.filterJson,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  SpaceSavedView _viewFromRow(SpaceSavedViewRow row) => SpaceSavedView(
    id: row.id,
    spaceId: row.spaceId,
    name: row.name,
    viewType: _enumValue(
      SpaceViewType.values,
      row.viewType,
      SpaceViewType.list,
    ),
    configJson: row.configJson,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  String _fieldKey(String value) {
    final key = _requiredText(value, 'Field key');
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(key)) {
      throw const PersistenceValidationFailure(
        'Field key must use lower-case letters, numbers, and underscores.',
      );
    }
    return key;
  }

  String _jsonObject(String value, String label) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      throw PersistenceValidationFailure('$label must be a JSON object.');
    }
    return jsonEncode(decoded);
  }

  String _viewConfig(String value) {
    final decoded = jsonDecode(_jsonObject(value, 'View config'));
    final config = decoded as Map<String, Object?>;
    const supportedKeys = {
      'recordTypeId',
      'visibleFieldKeys',
      'groupByStatus',
      'sortFieldKey',
    };
    final unsupportedKeys = config.keys.where(
      (key) => !supportedKeys.contains(key),
    );
    if (unsupportedKeys.isNotEmpty) {
      throw const PersistenceValidationFailure(
        'View config contains unsupported keys.',
      );
    }
    final recordTypeId = config['recordTypeId'];
    if (recordTypeId != null && recordTypeId is! String) {
      throw const PersistenceValidationFailure(
        'View config recordTypeId must be a string.',
      );
    }
    final visibleFieldKeys = config['visibleFieldKeys'];
    if (visibleFieldKeys != null &&
        (visibleFieldKeys is! List ||
            visibleFieldKeys.any((value) => value is! String))) {
      throw const PersistenceValidationFailure(
        'View config visibleFieldKeys must be a list of strings.',
      );
    }
    final groupByStatus = config['groupByStatus'];
    if (groupByStatus != null && groupByStatus is! bool) {
      throw const PersistenceValidationFailure(
        'View config groupByStatus must be a boolean.',
      );
    }
    final sortFieldKey = config['sortFieldKey'];
    if (sortFieldKey != null && sortFieldKey is! String) {
      throw const PersistenceValidationFailure(
        'View config sortFieldKey must be a string.',
      );
    }
    return jsonEncode(config);
  }

  String? _jsonObjectOrArray(String? value, String label) {
    final cleaned = _optionalText(value);
    if (cleaned == null) {
      return null;
    }
    final decoded = jsonDecode(cleaned);
    if (decoded is! Map<String, Object?> && decoded is! List<Object?>) {
      throw PersistenceValidationFailure(
        '$label must be a JSON object or array.',
      );
    }
    return jsonEncode(decoded);
  }

  String _requiredText(String value, String label) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw PersistenceValidationFailure('$label must not be empty.');
    }
    return trimmed;
  }

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  T _enumValue<T extends Enum>(List<T> values, String name, T fallback) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }

  void _logFailure(String operation, Object error, StackTrace stackTrace) {
    _logger.error(
      'spacesRepository',
      operation,
      'Spaces repository operation failed.',
      metadata: {'errorType': error.runtimeType.toString()},
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final spacesRepositoryProvider = Provider<SpacesRepository>((ref) {
  return DriftSpacesRepository(
    database: ref.watch(appDatabaseProvider),
    idService: ref.watch(idServiceProvider),
    clock: ref.watch(utcClockProvider),
    logger: ref.watch(appLoggerProvider),
  );
});
