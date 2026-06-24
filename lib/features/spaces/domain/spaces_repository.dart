import 'spaces_models.dart';

abstract interface class SpacesRepository {
  Future<SpacesSnapshot> current();
  Stream<SpacesSnapshot> watchSpaces();

  Future<SpaceDefinition> createSpace(SpaceDraft draft);
  Future<void> archiveSpace(String id);
  Future<void> restoreSpace(String id);
  Future<void> deleteSpace(String id);

  Future<SpaceRecordType> createRecordType(SpaceRecordTypeDraft draft);
  Future<void> archiveRecordType(String id);
  Future<void> restoreRecordType(String id);
  Future<void> deleteRecordType(String id);

  Future<SpaceFieldDefinition> createField(SpaceFieldDraft draft);
  Future<void> archiveField(String id);
  Future<void> restoreField(String id);
  Future<void> deleteField(String id);

  Future<SpaceStatusDefinition> createStatus(SpaceStatusDraft draft);
  Future<void> archiveStatus(String id);
  Future<void> restoreStatus(String id);
  Future<void> deleteStatus(String id);

  Future<SpaceRecord> createRecord(SpaceRecordDraft draft);
  Future<void> archiveRecord(String id);
  Future<void> restoreRecord(String id);
  Future<void> deleteRecord(String id);

  Future<SpaceRecordLink> linkRecord(SpaceRecordLinkDraft draft);
  Future<void> deleteRecordLink(String id);

  Future<SpaceSavedFilter> createSavedFilter(SpaceSavedFilterDraft draft);
  Future<void> deleteSavedFilter(String id);

  Future<SpaceSavedView> createSavedView(SpaceSavedViewDraft draft);
  Future<void> deleteSavedView(String id);
}
