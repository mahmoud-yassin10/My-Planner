import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DestinationPlaceholder extends StatelessWidget {
  const DestinationPlaceholder({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x6),
            child: Semantics(
              header: true,
              label: '$title destination',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: theme.colorScheme.primary,
                        semanticLabel: '$title icon',
                      ),
                      const SizedBox(height: AppSpacing.x4),
                      Text(
                        title,
                        key: ValueKey('${title.toLowerCase()}DestinationTitle'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
