enum SpaceFieldType { text, number, checkbox, date, url, select }

enum SpaceViewType { list, table, board, cards }

class SpaceDefinition {
  const SpaceDefinition({
    required this.id,
    required this.name,
    this.description,
    this.iconKey,
    this.colorValue,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? iconKey;
  final int? colorValue;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class SpaceRecordType {
  const SpaceRecordType({
    required this.id,
    required this.spaceId,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String spaceId;
  final String name;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class SpaceFieldDefinition {
  const SpaceFieldDefinition({
    required this.id,
    required this.recordTypeId,
    required this.name,
    required this.fieldKey,
    required this.fieldType,
    required this.isRequired,
    required this.sortOrder,
    this.optionsJson,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String recordTypeId;
  final String name;
  final String fieldKey;
  final SpaceFieldType fieldType;
  final bool isRequired;
  final int sortOrder;
  final String? optionsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class SpaceStatusDefinition {
  const SpaceStatusDefinition({
    required this.id,
    required this.recordTypeId,
    required this.name,
    this.colorValue,
    required this.sortOrder,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String recordTypeId;
  final String name;
  final int? colorValue;
  final int sortOrder;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class SpaceRecord {
  const SpaceRecord({
    required this.id,
    required this.recordTypeId,
    required this.title,
    this.statusId,
    required this.fieldsJson,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String recordTypeId;
  final String title;
  final String? statusId;
  final String fieldsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class SpaceRecordLink {
  const SpaceRecordLink({
    required this.id,
    required this.sourceRecordId,
    required this.targetType,
    required this.targetId,
    required this.relationshipType,
    required this.createdAt,
  });

  final String id;
  final String sourceRecordId;
  final String targetType;
  final String targetId;
  final String relationshipType;
  final DateTime createdAt;
}

class SpaceSavedFilter {
  const SpaceSavedFilter({
    required this.id,
    required this.spaceId,
    required this.name,
    required this.filterJson,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String spaceId;
  final String name;
  final String filterJson;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SpaceSavedView {
  const SpaceSavedView({
    required this.id,
    required this.spaceId,
    required this.name,
    required this.viewType,
    required this.configJson,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String spaceId;
  final String name;
  final SpaceViewType viewType;
  final String configJson;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class SpacesSnapshot {
  const SpacesSnapshot({
    this.spaces = const [],
    this.recordTypes = const [],
    this.fields = const [],
    this.statuses = const [],
    this.records = const [],
    this.links = const [],
    this.filters = const [],
    this.views = const [],
  });

  final List<SpaceDefinition> spaces;
  final List<SpaceRecordType> recordTypes;
  final List<SpaceFieldDefinition> fields;
  final List<SpaceStatusDefinition> statuses;
  final List<SpaceRecord> records;
  final List<SpaceRecordLink> links;
  final List<SpaceSavedFilter> filters;
  final List<SpaceSavedView> views;

  bool get isEmpty => spaces.isEmpty;
}

class SpaceDraft {
  const SpaceDraft({
    required this.name,
    this.description,
    this.iconKey,
    this.colorValue,
    this.sortOrder = 0,
  });

  final String name;
  final String? description;
  final String? iconKey;
  final int? colorValue;
  final int sortOrder;
}

class SpaceRecordTypeDraft {
  const SpaceRecordTypeDraft({
    required this.spaceId,
    required this.name,
    this.description,
    this.sortOrder = 0,
  });

  final String spaceId;
  final String name;
  final String? description;
  final int sortOrder;
}

class SpaceFieldDraft {
  const SpaceFieldDraft({
    required this.recordTypeId,
    required this.name,
    required this.fieldKey,
    required this.fieldType,
    this.isRequired = false,
    this.sortOrder = 0,
    this.optionsJson,
  });

  final String recordTypeId;
  final String name;
  final String fieldKey;
  final SpaceFieldType fieldType;
  final bool isRequired;
  final int sortOrder;
  final String? optionsJson;
}

class SpaceStatusDraft {
  const SpaceStatusDraft({
    required this.recordTypeId,
    required this.name,
    this.colorValue,
    this.sortOrder = 0,
    this.isDefault = false,
  });

  final String recordTypeId;
  final String name;
  final int? colorValue;
  final int sortOrder;
  final bool isDefault;
}

class SpaceRecordDraft {
  const SpaceRecordDraft({
    required this.recordTypeId,
    required this.title,
    this.statusId,
    this.fieldsJson = '{}',
  });

  final String recordTypeId;
  final String title;
  final String? statusId;
  final String fieldsJson;
}

class SpaceRecordLinkDraft {
  const SpaceRecordLinkDraft({
    required this.sourceRecordId,
    required this.targetType,
    required this.targetId,
    this.relationshipType = 'related',
  });

  final String sourceRecordId;
  final String targetType;
  final String targetId;
  final String relationshipType;
}

class SpaceSavedFilterDraft {
  const SpaceSavedFilterDraft({
    required this.spaceId,
    required this.name,
    this.filterJson = '{}',
  });

  final String spaceId;
  final String name;
  final String filterJson;
}

class SpaceSavedViewDraft {
  const SpaceSavedViewDraft({
    required this.spaceId,
    required this.name,
    this.viewType = SpaceViewType.list,
    this.configJson = '{}',
  });

  final String spaceId;
  final String name;
  final SpaceViewType viewType;
  final String configJson;
}
