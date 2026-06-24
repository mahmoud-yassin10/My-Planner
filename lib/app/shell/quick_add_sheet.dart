import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const quickAddOptionLabels = [
  'Task',
  'Event',
  'Note',
  'Goal',
  'Project',
  'Space record',
];

Future<void> showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const QuickAddSheet(),
  );
}

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x6,
          AppSpacing.x2,
          AppSpacing.x6,
          AppSpacing.x6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Add',
                key: const ValueKey('quickAddTitle'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                'Creation flows will be added in a later phase.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              for (final label in quickAddOptionLabels)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_iconFor(label)),
                  title: Text(label),
                  enabled: false,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String label) {
    return switch (label) {
      'Task' => Icons.check_circle_outline,
      'Event' => Icons.event_outlined,
      'Note' => Icons.note_outlined,
      'Goal' => Icons.flag_outlined,
      'Project' => Icons.account_tree_outlined,
      'Space record' => Icons.table_rows_outlined,
      _ => Icons.add_circle_outline,
    };
  }
}
