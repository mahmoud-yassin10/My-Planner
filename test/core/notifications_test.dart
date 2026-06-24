import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/notifications/notification_models.dart';
import 'package:momentum_os/core/notifications/notification_service.dart';

void main() {
  late List<AppLogRecord> records;
  late LocalPlaceholderNotificationService service;

  setUp(() {
    records = <AppLogRecord>[];
    service = LocalPlaceholderNotificationService(
      logger: AppLogger(sink: records.add),
    );
  });

  test('permission state starts as requestable and can be granted', () async {
    final initial = await service.permissionState();

    expect(initial.status, NotificationPermissionStatus.notDetermined);
    expect(initial.canRequest, isTrue);

    final requested = await service.requestPermission();

    expect(requested.status, NotificationPermissionStatus.granted);
    expect(records.single.operation, 'requestPermission');
    expect(records.single.metadata['status'], 'granted');
  });

  test('valid intents are prepared without platform scheduling', () async {
    final result = await service.prepareIntent(
      NotificationIntent(
        category: NotificationIntentCategory.task,
        title: '  Review item  ',
        body: '  Generic reminder body. ',
        scheduledAt: DateTime(2026, 6, 24, 9),
        ownerType: 'task',
        ownerId: 'task-1',
      ),
    );

    expect(result.intent.title, 'Review item');
    expect(result.intent.body, 'Generic reminder body.');
    expect(result.intent.scheduledAt?.isUtc, isTrue);
    expect(result.platformSchedulingEnabled, isFalse);
  });

  test('invalid intents fail safely and log diagnostic context', () async {
    await expectLater(
      service.prepareIntent(
        const NotificationIntent(
          category: NotificationIntentCategory.custom,
          title: '',
          body: 'Body',
        ),
      ),
      throwsA(
        isA<NotificationValidationFailure>().having(
          (failure) => failure.message,
          'safe message',
          'Notification intent is invalid.',
        ),
      ),
    );

    expect(records.single.level, AppLogLevel.warning);
    expect(records.single.component, 'notificationService');
    expect(records.single.operation, 'prepareIntent');
    expect(records.single.metadata['category'], 'custom');
    expect(records.single.error, isA<NotificationValidationFailure>());
    expect(records.single.stackTrace, isNotNull);
  });

  test(
    'sensitive metadata keys are rejected and not emitted as metadata',
    () async {
      await expectLater(
        service.prepareIntent(
          const NotificationIntent(
            category: NotificationIntentCategory.custom,
            title: 'Safe title',
            body: 'Safe body',
            metadata: {'apiToken': 'do-not-log'},
          ),
        ),
        throwsA(isA<NotificationValidationFailure>()),
      );

      expect(records.single.metadata.containsKey('apiToken'), isFalse);
      expect(
        records.single.metadata['errorType'],
        'NotificationValidationFailure',
      );
    },
  );

  test('schedule delegates valid intents to the adapter deterministically', () async {
    final adapter = _FakeNotificationPlatformAdapter();
    service = LocalPlaceholderNotificationService(
      logger: AppLogger(sink: records.add),
      adapter: adapter,
      initialPermissionState: const NotificationPermissionState.granted(),
    );
    final intent = _scheduledIntent(DateTime.utc(2026, 6, 24, 9));

    final scheduled = await service.scheduleIntent(intent);

    expect(scheduled.platformId, deterministicNotificationIdFor(intent));
    expect(adapter.scheduled.single.platformId, scheduled.platformId);
    expect(adapter.scheduled.single.scheduledAt, DateTime.utc(2026, 6, 24, 9));
    expect(records.single.operation, 'scheduleIntent');
    expect(records.single.metadata['platformId'], scheduled.platformId);
  });

  test('cancel delegates deterministic identifiers to the adapter', () async {
    final adapter = _FakeNotificationPlatformAdapter();
    service = LocalPlaceholderNotificationService(
      logger: AppLogger(sink: records.add),
      adapter: adapter,
      initialPermissionState: const NotificationPermissionState.granted(),
    );
    final intent = _scheduledIntent(DateTime.utc(2026, 6, 24, 9));

    await service.cancelIntent(intent);

    expect(adapter.canceled.single, deterministicNotificationIdFor(intent));
    expect(records.single.operation, 'cancelIntent');
  });

  test('reschedule cancels the previous intent before scheduling the next', () async {
    final adapter = _FakeNotificationPlatformAdapter();
    service = LocalPlaceholderNotificationService(
      logger: AppLogger(sink: records.add),
      adapter: adapter,
      initialPermissionState: const NotificationPermissionState.granted(),
    );
    final previous = _scheduledIntent(DateTime.utc(2026, 6, 24, 9));
    final next = _scheduledIntent(DateTime.utc(2026, 6, 24, 10));

    final scheduled = await service.rescheduleIntent(
      previousIntent: previous,
      nextIntent: next,
    );

    expect(adapter.canceled.single, deterministicNotificationIdFor(previous));
    expect(
      adapter.scheduled.single.platformId,
      deterministicNotificationIdFor(next),
    );
    expect(scheduled.platformId, deterministicNotificationIdFor(next));
    expect(records.single.operation, 'rescheduleIntent');
  });

  test('permission denial fails safely before adapter calls', () async {
    final adapter = _FakeNotificationPlatformAdapter();
    service = LocalPlaceholderNotificationService(
      logger: AppLogger(sink: records.add),
      adapter: adapter,
      initialPermissionState: const NotificationPermissionState.denied(),
    );

    await expectLater(
      service.scheduleIntent(_scheduledIntent(DateTime.utc(2026, 6, 24, 9))),
      throwsA(isA<NotificationPermissionFailure>()),
    );

    expect(adapter.scheduled, isEmpty);
    expect(records.single.operation, 'scheduleIntent');
    expect(records.single.metadata['status'], 'denied');
  });

  test('adapter failures are translated and preserve debug diagnostics', () async {
    final adapter = _FakeNotificationPlatformAdapter(
      scheduleError: StateError('platform detail'),
    );
    service = LocalPlaceholderNotificationService(
      logger: AppLogger(sink: records.add),
      adapter: adapter,
      initialPermissionState: const NotificationPermissionState.granted(),
    );

    await expectLater(
      service.scheduleIntent(_scheduledIntent(DateTime.utc(2026, 6, 24, 9))),
      throwsA(
        isA<NotificationSchedulingFailure>().having(
          (failure) => failure.message,
          'safe message',
          'Notification could not be scheduled.',
        ),
      ),
    );

    expect(records.single.operation, 'scheduleIntent');
    expect(records.single.error, isA<StateError>());
    expect(records.single.stackTrace, isNotNull);
  });
}

NotificationIntent _scheduledIntent(DateTime scheduledAt) {
  return NotificationIntent(
    category: NotificationIntentCategory.custom,
    title: 'Generic reminder',
    body: 'Review the generic item.',
    scheduledAt: scheduledAt,
    ownerType: 'generic',
    ownerId: 'item-1',
  );
}

class _FakeNotificationPlatformAdapter implements NotificationPlatformAdapter {
  _FakeNotificationPlatformAdapter({this.scheduleError, this.cancelError});

  final Object? scheduleError;
  final Object? cancelError;
  final scheduled = <ScheduledNotification>[];
  final canceled = <int>[];

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    final error = scheduleError;
    if (error != null) {
      throw error;
    }
    scheduled.add(notification);
  }

  @override
  Future<void> cancel(int platformId) async {
    final error = cancelError;
    if (error != null) {
      throw error;
    }
    canceled.add(platformId);
  }
}
