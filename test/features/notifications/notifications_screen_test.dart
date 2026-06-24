import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/notifications/notification_models.dart';
import 'package:momentum_os/core/notifications/notification_service.dart';
import 'package:momentum_os/features/notifications/presentation/notifications_screen.dart';

void main() {
  testWidgets('Notifications screen renders permission foundation state', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(
      find.byKey(const ValueKey('notificationsDestinationTitle')),
      findsOneWidget,
    );
    expect(find.text('Not requested'), findsOneWidget);
    expect(find.text('No notification inbox yet'), findsOneWidget);
    expect(find.text('Request permission placeholder'), findsOneWidget);
  });

  testWidgets('permission placeholder action updates the visible state', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.tap(find.text('Request permission placeholder'));
    await tester.pumpAndSettle();

    expect(find.text('Granted'), findsOneWidget);
    expect(find.text('Request permission placeholder'), findsNothing);
  });

  testWidgets('Notifications screen renders loading state', (tester) async {
    final completer = Completer<NotificationPermissionState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPermissionStateProvider.overrideWith(
            (ref) => completer.future,
          ),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );

    expect(find.text('Loading notifications'), findsOneWidget);
  });

  testWidgets('Notifications screen renders error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPermissionStateProvider.overrideWith(
            (ref) async => throw StateError('permission failed'),
          ),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications could not load'), findsOneWidget);
    expect(
      find.text('Try again to reload notification infrastructure.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appLoggerProvider.overrideWithValue(AppLogger(sink: (_) {}))],
      child: const MaterialApp(home: NotificationsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}
