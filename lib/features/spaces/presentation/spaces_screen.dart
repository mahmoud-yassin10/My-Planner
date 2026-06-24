import 'dart:convert';

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

class _SpacesContent extends StatefulWidget {
  const _SpacesContent({required this.snapshot});

  final SpacesSnapshot snapshot;

  @override
  State<_SpacesContent> createState() => _SpacesContentState();
}

class _SpacesContentState extends State<_SpacesContent> {
  String? _selectedViewId;

  SpacesSnapshot get snapshot => widget.snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeViews = snapshot.views;
    final selectedView = activeViews.isEmpty
        ? null
        : _selectedView(activeViews);

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
                if (activeViews.isNotEmpty) ...[
                  _ViewSelector(
                    views: activeViews,
                    selectedViewId: selectedView!.id,
                    onSelected: (id) => setState(() {
                      _selectedViewId = id;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  _SavedViewPreview(snapshot: snapshot, view: selectedView),
                  const SizedBox(height: AppSpacing.x6),
                ],
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

  SpaceSavedView _selectedView(List<SpaceSavedView> views) {
    return views.firstWhere(
      (view) => view.id == _selectedViewId,
      orElse: () => views.first,
    );
  }
}

class _ViewSelector extends StatelessWidget {
  const _ViewSelector({
    required this.views,
    required this.selectedViewId,
    required this.onSelected,
  });

  final List<SpaceSavedView> views;
  final String selectedViewId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Saved Space views',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved views', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.x3),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              for (final view in views)
                ChoiceChip(
                  label: Text(view.name),
                  tooltip: 'Show ${view.name}',
                  selected: view.id == selectedViewId,
                  onSelected: (_) => onSelected(view.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedViewPreview extends StatelessWidget {
  const _SavedViewPreview({required this.snapshot, required this.view});

  final SpacesSnapshot snapshot;
  final SpaceSavedView view;

  @override
  Widget build(BuildContext context) {
    final config = _ParsedViewConfig.fromJson(view.configJson);
    final records = _recordsFor(config);
    final fields = _fieldsFor(config);

    return Semantics(
      container: true,
      label: '${view.name} ${view.viewType.name} view',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SavedViewHeader(view: view, recordCount: records.length),
          const SizedBox(height: AppSpacing.x3),
          if (records.isEmpty)
            const FoundationEmptyState(
              title: 'No records in this view',
              message: 'Records matching this saved view will appear here.',
            )
          else
            switch (view.viewType) {
              SpaceViewType.list => _ListSpaceView(
                records: records,
                fields: fields,
                statuses: snapshot.statuses,
              ),
              SpaceViewType.table => _TableSpaceView(
                records: records,
                fields: fields,
                statuses: snapshot.statuses,
              ),
              SpaceViewType.board => _BoardSpaceView(
                records: records,
                statuses: snapshot.statuses,
              ),
              SpaceViewType.cards => _CardsSpaceView(
                records: records,
                fields: fields,
                statuses: snapshot.statuses,
              ),
            },
        ],
      ),
    );
  }

  List<SpaceRecord> _recordsFor(_ParsedViewConfig config) {
    final filtered = snapshot.records.where((record) {
      final type = snapshot.recordTypes
          .where((type) => type.id == record.recordTypeId)
          .firstOrNull;
      if (type == null || type.spaceId != view.spaceId) {
        return false;
      }
      return config.recordTypeId == null ||
          config.recordTypeId == record.recordTypeId;
    }).toList();

    if (config.sortFieldKey == null) {
      filtered.sort((left, right) => left.title.compareTo(right.title));
      return filtered;
    }

    filtered.sort((left, right) {
      final leftValue = _fieldValues(left)[config.sortFieldKey].toString();
      final rightValue = _fieldValues(right)[config.sortFieldKey].toString();
      return leftValue.compareTo(rightValue);
    });
    return filtered;
  }

  List<SpaceFieldDefinition> _fieldsFor(_ParsedViewConfig config) {
    final fields = snapshot.fields.where((field) {
      final type = snapshot.recordTypes
          .where((type) => type.id == field.recordTypeId)
          .firstOrNull;
      if (type == null || type.spaceId != view.spaceId) {
        return false;
      }
      if (config.recordTypeId != null &&
          field.recordTypeId != config.recordTypeId) {
        return false;
      }
      return config.visibleFieldKeys.isEmpty ||
          config.visibleFieldKeys.contains(field.fieldKey);
    }).toList();
    fields.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return fields;
  }
}

class _SavedViewHeader extends StatelessWidget {
  const _SavedViewHeader({required this.view, required this.recordCount});

  final SpaceSavedView view;
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.view_agenda_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.x2),
        Expanded(
          child: Text(
            view.name,
            key: const ValueKey('selectedSpaceViewTitle'),
            style: theme.textTheme.titleLarge,
          ),
        ),
        Text(
          '${view.viewType.name} · $recordCount records',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ListSpaceView extends StatelessWidget {
  const _ListSpaceView({
    required this.records,
    required this.fields,
    required this.statuses,
  });

  final List<SpaceRecord> records;
  final List<SpaceFieldDefinition> fields;
  final List<SpaceStatusDefinition> statuses;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final record in records)
          _SpaceCard(
            title: record.title,
            subtitle: _recordSummary(record, fields),
            trailing: _statusLabel(record, statuses),
          ),
      ],
    );
  }
}

