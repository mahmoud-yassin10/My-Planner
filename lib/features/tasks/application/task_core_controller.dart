import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift_task_core_repository.dart';
import '../domain/task_core_models.dart';
import '../domain/task_core_repository.dart';

final taskCoreSnapshotProvider = StreamProvider<TaskCoreSnapshot>((ref) {
  return ref.watch(taskCoreRepositoryProvider).watchTaskCore();
});

final taskCoreControllerProvider = Provider<TaskCoreController>((ref) {
  return TaskCoreController(ref.watch(taskCoreRepositoryProvider));
});

class TaskCoreController {
  const TaskCoreController(this._repository);

  final TaskCoreRepository _repository;

  Future<TaskItem> createTask(TaskDraft draft) => _repository.createTask(draft);

  Future<TaskItem> updateTask(String id, TaskDraft draft) {
    return _repository.updateTask(id, draft);
  }

  Future<void> completeTask(String id) => _repository.completeTask(id);

  Future<void> archiveTask(String id) => _repository.archiveTask(id);

  Future<void> restoreTask(String id) => _repository.restoreTask(id);

  Future<Tag> createTag(TagDraft draft) => _repository.createTag(draft);

  Future<Tag> updateTag(String id, TagDraft draft) {
    return _repository.updateTag(id, draft);
  }

  Future<void> archiveTag(String id) => _repository.archiveTag(id);

  Future<void> restoreTag(String id) => _repository.restoreTag(id);

  Future<EntityTag> tagEntity({
    required String entityType,
    required String entityId,
    required String tagId,
  }) {
    return _repository.tagEntity(
      entityType: entityType,
      entityId: entityId,
      tagId: tagId,
    );
  }

  Future<Note> createNote(NoteDraft draft) => _repository.createNote(draft);

  Future<Note> updateNote(String id, NoteDraft draft) {
    return _repository.updateNote(id, draft);
  }

  Future<void> archiveNote(String id) => _repository.archiveNote(id);

  Future<void> restoreNote(String id) => _repository.restoreNote(id);

  Future<NoteLink> linkNote({
    required String noteId,
    required String entityType,
    required String entityId,
  }) {
    return _repository.linkNote(
      noteId: noteId,
      entityType: entityType,
      entityId: entityId,
    );
  }
}
