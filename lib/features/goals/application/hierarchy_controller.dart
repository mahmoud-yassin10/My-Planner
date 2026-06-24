import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift_hierarchy_repository.dart';
import '../domain/hierarchy_models.dart';
import '../domain/hierarchy_repository.dart';

final hierarchySnapshotProvider = StreamProvider<HierarchySnapshot>((ref) {
  return ref.watch(hierarchyRepositoryProvider).watchHierarchy();
});

final hierarchyControllerProvider = Provider<HierarchyController>((ref) {
  return HierarchyController(ref.watch(hierarchyRepositoryProvider));
});

class HierarchyController {
  const HierarchyController(this._repository);

  final HierarchyRepository _repository;

  Future<Area> createArea(AreaDraft draft) => _repository.createArea(draft);

  Future<Goal> createGoal(GoalDraft draft) => _repository.createGoal(draft);

  Future<Project> createProject(ProjectDraft draft) {
    return _repository.createProject(draft);
  }

  Future<Milestone> createMilestone(MilestoneDraft draft) {
    return _repository.createMilestone(draft);
  }

  Future<void> archiveArea(String id) => _repository.archiveArea(id);

  Future<void> archiveGoal(String id) => _repository.archiveGoal(id);

  Future<void> archiveProject(String id) => _repository.archiveProject(id);

  Future<void> archiveMilestone(String id) {
    return _repository.archiveMilestone(id);
  }
}
