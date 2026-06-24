import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift_planner_repository.dart';
import '../domain/planner_models.dart';
import '../domain/planner_repository.dart';

class PlannerController {
  const PlannerController(this._repository);

  final PlannerRepository _repository;

  Future<PlannerEvent> createEvent(PlannerEventDraft draft) {
    return _repository.createEvent(draft);
  }

  Future<PlannerEvent> updateEvent(String id, PlannerEventDraft draft) {
    return _repository.updateEvent(id, draft);
  }

  Future<void> archiveEvent(String id) => _repository.archiveEvent(id);

  Future<void> restoreEvent(String id) => _repository.restoreEvent(id);

  Future<TimeBlock> createTimeBlock(TimeBlockDraft draft) {
    return _repository.createTimeBlock(draft);
  }

  Future<TimeBlock> updateTimeBlock(String id, TimeBlockDraft draft) {
    return _repository.updateTimeBlock(id, draft);
  }

  Future<void> archiveTimeBlock(String id) => _repository.archiveTimeBlock(id);

  Future<void> restoreTimeBlock(String id) => _repository.restoreTimeBlock(id);

  Future<FocusSession> createFocusSession(FocusSessionDraft draft) {
    return _repository.createFocusSession(draft);
  }

  Future<FocusSession> updateFocusSession(String id, FocusSessionDraft draft) {
    return _repository.updateFocusSession(id, draft);
  }

  Future<void> archiveFocusSession(String id) {
    return _repository.archiveFocusSession(id);
  }

  Future<void> restoreFocusSession(String id) {
    return _repository.restoreFocusSession(id);
  }
}

final plannerControllerProvider = Provider<PlannerController>((ref) {
  return PlannerController(ref.watch(plannerRepositoryProvider));
});

final plannerSnapshotProvider = StreamProvider<PlannerSnapshot>((ref) {
  return ref.watch(plannerRepositoryProvider).watchPlanner();
});
