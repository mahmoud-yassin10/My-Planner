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

  Future<void> archiveSpace(String id) => _repository.archiveSpace(id);

  Future<void> restoreSpace(String id) => _repository.restoreSpace(id);

  Future<void> deleteSpace(String id) => _repository.deleteSpace(id);

  Future<SpaceRecordType> createRecordType(SpaceRecordTypeDraft draft) {
    return _repository.createRecordType(draft);
  }

  Future<void> archiveRecordType(String id) {
    return _repository.archiveRecordType(id);
  }

  Future<void> restoreRecordType(String id) {
    return _repository.restoreRecordType(id);
  }

  Future<void> deleteRecordType(String id) {
    return _repository.deleteRecordType(id);
  }

  Future<SpaceFieldDefinition> createField(SpaceFieldDraft draft) {
    return _repository.createField(draft);
  }

  Future<void> archiveField(String id) => _repository.archiveField(id);

  Future<void> restoreField(String id) => _repository.restoreField(id);

  Future<void> deleteField(String id) => _repository.deleteField(id);

  Future<SpaceStatusDefinition> createStatus(SpaceStatusDraft draft) {
    return _repository.createStatus(draft);
  }

  Future<void> archiveStatus(String id) => _repository.archiveStatus(id);

  Future<void> restoreStatus(String id) => _repository.restoreStatus(id);

  Future<void> deleteStatus(String id) => _repository.deleteStatus(id);

  Future<SpaceRecord> createRecord(SpaceRecordDraft draft) {
    return _repository.createRecord(draft);
  }

  Future<void> archiveRecord(String id) => _repository.archiveRecord(id);

  Future<void> restoreRecord(String id) => _repository.restoreRecord(id);

  Future<void> deleteRecord(String id) => _repository.deleteRecord(id);

  Future<SpaceRecordLink> linkRecord(SpaceRecordLinkDraft draft) {
    return _repository.linkRecord(draft);
  }

  Future<void> deleteRecordLink(String id) {
    return _repository.deleteRecordLink(id);
  }

  Future<SpaceSavedFilter> createSavedFilter(SpaceSavedFilterDraft draft) {
    return _repository.createSavedFilter(draft);
  }

  Future<void> deleteSavedFilter(String id) {
    return _repository.deleteSavedFilter(id);
  }

  Future<SpaceSavedView> createSavedView(SpaceSavedViewDraft draft) {
    return _repository.createSavedView(draft);
  }

  Future<void> deleteSavedView(String id) {
    return _repository.deleteSavedView(id);
  }
}

final spacesControllerProvider = Provider<SpacesController>((ref) {
  return SpacesController(ref.watch(spacesRepositoryProvider));
});

final spacesSnapshotProvider = StreamProvider<SpacesSnapshot>((ref) {
  return ref.watch(spacesRepositoryProvider).watchSpaces();
});
