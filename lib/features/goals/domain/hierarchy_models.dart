enum AreaStatus { active }

enum GoalStatus { draft, active, paused, completed }

enum ProjectStatus { planned, active, onHold, completed, cancelled }

enum MilestoneStatus { planned, active, completed, cancelled }

class Area {
  const Area({
    required this.id,
    required this.name,
    this.description,
    this.iconKey,
    this.colorValue,
    required this.status,
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
  final AreaStatus status;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class Goal {
  const Goal({
    required this.id,
    required this.title,
    this.description,
    this.areaId,
    this.parentGoalId,
    this.goalType,
    this.timeHorizon,
    this.measurementType,
    this.targetValue,
    this.currentValue,
    this.unit,
    this.startAt,
    this.deadlineAt,
    this.priority,
    required this.status,
    this.motivation,
    this.reviewFrequency,
    this.lastReviewAt,
    this.nextReviewAt,
    this.notes,
    this.customFieldsJson,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? areaId;
  final String? parentGoalId;
  final String? goalType;
  final String? timeHorizon;
  final String? measurementType;
  final double? targetValue;
  final double? currentValue;
  final String? unit;
  final DateTime? startAt;
  final DateTime? deadlineAt;
  final int? priority;
  final GoalStatus status;
  final String? motivation;
  final String? reviewFrequency;
  final DateTime? lastReviewAt;
  final DateTime? nextReviewAt;
  final String? notes;
  final String? customFieldsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class Project {
  const Project({
    required this.id,
    required this.title,
    this.description,
    this.areaId,
    this.goalId,
    required this.status,
    this.startAt,
    this.deadlineAt,
    this.progress,
    this.notes,
    this.customFieldsJson,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? areaId;
  final String? goalId;
  final ProjectStatus status;
  final DateTime? startAt;
  final DateTime? deadlineAt;
  final double? progress;
  final String? notes;
  final String? customFieldsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    this.description,
    this.goalId,
    this.projectId,
    this.dueAt,
    required this.status,
    this.completedAt,
    required this.sortOrder,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? goalId;
  final String? projectId;
  final DateTime? dueAt;
  final MilestoneStatus status;
  final DateTime? completedAt;
  final int sortOrder;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class HierarchySnapshot {
  const HierarchySnapshot({
    this.areas = const [],
    this.goals = const [],
    this.projects = const [],
    this.milestones = const [],
  });

  final List<Area> areas;
  final List<Goal> goals;
  final List<Project> projects;
  final List<Milestone> milestones;

  bool get isEmpty =>
      areas.isEmpty && goals.isEmpty && projects.isEmpty && milestones.isEmpty;
}

class AreaDraft {
  const AreaDraft({
    required this.name,
    this.description,
    this.iconKey,
    this.colorValue,
    this.status = AreaStatus.active,
    this.sortOrder = 0,
  });

  final String name;
  final String? description;
  final String? iconKey;
  final int? colorValue;
  final AreaStatus status;
  final int sortOrder;
}

class GoalDraft {
  const GoalDraft({
    required this.title,
    this.description,
    this.areaId,
    this.parentGoalId,
    this.goalType,
    this.timeHorizon,
    this.measurementType,
    this.targetValue,
    this.currentValue,
    this.unit,
    this.startAt,
    this.deadlineAt,
    this.priority,
    this.status = GoalStatus.active,
    this.motivation,
    this.reviewFrequency,
    this.lastReviewAt,
    this.nextReviewAt,
    this.notes,
    this.customFieldsJson,
  });

  final String title;
  final String? description;
  final String? areaId;
  final String? parentGoalId;
  final String? goalType;
  final String? timeHorizon;
  final String? measurementType;
  final double? targetValue;
  final double? currentValue;
  final String? unit;
  final DateTime? startAt;
  final DateTime? deadlineAt;
  final int? priority;
  final GoalStatus status;
  final String? motivation;
  final String? reviewFrequency;
  final DateTime? lastReviewAt;
  final DateTime? nextReviewAt;
  final String? notes;
  final String? customFieldsJson;
}

class ProjectDraft {
  const ProjectDraft({
    required this.title,
    this.description,
    this.areaId,
    this.goalId,
    this.status = ProjectStatus.planned,
    this.startAt,
    this.deadlineAt,
    this.progress,
    this.notes,
    this.customFieldsJson,
  });

  final String title;
  final String? description;
  final String? areaId;
  final String? goalId;
  final ProjectStatus status;
  final DateTime? startAt;
  final DateTime? deadlineAt;
  final double? progress;
  final String? notes;
  final String? customFieldsJson;
}

class MilestoneDraft {
  const MilestoneDraft({
    required this.title,
    this.description,
    this.goalId,
    this.projectId,
    this.dueAt,
    this.status = MilestoneStatus.planned,
    this.completedAt,
    this.sortOrder = 0,
    this.notes,
  });

  final String title;
  final String? description;
  final String? goalId;
  final String? projectId;
  final DateTime? dueAt;
  final MilestoneStatus status;
  final DateTime? completedAt;
  final int sortOrder;
  final String? notes;
}
