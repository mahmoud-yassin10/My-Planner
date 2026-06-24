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
          _AreaSection(areas: snapshot.areas),
          _GoalSection(goals: snapshot.goals),
          _ProjectSection(projects: snapshot.projects),
          _MilestoneSection(milestones: snapshot.milestones),
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
    required Future<Object?> Function(String value) onSubmit,
  }) async {
    await showDialog<void>(
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

class _AreaSection extends StatelessWidget {
  const _AreaSection({required this.areas});

  final List<Area> areas;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Areas',
      emptyMessage: 'No areas yet.',
      children: [
        for (final area in areas)
          _HierarchyTile(
            title: area.name,
            subtitle: area.isArchived ? 'Archived area' : 'Active area',
            icon: Icons.layers_outlined,
            archived: area.isArchived,
            onArchive: () =>
                context.readHierarchyController().archiveArea(area.id),
          ),
      ],
    );
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Goals',
      emptyMessage: 'No goals yet.',
      children: [
        for (final goal in goals)
          _HierarchyTile(
            title: goal.title,
            subtitle: goal.isArchived
                ? 'Archived goal'
                : 'Status: ${goal.status.name}',
            icon: Icons.flag_outlined,
            archived: goal.isArchived,
            onArchive: () =>
                context.readHierarchyController().archiveGoal(goal.id),
          ),
      ],
    );
  }
}

class _ProjectSection extends StatelessWidget {
  const _ProjectSection({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Projects',
      emptyMessage: 'No projects yet.',
      children: [
        for (final project in projects)
          _HierarchyTile(
            title: project.title,
            subtitle: project.isArchived
                ? 'Archived project'
                : 'Status: ${project.status.name}',
            icon: Icons.account_tree_outlined,
            archived: project.isArchived,
            onArchive: () =>
                context.readHierarchyController().archiveProject(project.id),
          ),
      ],
    );
  }
}

class _MilestoneSection extends StatelessWidget {
  const _MilestoneSection({required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    return _RecordSection(
      title: 'Milestones',
      emptyMessage: 'No milestones yet.',
      children: [
        for (final milestone in milestones)
          _HierarchyTile(
            title: milestone.title,
            subtitle: milestone.isArchived
                ? 'Archived milestone'
                : 'Status: ${milestone.status.name}',
            icon: Icons.check_circle_outline,
            archived: milestone.isArchived,
            onArchive: () => context.readHierarchyController().archiveMilestone(
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
    required this.onArchive,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool archived;
  final Future<void> Function() onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: archived
            ? const Icon(Icons.inventory_2_outlined)
            : IconButton(
                tooltip: 'Archive $title',
                onPressed: onArchive,
                icon: const Icon(Icons.archive_outlined),
              ),
      ),
    );
  }
}

extension on BuildContext {
  HierarchyController readHierarchyController() {
    final container = ProviderScope.containerOf(this, listen: false);
    return container.read(hierarchyControllerProvider);
  }
}
