import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/foundation_states.dart';
import '../application/template_controller.dart';
import '../domain/template_models.dart';

class TemplatesFoundationPanel extends ConsumerWidget {
  const TemplatesFoundationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(templatesSnapshotProvider);

    return snapshot.when(
      loading: () => const FoundationLoadingState(message: 'Loading templates'),
      error: (error, stackTrace) => FoundationErrorState(
        title: 'Templates could not load',
        message: 'Try again to reload template infrastructure.',
        actionLabel: 'Try again',
        onRetry: () => ref.invalidate(templatesSnapshotProvider),
      ),
      data: (data) => _TemplatesContent(snapshot: data),
    );
  }
}

class _TemplatesContent extends StatelessWidget {
  const _TemplatesContent({required this.snapshot});

  final TemplatesSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Templates',
            key: const ValueKey('templatesFoundationTitle'),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            'Optional configurations remain removable and inactive until installed.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.x6),
          if (snapshot.isEmpty)
            const Expanded(
              child: FoundationEmptyState(
                title: 'No templates available',
                message: 'Template packs will be added in a later phase.',
                icon: Icons.dashboard_customize_outlined,
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  for (final definition in snapshot.definitions)
                    _TemplateDefinitionTile(
                      definition: definition,
                      isInstalled: snapshot.isInstalled(definition.key),
                    ),
                  if (snapshot.installations.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.x6),
                    Text(
                      'Installation history',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    for (final installation in snapshot.installations)
                      _TemplateInstallationTile(installation: installation),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TemplateDefinitionTile extends StatelessWidget {
  const _TemplateDefinitionTile({
    required this.definition,
    required this.isInstalled,
  });

  final TemplateDefinition definition;
  final bool isInstalled;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.extension_outlined),
        title: Text(definition.name),
        subtitle: Text(definition.description),
        trailing: Text(isInstalled ? 'Installed' : definition.version),
      ),
    );
  }
}

class _TemplateInstallationTile extends StatelessWidget {
  const _TemplateInstallationTile({required this.installation});

  final TemplateInstallation installation;

  @override
  Widget build(BuildContext context) {
    final choice = installation.uninstallChoice?.name;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(installation.templateKey),
        subtitle: Text(choice ?? installation.status.name),
        trailing: Text(installation.templateVersion),
      ),
    );
  }
}
