import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift_spaces_repository.dart';
import '../domain/spaces_models.dart';
import '../domain/spaces_repository.dart';

class SpacesController {
  const SpacesController(this._repository);

  final SpacesRepository _repository;

  Future<SpaceDefinition> createSpace(SpaceDraft draft) {
    return _repository.createSpace(draft);
  }

  Future<SpaceRecordType> createRecordType(SpaceRecordTypeDraft draft) {
    return _repository.createRecordType(draft);
  }

  Future<SpaceFieldDefinition> createField(SpaceFieldDraft draft) {
    return _repository.createField(draft);
  }

  Future<SpaceStatusDefinition> createStatus(SpaceStatusDraft draft) {
    return _repository.createStatus(draft);
  }

  Future<SpaceRecord> createRecord(SpaceRecordDraft draft) {
    return _repository.createRecord(draft);
  }

  Future<SpaceRecordLink> linkRecord(SpaceRecordLinkDraft draft) {
    return _repository.linkRecord(draft);
  }

  Future<SpaceSavedFilter> createSavedFilter(SpaceSavedFilterDraft draft) {
    return _repository.createSavedFilter(draft);
  }

  Future<SpaceSavedView> createSavedView(SpaceSavedViewDraft draft) {
    return _repository.createSavedView(draft);
  }
}

final spacesControllerProvider = Provider<SpacesController>((ref) {
  return SpacesController(ref.watch(spacesRepositoryProvider));
});

final spacesSnapshotProvider = StreamProvider<SpacesSnapshot>((ref) {
  return ref.watch(spacesRepositoryProvider).watchSpaces();
});
