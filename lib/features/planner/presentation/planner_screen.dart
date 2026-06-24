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
                          : 'Status: ${task.status.name}',
                    ),
                    trailing: task.isCompleted
                        ? null
                        : IconButton(
                            tooltip: 'Complete ${task.title}',
                            onPressed: () => ref
                                .read(taskCoreControllerProvider)
                                .completeTask(task.id),
                            icon: const Icon(Icons.done),
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
                    tag.isArchived ? 'Archived tag' : 'Active tag',
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
                  subtitle: Text(note.isPinned ? 'Pinned note' : 'Note'),
                ),
            ],
          ),
        ],
      ],
    );
  }
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
            onSubmit: (title) =>
                controller.createNote(NoteDraft(title: title, content: '')),
          ),
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('Note'),
        ),
      ],
    );
  }

  Future<void> _showTextDialog({
    required BuildContext context,
    required String title,
    required String label,
    required Future<Object?> Function(String value) onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) =>
          _TextEntryDialog(title: title, label: label, onSubmit: onSubmit),
    );
  }
}

class _TextEntryDialog extends StatefulWidget {
  const _TextEntryDialog({
    required this.title,
    required this.label,
    required this.onSubmit,
  });

  final String title;
  final String label;
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
    _textController = TextEditingController();
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
          child: const Text('Create'),
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
