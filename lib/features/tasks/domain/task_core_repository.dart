import 'task_core_models.dart';

abstract interface class TaskCoreRepository {
  Stream<TaskCoreSnapshot> watchTaskCore();

  Future<TaskCoreSnapshot> current();

  Future<TaskItem> createTask(TaskDraft draft);
  Future<TaskItem> updateTask(String id, TaskDraft draft);
  Future<void> completeTask(String id);
  Future<void> archiveTask(String id);
  Future<void> restoreTask(String id);
  Future<void> deleteTask(String id);

  Future<Tag> createTag(TagDraft draft);
  Future<void> archiveTag(String id);
  Future<void> deleteTag(String id);
  Future<EntityTag> tagEntity({
    required String entityType,
    required String entityId,
    required String tagId,
  });

  Future<Note> createNote(NoteDraft draft);
  Future<void> archiveNote(String id);
  Future<void> deleteNote(String id);
  Future<NoteLink> linkNote({
    required String noteId,
    required String entityType,
    required String entityId,
    String relationshipType,
  });
}
