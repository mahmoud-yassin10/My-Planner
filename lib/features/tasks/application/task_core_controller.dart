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

  Future<void> completeTask(String id) => _repository.completeTask(id);

  Future<void> archiveTask(String id) => _repository.archiveTask(id);

  Future<Tag> createTag(TagDraft draft) => _repository.createTag(draft);

  Future<Note> createNote(NoteDraft draft) => _repository.createNote(draft);
}
