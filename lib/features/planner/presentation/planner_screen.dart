import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/foundation_states.dart';
import '../../tasks/application/task_core_controller.dart';
import '../../tasks/domain/task_core_models.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(taskCoreSnapshotProvider);

    return snapshot.when(
      loading: () =>
          const FoundationLoadingState(message: 'Loading planner tasks'),
      error: (error, stackTrace) => FoundationErrorState(
        title: 'Planner could not load',
        message: 'Try again to reload tasks, tags, and notes.',
        actionLabel: 'Try again',
        onRetry: () => ref.invalidate(taskCoreSnapshotProvider),
      ),
      data: (data) => _PlannerContent(snapshot: data),
    );
  }
}

class _PlannerContent extends ConsumerWidget {
  const _PlannerContent({required this.snapshot});

  final TaskCoreSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeTasks = snapshot.tasks.where((task) => !task.isArchived).length;
    final completedTasks = snapshot.tasks
        .where((task) => task.isCompleted)
        .length;

    return ListView(
      key: const ValueKey('plannerTaskCoreContent'),
      padding: const EdgeInsets.all(AppSpacing.x4),
      children: [
        Text(
          'Planner',
          key: const ValueKey('plannerDestinationTitle'),
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          '$activeTasks active tasks, $completedTasks completed',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        _CreateActions(snapshot: snapshot),
        const SizedBox(height: AppSpacing.x4),
        if (snapshot.isEmpty)
          const FoundationEmptyState(
            title: 'No task-core records yet',
            message:
                'Create a task, tag, or note to start organizing execution.',
            icon: Icons.checklist_outlined,
          )
        else ...[
          _RecordSection(
            title: 'Tasks',
            emptyMessage: 'No tasks yet.',
            children: [
              for (final task in snapshot.tasks)
                Card(
                  child: ListTile(
                    leading: Icon(
                      task.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      task.isArchived
                          ? 'Archived task'
                          : 'Status: ${task.status.name}; ${snapshot.entityTags.where((entityTag) => entityTag.entityType == 'task' && entityTag.entityId == task.id).length} tags, ${snapshot.noteLinks.where((link) => link.entityType == 'task' && link.entityId == task.id).length} notes',
                    ),
                    trailing: Wrap(
                      spacing: AppSpacing.x1,
                      children: [
                        IconButton(
                          tooltip: 'Edit ${task.title}',
                          onPressed: () => _showTaskCoreTextDialog(
                            context: context,
                            title: 'Edit task',
                            label: 'Task title',
                            initialValue: task.title,
                            onSubmit: (title) => ref
                                .read(taskCoreControllerProvider)
                                .updateTask(
                                  task.id,
                                  TaskDraft(
                                    title: title,
                                    description: task.description,
                                    areaId: task.areaId,
                                    goalId: task.goalId,
                                    projectId: task.projectId,
                                    milestoneId: task.milestoneId,
                                    status: task.status,
                                    priority: task.priority,
                                    energyRequirement: task.energyRequirement,
                                    estimatedDurationMinutes:
                                        task.estimatedDurationMinutes,
                                    actualDurationMinutes:
                                        task.actualDurationMinutes,
                                    dueAt: task.dueAt,
                                    scheduledStartAt: task.scheduledStartAt,
                                    scheduledEndAt: task.scheduledEndAt,
                                    preferredTimeOfDay: task.preferredTimeOfDay,
                                    completedAt: task.completedAt,
                                    parentTaskId: task.parentTaskId,
                                    notes: task.notes,
                                  ),
                                ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        if (!task.isCompleted)
                          IconButton(
                            tooltip: 'Complete ${task.title}',
                            onPressed: () => ref
                                .read(taskCoreControllerProvider)
                                .completeTask(task.id),
                            icon: const Icon(Icons.done),
                          ),
                        IconButton(
                          tooltip: task.isArchived
                              ? 'Restore ${task.title}'
                              : 'Archive ${task.title}',
                          onPressed: task.isArchived
                              ? () => ref
                                    .read(taskCoreControllerProvider)
                                    .restoreTask(task.id)
                              : () => ref
                                    .read(taskCoreControllerProvider)
                                    .archiveTask(task.id),
                          icon: Icon(
                            task.isArchived
                                ? Icons.unarchive_outlined
                                : Icons.archive_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          _RecordSection(
            title: 'Tags',
            emptyMessage: 'No tags yet.',
            children: [
              for (final tag in snapshot.tags)
                ListTile(
                  leading: const Icon(Icons.sell_outlined),
                  title: Text(tag.name),
                  subtitle: Text(
                    tag.isArchived
                        ? 'Archived tag'
                        : 'Used on ${snapshot.entityTags.where((entityTag) => entityTag.tagId == tag.id).length} records',
                  ),
                  trailing: Wrap(
                    spacing: AppSpacing.x1,
                    children: [
                      IconButton(
                        tooltip: 'Edit ${tag.name}',
                        onPressed: () => _showTaskCoreTextDialog(
                          context: context,
                          title: 'Edit tag',
                          label: 'Tag name',
                          initialValue: tag.name,
                          onSubmit: (name) => ref
                              .read(taskCoreControllerProvider)
                              .updateTag(tag.id, TagDraft(name: name)),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: tag.isArchived
                            ? 'Restore ${tag.name}'
                            : 'Archive ${tag.name}',
                        onPressed: tag.isArchived
                            ? () => ref
                                  .read(taskCoreControllerProvider)
                                  .restoreTag(tag.id)
                            : () => ref
                                  .read(taskCoreControllerProvider)
                                  .archiveTag(tag.id),
                        icon: Icon(
                          tag.isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          _RecordSection(
            title: 'Notes',
            emptyMessage: 'No notes yet.',
            children: [
              for (final note in snapshot.notes)
                ListTile(
                  leading: const Icon(Icons.note_outlined),
                  title: Text(note.title),
                  subtitle: Text(
                    note.isArchived
                        ? 'Archived note'
                        : '${note.isPinned ? 'Pinned note' : 'Note'}; linked to ${snapshot.noteLinks.where((link) => link.noteId == note.id).length} records',
                  ),
                  trailing: Wrap(
                    spacing: AppSpacing.x1,
                    children: [
                      IconButton(
                        tooltip: 'Edit ${note.title}',
                        onPressed: () => _showTaskCoreTextDialog(
                          context: context,
                          title: 'Edit note',
                          label: 'Note title',
                          initialValue: note.title,
                          onSubmit: (title) => ref
                              .read(taskCoreControllerProvider)
                              .updateNote(
                                note.id,
                                NoteDraft(
                                  title: title,
                                  content: note.content,
                                  contentFormat: note.contentFormat,
                                  isPinned: note.isPinned,
                                ),
                              ),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: note.isArchived
                            ? 'Restore ${note.title}'
                            : 'Archive ${note.title}',
                        onPressed: note.isArchived
                            ? () => ref
                                  .read(taskCoreControllerProvider)
                                  .restoreNote(note.id)
                            : () => ref
                                  .read(taskCoreControllerProvider)
                                  .archiveNote(note.id),
                        icon: Icon(
                          note.isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

Future<void> _showTaskCoreTextDialog({
  required BuildContext context,
  required String title,
  required String label,
  required String initialValue,
  required Future<Object?> Function(String value) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _TextEntryDialog(
      title: title,
      label: label,
      actionLabel: 'Save',
      initialValue: initialValue,
      onSubmit: onSubmit,
    ),
  );
}

class _CreateActions extends ConsumerWidget {
  const _CreateActions({required this.snapshot});

  final TaskCoreSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(taskCoreControllerProvider);

    return Wrap(
      spacing: AppSpacing.x2,
      runSpacing: AppSpacing.x2,
      children: [
        FilledButton.icon(
          key: const ValueKey('createTaskButton'),
          onPressed: () => _showTextDialog(
            context: context,
            title: 'Create task',
            label: 'Task title',
            actionLabel: 'Create',
            onSubmit: (title) => controller.createTask(TaskDraft(title: title)),
          ),
          icon: const Icon(Icons.add_task),
          label: const Text('Task'),
        ),
        FilledButton.icon(
          key: const ValueKey('createTagButton'),
          onPressed: () => _showTextDialog(
            context: context,
            title: 'Create tag',
            label: 'Tag name',
            actionLabel: 'Create',
            onSubmit: (name) => controller.createTag(TagDraft(name: name)),
          ),
          icon: const Icon(Icons.sell_outlined),
          label: const Text('Tag'),
        ),
        FilledButton.icon(
          key: const ValueKey('createNoteButton'),
          onPressed: () => _showTextDialog(
            context: context,
            title: 'Create note',
            label: 'Note title',
            actionLabel: 'Create',
            onSubmit: (title) =>
                controller.createNote(NoteDraft(title: title, content: '')),
          ),
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('Note'),
        ),
        FilledButton.icon(
          key: const ValueKey('tagFirstTaskButton'),
          onPressed: snapshot.tasks.isEmpty || snapshot.tags.isEmpty
              ? null
              : () => controller.tagEntity(
                  entityType: 'task',
                  entityId: snapshot.tasks.first.id,
                  tagId: snapshot.tags.first.id,
                ),
          icon: const Icon(Icons.label_outline),
          label: const Text('Tag first task'),
        ),
        FilledButton.icon(
          key: const ValueKey('linkFirstNoteButton'),
          onPressed: snapshot.tasks.isEmpty || snapshot.notes.isEmpty
              ? null
              : () => controller.linkNote(
                  noteId: snapshot.notes.first.id,
                  entityType: 'task',
                  entityId: snapshot.tasks.first.id,
                ),
          icon: const Icon(Icons.link),
          label: const Text('Link first note'),
        ),
      ],
    );
  }

  Future<void> _showTextDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String actionLabel,
    String initialValue = '',
    required Future<Object?> Function(String value) onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _TextEntryDialog(
        title: title,
        label: label,
        actionLabel: actionLabel,
        initialValue: initialValue,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _TextEntryDialog extends StatefulWidget {
  const _TextEntryDialog({
    required this.title,
    required this.label,
    required this.actionLabel,
    required this.initialValue,
    required this.onSubmit,
  });

  final String title;
  final String label;
  final String actionLabel;
  final String initialValue;
  final Future<Object?> Function(String value) onSubmit;

  @override
  State<_TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<_TextEntryDialog> {
  late final TextEditingController _textController;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
    _canSubmit = widget.initialValue.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textController,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.label),
        onChanged: (value) {
          setState(() => _canSubmit = value.trim().isNotEmpty);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSubmit ? () => _submit(_textController.text) : null,
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }

  Future<void> _submit(String value) async {
    await widget.onSubmit(value);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _RecordSection extends StatelessWidget {
  const _RecordSection({
    required this.title,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.x2),
          if (children.isEmpty)
            Text(
              emptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}
