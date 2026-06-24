import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/foundation_states.dart';
import '../application/hierarchy_controller.dart';
import '../domain/hierarchy_models.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(hierarchySnapshotProvider);

    return snapshot.when(
      loading: () =>
          const FoundationLoadingState(message: 'Loading goals and projects'),
      error: (error, stackTrace) => FoundationErrorState(
        title: 'Goals could not load',
        message: 'Try again to reload the hierarchy.',
        actionLabel: 'Try again',
        onRetry: () => ref.invalidate(hierarchySnapshotProvider),
      ),
      data: (data) => _HierarchyContent(snapshot: data),
    );
  }
}

class _HierarchyContent extends ConsumerWidget {
  const _HierarchyContent({required this.snapshot});

  final HierarchySnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      key: const ValueKey('goalsHierarchyContent'),
      padding: const EdgeInsets.all(AppSpacing.x4),
      children: [
        _Header(snapshot: snapshot),
        const SizedBox(height: AppSpacing.x4),
        _CreateActions(snapshot: snapshot),
        const SizedBox(height: AppSpacing.x4),
        if (snapshot.isEmpty)
          const FoundationEmptyState(
            title: 'No hierarchy records yet',
            message:
                'Create an area, goal, project, or milestone to start shaping the core structure.',
            icon: Icons.flag_outlined,
          )
        else ...[
          _AreaSection(snapshot: snapshot),
          _GoalSection(snapshot: snapshot),
          _ProjectSection(snapshot: snapshot),
          _MilestoneSection(snapshot: snapshot),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.snapshot});

  final HierarchySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeGoals = snapshot.goals.where((goal) => !goal.isArchived).length;
    final activeProjects = snapshot.projects
        .where((project) => !project.isArchived)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals',
          key: const ValueKey('goalsDestinationTitle'),
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          '$activeGoals active goals, $activeProjects active projects',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CreateActions extends ConsumerWidget {
  const _CreateActions({required this.snapshot});

  final HierarchySnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(hierarchyControllerProvider);

    return Wrap(
      spacing: AppSpacing.x2,
      runSpacing: AppSpacing.x2,
      children: [
        FilledButton.icon(
          key: const ValueKey('createAreaButton'),
          onPressed: () => _showTextDialog(
            context: context,
            title: 'Create area',
            label: 'Area name',
            actionLabel: 'Create',
            onSubmit: (name) => controller.createArea(AreaDraft(name: name)),
          ),
          icon: const Icon(Icons.layers_outlined),
          label: const Text('Area'),
        ),
        FilledButton.icon(
          key: const ValueKey('createGoalButton'),
          onPressed: () => _showTextDialog(
            context: context,
            title: 'Create goal',
            label: 'Goal title',
            actionLabel: 'Create',
            onSubmit: (title) => controller.createGoal(
              GoalDraft(title: title, areaId: snapshot.areas.firstOrNull?.id),
            ),
          ),
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Goal'),
        ),
        FilledButton.icon(
          key: const ValueKey('createProjectButton'),
          onPressed: () => _showTextDialog(
            context: context,
            title: 'Create project',
            label: 'Project title',
            actionLabel: 'Create',
            onSubmit: (title) => controller.createProject(
              ProjectDraft(
                title: title,
                areaId: snapshot.areas.firstOrNull?.id,
                goalId: snapshot.goals.firstOrNull?.id,
              ),
            ),
          ),
          icon: const Icon(Icons.account_tree_outlined),
          label: const Text('Project'),
        ),
        FilledButton.icon(
          key: const ValueKey('createMilestoneButton'),
          onPressed: snapshot.goals.isEmpty && snapshot.projects.isEmpty
              ? null
              : () => _showTextDialog(
                  context: context,
                  title: 'Create milestone',
                  label: 'Milestone title',
                  actionLabel: 'Create',
                  onSubmit: (title) => controller.createMilestone(
                    MilestoneDraft(
                      title: title,
                      goalId: snapshot.goals.firstOrNull?.id,
                      projectId: snapshot.goals.isEmpty
                          ? snapshot.projects.firstOrNull?.id
                          : null,
                    ),
                  ),
                ),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Milestone'),
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
  }) async {
    await showDialog<void>(
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
        textInputAction: TextInputAction.done,
        onChanged: (value) {
          setState(() => _canSubmit = value.trim().isNotEmpty);
        },
        onSubmitted: _canSubmit ? _submit : null,
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

class _AreaSection extends StatelessWidget {
  const _AreaSection({required this.snapshot});

  final HierarchySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Areas',
      emptyMessage: 'No areas yet.',
      children: [
        for (final area in snapshot.areas)
          _HierarchyTile(
            title: area.name,
            subtitle: area.isArchived
                ? 'Archived area'
                : '${snapshot.goals.where((goal) => goal.areaId == area.id).length} goals, ${snapshot.projects.where((project) => project.areaId == area.id).length} projects',
            icon: Icons.layers_outlined,
            archived: area.isArchived,
            onEdit: () => _showHierarchyTextDialog(
              context: context,
              title: 'Edit area',
              label: 'Area name',
              initialValue: area.name,
              onSubmit: (name) => context.readHierarchyController().updateArea(
                area.id,
                AreaDraft(name: name),
              ),
            ),
            onArchive: () =>
                context.readHierarchyController().archiveArea(area.id),
            onRestore: () =>
                context.readHierarchyController().restoreArea(area.id),
          ),
      ],
    );
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.snapshot});

  final HierarchySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Goals',
      emptyMessage: 'No goals yet.',
      children: [
        for (final goal in snapshot.goals)
          _HierarchyTile(
            title: goal.title,
            subtitle: goal.isArchived
                ? 'Archived goal'
                : 'Status: ${goal.status.name}; ${snapshot.projects.where((project) => project.goalId == goal.id).length} projects, ${snapshot.milestones.where((milestone) => milestone.goalId == goal.id).length} milestones',
            icon: Icons.flag_outlined,
            archived: goal.isArchived,
            onEdit: () => _showHierarchyTextDialog(
              context: context,
              title: 'Edit goal',
              label: 'Goal title',
              initialValue: goal.title,
              onSubmit: (title) => context.readHierarchyController().updateGoal(
                goal.id,
                GoalDraft(
                  title: title,
                  description: goal.description,
                  areaId: goal.areaId,
                  parentGoalId: goal.parentGoalId,
                  goalType: goal.goalType,
                  timeHorizon: goal.timeHorizon,
                  measurementType: goal.measurementType,
                  targetValue: goal.targetValue,
                  currentValue: goal.currentValue,
                  unit: goal.unit,
                  startAt: goal.startAt,
                  deadlineAt: goal.deadlineAt,
                  priority: goal.priority,
                  status: goal.status,
                  motivation: goal.motivation,
                  reviewFrequency: goal.reviewFrequency,
                  lastReviewAt: goal.lastReviewAt,
                  nextReviewAt: goal.nextReviewAt,
                  notes: goal.notes,
                  customFieldsJson: goal.customFieldsJson,
                ),
              ),
            ),
            onArchive: () =>
                context.readHierarchyController().archiveGoal(goal.id),
            onRestore: () =>
                context.readHierarchyController().restoreGoal(goal.id),
          ),
      ],
    );
  }
}