class _TableSpaceView extends StatelessWidget {
  const _TableSpaceView({
    required this.records,
    required this.fields,
    required this.statuses,
  });

  final List<SpaceRecord> records;
  final List<SpaceFieldDefinition> fields;
  final List<SpaceStatusDefinition> statuses;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Record')),
          const DataColumn(label: Text('Status')),
          for (final field in fields.take(4))
            DataColumn(label: Text(field.name)),
        ],
        rows: [
          for (final record in records)
            DataRow(
              cells: [
                DataCell(Text(record.title)),
                DataCell(Text(_statusLabel(record, statuses))),
                for (final field in fields.take(4))
                  DataCell(Text(_fieldText(record, field))),
              ],
            ),
        ],
      ),
    );
  }
}

class _BoardSpaceView extends StatelessWidget {
  const _BoardSpaceView({required this.records, required this.statuses});

  final List<SpaceRecord> records;
  final List<SpaceStatusDefinition> statuses;

  @override
  Widget build(BuildContext context) {
    final groupedStatuses = statuses.where((status) {
      return records.any((record) => record.statusId == status.id);
    }).toList();
    final lanes = groupedStatuses.isEmpty
        ? [('Open', records)]
        : [
            for (final status in groupedStatuses)
              (
                status.name,
                records
                    .where((record) => record.statusId == status.id)
                    .toList(),
              ),
            if (records.any((record) => record.statusId == null))
              (
                'Open',
                records.where((record) => record.statusId == null).toList(),
              ),
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final lane in lanes)
            SizedBox(
              width: 240,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.x3),
                child: _BoardLane(title: lane.$1, records: lane.$2),
              ),
            ),
        ],
      ),
    );
  }
}

class _BoardLane extends StatelessWidget {
  const _BoardLane({required this.title, required this.records});

  final String title;
  final List<SpaceRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.x2),
            for (final record in records)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                child: ListTile(
                  tileColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  title: Text(record.title),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardsSpaceView extends StatelessWidget {
  const _CardsSpaceView({
    required this.records,
    required this.fields,
    required this.statuses,
  });

  final List<SpaceRecord> records;
  final List<SpaceFieldDefinition> fields;
  final List<SpaceStatusDefinition> statuses;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.x3,
          mainAxisSpacing: AppSpacing.x3,
          childAspectRatio: 2.4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final record in records)
              _SpaceCard(
                title: record.title,
                subtitle: _recordSummary(record, fields),
                trailing: _statusLabel(record, statuses),
              ),
          ],
        );
      },
    );
  }
}

class _ParsedViewConfig {
  const _ParsedViewConfig({
    this.recordTypeId,
    this.visibleFieldKeys = const [],
    this.sortFieldKey,
  });

  final String? recordTypeId;
  final List<String> visibleFieldKeys;
  final String? sortFieldKey;

  factory _ParsedViewConfig.fromJson(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      return const _ParsedViewConfig();
    }
    final visibleFieldKeys = decoded['visibleFieldKeys'];
    return _ParsedViewConfig(
      recordTypeId: decoded['recordTypeId'] is String
          ? decoded['recordTypeId'] as String
          : null,
      visibleFieldKeys: visibleFieldKeys is List
          ? visibleFieldKeys.whereType<String>().toList()
          : const [],
      sortFieldKey: decoded['sortFieldKey'] is String
          ? decoded['sortFieldKey'] as String
          : null,
    );
  }
}

String _recordSummary(SpaceRecord record, List<SpaceFieldDefinition> fields) {
  final values = _fieldValues(record);
  final parts = <String>[
    for (final field in fields.take(3))
      if (values[field.fieldKey] != null)
        '${field.name}: ${values[field.fieldKey]}',
  ];
  return parts.isEmpty ? 'Space record' : parts.join(' · ');
}

String _fieldText(SpaceRecord record, SpaceFieldDefinition field) {
  return _fieldValues(record)[field.fieldKey]?.toString() ?? '';
}

Map<String, Object?> _fieldValues(SpaceRecord record) {
  final decoded = jsonDecode(record.fieldsJson);
  if (decoded is Map<String, Object?>) {
    return decoded;
  }
  return const {};
}

String _statusLabel(SpaceRecord record, List<SpaceStatusDefinition> statuses) {
  final status = statuses
      .where((status) => status.id == record.statusId)
      .firstOrNull;
  return status?.name ?? 'Open';
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
