enum TaskStatus {
  inbox,
  planned,
  inProgress,
  waiting,
  completed,
  postponed,
  cancelled,
}

enum TaskPriority { low, medium, high, critical }

enum TaskEnergyRequirement { low, normal, deepWork }

enum NoteContentFormat { plainText, markdown }

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    this.areaId,
    this.goalId,
    this.projectId,
    this.milestoneId,
    this.parentTaskId,
    required this.status,
    required this.priority,
    required this.energyRequirement,
    this.estimatedDurationMinutes,
    this.actualDurationMinutes,
    this.dueAt,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.preferredTimeOfDay,
    this.completedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? areaId;
  final String? goalId;
  final String? projectId;
  final String? milestoneId;
  final String? parentTaskId;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskEnergyRequirement energyRequirement;
  final int? estimatedDurationMinutes;
  final int? actualDurationMinutes;
  final DateTime? dueAt;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final String? preferredTimeOfDay;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
  bool get isCompleted => completedAt != null || status == TaskStatus.completed;
}

class Tag {
  const Tag({
    required this.id,
    required this.name,
    this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String name;
  final int? colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class EntityTag {
  const EntityTag({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.tagId,
    required this.createdAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String tagId;
  final DateTime createdAt;
}

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.contentFormat,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String content;
  final NoteContentFormat contentFormat;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class NoteLink {
  const NoteLink({
    required this.id,
    required this.noteId,
    required this.entityType,
    required this.entityId,
    required this.relationshipType,
    required this.createdAt,
  });

  final String id;
  final String noteId;
  final String entityType;
  final String entityId;
  final String relationshipType;
  final DateTime createdAt;
}

class TaskCoreSnapshot {
  const TaskCoreSnapshot({
    this.tasks = const [],
    this.tags = const [],
    this.entityTags = const [],
    this.notes = const [],
    this.noteLinks = const [],
  });

  final List<TaskItem> tasks;
  final List<Tag> tags;
  final List<EntityTag> entityTags;
  final List<Note> notes;
  final List<NoteLink> noteLinks;

  bool get isEmpty => tasks.isEmpty && tags.isEmpty && notes.isEmpty;
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    this.description,
    this.areaId,
    this.goalId,
    this.projectId,
    this.milestoneId,
    this.parentTaskId,
    this.status = TaskStatus.inbox,
    this.priority = TaskPriority.medium,
    this.energyRequirement = TaskEnergyRequirement.normal,
    this.estimatedDurationMinutes,
    this.actualDurationMinutes,
    this.dueAt,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.preferredTimeOfDay,
    this.completedAt,
    this.notes,
  });

  final String title;
  final String? description;
  final String? areaId;
  final String? goalId;
  final String? projectId;
  final String? milestoneId;
  final String? parentTaskId;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskEnergyRequirement energyRequirement;
  final int? estimatedDurationMinutes;
  final int? actualDurationMinutes;
  final DateTime? dueAt;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final String? preferredTimeOfDay;
  final DateTime? completedAt;
  final String? notes;
}

class TagDraft {
  const TagDraft({required this.name, this.colorValue});

  final String name;
  final int? colorValue;
}

class NoteDraft {
  const NoteDraft({
    required this.title,
    required this.content,
    this.contentFormat = NoteContentFormat.plainText,
    this.isPinned = false,
  });

  final String title;
  final String content;
  final NoteContentFormat contentFormat;
  final bool isPinned;
}
