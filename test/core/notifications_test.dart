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
}
