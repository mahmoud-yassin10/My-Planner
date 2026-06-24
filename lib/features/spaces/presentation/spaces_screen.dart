import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/foundation_states.dart';
import '../application/spaces_controller.dart';
import '../domain/spaces_models.dart';

class SpacesScreen extends ConsumerWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(spacesSnapshotProvider);

    return snapshot.when(
      loading: () => const FoundationLoadingState(message: 'Loading Spaces'),
      error: (error, stackTrace) => FoundationErrorState(
        title: 'Spaces could not load',
        message: 'Try again to reload Spaces.',
        actionLabel: 'Try again',
        onRetry: () => ref.invalidate(spacesSnapshotProvider),
      ),
      data: (data) => _SpacesContent(snapshot: data),
    );
  }
}

class _SpacesContent extends StatelessWidget {
  const _SpacesContent({required this.snapshot});

  final SpacesSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x6,
              AppSpacing.x6,
              AppSpacing.x6,
              AppSpacing.x2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.dashboard_customize_outlined,
                  color: theme.colorScheme.primary,
                  size: 36,
                ),
                const SizedBox(height: AppSpacing.x3),
                Text(
                  'Spaces',
                  key: const ValueKey('spacesDestinationTitle'),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  'Configure flexible workspaces without fixed assumptions.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.x4),
                Wrap(
                  spacing: AppSpacing.x2,
                  runSpacing: AppSpacing.x2,
                  children: const [
                    _FoundationActionChip(label: 'New Space'),
                    _FoundationActionChip(label: 'Record Type'),
                    _FoundationActionChip(label: 'Field'),
                    _FoundationActionChip(label: 'Status'),
                    _FoundationActionChip(label: 'Record'),
                    _FoundationActionChip(label: 'Filter'),
                    _FoundationActionChip(label: 'View'),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (snapshot.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: FoundationEmptyState(
              title: 'No Spaces yet',
              message: 'Generic Spaces records will appear here after setup.',
              icon: Icons.dashboard_customize_outlined,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.x6),
            sliver: SliverList.list(
              children: [
                _MetricGrid(snapshot: snapshot),
                const SizedBox(height: AppSpacing.x6),
                _SpacesSection(
                  title: 'Spaces',
                  emptyMessage: 'No Space definitions yet.',
                  children: [
                    for (final space in snapshot.spaces)
                      _SpaceCard(
                        title: space.name,
                        subtitle: space.description ?? 'Generic Space',
                        trailing: '${_countTypes(space.id)} types',
                      ),
                  ],
                ),
                _SpacesSection(
                  title: 'Record types',
                  emptyMessage: 'No record types yet.',
                  children: [
                    for (final type in snapshot.recordTypes)
                      _SpaceCard(
                        title: type.name,
                        subtitle: type.description ?? 'Configurable records',
                        trailing: '${_countFields(type.id)} fields',
                      ),
                  ],
                ),
                _SpacesSection(
                  title: 'Fields and statuses',
                  emptyMessage: 'No fields or statuses yet.',
                  children: [
                    for (final field in snapshot.fields)
                      _SpaceCard(
                        title: field.name,
                        subtitle: field.fieldKey,
                        trailing: field.fieldType.name,
                      ),
                    for (final status in snapshot.statuses)
                      _SpaceCard(
                        title: status.name,
                        subtitle: status.isDefault
                            ? 'Default status'
                            : 'Record status',
                        trailing: 'status',
                      ),
                  ],
                ),
                _SpacesSection(
                  title: 'Records and relationships',
                  emptyMessage: 'No records or relationships yet.',
                  children: [
                    for (final record in snapshot.records)
                      _SpaceCard(
                        title: record.title,
                        subtitle: 'Space record',
                        trailing: record.statusId == null ? 'open' : 'status',
                      ),
                    for (final link in snapshot.links)
                      _SpaceCard(
                        title: link.relationshipType,
                        subtitle: '${link.targetType}: ${link.targetId}',
                        trailing: 'link',
                      ),
                  ],
                ),
                _SpacesSection(
                  title: 'Saved filters and views',
                  emptyMessage: 'No saved filters or views yet.',
                  children: [
                    for (final filter in snapshot.filters)
                      _SpaceCard(
                        title: filter.name,
                        subtitle: 'Saved filter',
                        trailing: 'filter',
                      ),
                    for (final view in snapshot.views)
                      _SpaceCard(
                        title: view.name,
                        subtitle: 'Saved ${view.viewType.name} view',
                        trailing: 'view',
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  int _countTypes(String spaceId) {
    return snapshot.recordTypes.where((type) => type.spaceId == spaceId).length;
  }

  int _countFields(String recordTypeId) {
    return snapshot.fields
        .where((field) => field.recordTypeId == recordTypeId)
        .length;
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.snapshot});

  final SpacesSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Spaces', snapshot.spaces.length),
      ('Types', snapshot.recordTypes.length),
      ('Fields', snapshot.fields.length),
      ('Records', snapshot.records.length),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.x3,
          mainAxisSpacing: AppSpacing.x3,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final metric in metrics)
              _MetricTile(label: metric.$1, value: metric.$2),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$value', style: theme.textTheme.headlineSmall),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpacesSection extends StatelessWidget {
  const _SpacesSection({
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
      padding: const EdgeInsets.only(bottom: AppSpacing.x6),
      child: Semantics(
        container: true,
        header: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.x3),
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
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x2),
      child: Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Text(
            trailing,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _FoundationActionChip extends StatelessWidget {
  const _FoundationActionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 18),
      label: Text(label),
      tooltip: '$label foundation action',
      onPressed: () {},
    );
  }
}