class _ProjectSection extends StatelessWidget {
  const _ProjectSection({required this.snapshot});

  final HierarchySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Projects',
      emptyMessage: 'No projects yet.',
      children: [
        for (final project in snapshot.projects)
          _HierarchyTile(
            title: project.title,
            subtitle: project.isArchived
                ? 'Archived project'
                : 'Status: ${project.status.name}; ${snapshot.milestones.where((milestone) => milestone.projectId == project.id).length} milestones',
            icon: Icons.account_tree_outlined,
            archived: project.isArchived,
            onEdit: () => _showHierarchyTextDialog(
              context: context,
              title: 'Edit project',
              label: 'Project title',
              initialValue: project.title,
              onSubmit: (title) =>
                  context.readHierarchyController().updateProject(
                    project.id,
                    ProjectDraft(
                      title: title,
                      areaId: project.areaId,
                      goalId: project.goalId,
                      status: project.status,
                      description: project.description,
                      startAt: project.startAt,
                      deadlineAt: project.deadlineAt,
                      progress: project.progress,
                      notes: project.notes,
                      customFieldsJson: project.customFieldsJson,
                    ),
                  ),
            ),
            onArchive: () =>
                context.readHierarchyController().archiveProject(project.id),
            onRestore: () =>
                context.readHierarchyController().restoreProject(project.id),
          ),
      ],
    );
  }
}

class _MilestoneSection extends StatelessWidget {
  const _MilestoneSection({required this.snapshot});

  final HierarchySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Milestones',
      emptyMessage: 'No milestones yet.',
      children: [
        for (final milestone in snapshot.milestones)
          _HierarchyTile(
            title: milestone.title,
            subtitle: milestone.isArchived
                ? 'Archived milestone'
                : 'Status: ${milestone.status.name}; ${milestone.goalId != null ? 'goal-linked' : 'project-linked'}',
            icon: Icons.check_circle_outline,
            archived: milestone.isArchived,
            onEdit: () => _showHierarchyTextDialog(
              context: context,
              title: 'Edit milestone',
              label: 'Milestone title',
              initialValue: milestone.title,
              onSubmit: (title) =>
                  context.readHierarchyController().updateMilestone(
                    milestone.id,
                    MilestoneDraft(
                      title: title,
                      description: milestone.description,
                      goalId: milestone.goalId,
                      projectId: milestone.projectId,
                      dueAt: milestone.dueAt,
                      status: milestone.status,
                      completedAt: milestone.completedAt,
                      sortOrder: milestone.sortOrder,
                      notes: milestone.notes,
                    ),
                  ),
            ),
            onArchive: () => context.readHierarchyController().archiveMilestone(
              milestone.id,
            ),
            onRestore: () => context.readHierarchyController().restoreMilestone(
              milestone.id,
            ),
          ),
      ],
    );
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

class _HierarchyTile extends StatelessWidget {
  const _HierarchyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.archived,
    required this.onEdit,
    required this.onArchive,
    required this.onRestore,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool archived;
  final VoidCallback onEdit;
  final Future<void> Function() onArchive;
  final Future<void> Function() onRestore;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Wrap(
          spacing: AppSpacing.x1,
          children: [
            IconButton(
              tooltip: 'Edit $title',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: archived ? 'Restore $title' : 'Archive $title',
              onPressed: archived ? onRestore : onArchive,
              icon: Icon(
                archived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showHierarchyTextDialog({
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

extension on BuildContext {
  HierarchyController readHierarchyController() {
    final container = ProviderScope.containerOf(this, listen: false);
    return container.read(hierarchyControllerProvider);
  }
}
