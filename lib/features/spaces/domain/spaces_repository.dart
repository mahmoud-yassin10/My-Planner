import 'spaces_models.dart';

abstract interface class SpacesRepository {
  Future<SpacesSnapshot> current();
  Stream<SpacesSnapshot> watchSpaces();

  Future<SpaceDefinition> createSpace(SpaceDraft draft);
  Future<SpaceRecordType> createRecordType(SpaceRecordTypeDraft draft);
  Future<SpaceFieldDefinition> createField(SpaceFieldDraft draft);
  Future<SpaceStatusDefinition> createStatus(SpaceStatusDraft draft);
  Future<SpaceRecord> createRecord(SpaceRecordDraft draft);
  Future<SpaceRecordLink> linkRecord(SpaceRecordLinkDraft draft);
  Future<SpaceSavedFilter> createSavedFilter(SpaceSavedFilterDraft draft);
  Future<SpaceSavedView> createSavedView(SpaceSavedViewDraft draft);
}
