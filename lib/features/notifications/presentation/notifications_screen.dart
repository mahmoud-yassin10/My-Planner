import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/widgets/foundation_states.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(notificationPermissionStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: permissionState.when(
        loading: () =>
            const FoundationLoadingState(message: 'Loading notifications'),
        error: (error, stackTrace) => FoundationErrorState(
          title: 'Notifications could not load',
          message: 'Try again to reload notification infrastructure.',
          actionLabel: 'Try again',
          onRetry: () => ref.invalidate(notificationPermissionStateProvider),
        ),
        data: (state) => _NotificationFoundationContent(state: state),
      ),
    );
  }
}

class _NotificationFoundationContent extends ConsumerWidget {
  const _NotificationFoundationContent({required this.state});

  final NotificationPermissionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x6),
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.primary,
              semanticLabel: 'Notifications icon',
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                'Notifications',
                key: const ValueKey('notificationsDestinationTitle'),
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          'Scheduling, cancellation, and rescheduling are available through a replaceable notification adapter. The default adapter does not yet schedule operating-system notifications.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.x6),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permission', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.x2),
                Semantics(
                  label: 'Notification permission ${state.status.name}',
                  child: Chip(
                    avatar: Icon(
                      state.isGranted
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                    ),
                    label: Text(_permissionLabel(state.status)),
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  state.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (state.canRequest) ...[
                  const SizedBox(height: AppSpacing.x4),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(notificationServiceProvider)
                          .requestPermission();
                      ref.invalidate(notificationPermissionStateProvider);
                    },
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Request permission placeholder'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        const FoundationEmptyState(
          title: 'No notification inbox yet',
          message:
              'Notification inbox persistence and the production operating-system notification adapter remain planned for later Phase 7 work.',
          icon: Icons.mark_email_unread_outlined,
        ),
      ],
    );
  }

  String _permissionLabel(NotificationPermissionStatus status) {
    return switch (status) {
      NotificationPermissionStatus.notDetermined => 'Not requested',
      NotificationPermissionStatus.granted => 'Granted',
      NotificationPermissionStatus.denied => 'Denied',
      NotificationPermissionStatus.permanentlyDenied => 'Permanently denied',
      NotificationPermissionStatus.unavailable => 'Unavailable',
    };
  }
}
