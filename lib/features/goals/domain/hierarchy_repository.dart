import 'hierarchy_models.dart';

abstract interface class HierarchyRepository {
  Stream<HierarchySnapshot> watchHierarchy();

  Future<HierarchySnapshot> current();

  Future<Area> createArea(AreaDraft draft);
  Future<Area> updateArea(String id, AreaDraft draft);
  Future<void> archiveArea(String id);
  Future<void> restoreArea(String id);
  Future<void> deleteArea(String id);

  Future<Goal> createGoal(GoalDraft draft);
  Future<Goal> updateGoal(String id, GoalDraft draft);
  Future<void> archiveGoal(String id);
  Future<void> restoreGoal(String id);
  Future<void> deleteGoal(String id);

  Future<Project> createProject(ProjectDraft draft);
  Future<Project> updateProject(String id, ProjectDraft draft);
  Future<void> archiveProject(String id);
  Future<void> restoreProject(String id);
  Future<void> deleteProject(String id);

  Future<Milestone> createMilestone(MilestoneDraft draft);
  Future<Milestone> updateMilestone(String id, MilestoneDraft draft);
  Future<void> archiveMilestone(String id);
  Future<void> restoreMilestone(String id);
  Future<void> deleteMilestone(String id);
}
