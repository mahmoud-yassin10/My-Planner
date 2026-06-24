import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';
import 'notification_models.dart';

abstract interface class NotificationService {
  Future<NotificationPermissionState> permissionState();

  Future<NotificationPermissionState> requestPermission();

  Future<NotificationPreparationResult> prepareIntent(
    NotificationIntent intent,
  );

  Future<ScheduledNotification> scheduleIntent(NotificationIntent intent);

  Future<void> cancelIntent(NotificationIntent intent);

  Future<ScheduledNotification> rescheduleIntent({
    required NotificationIntent previousIntent,
    required NotificationIntent nextIntent,
  });
}

abstract interface class NotificationPlatformAdapter {
  Future<void> schedule(ScheduledNotification notification);

  Future<void> cancel(int platformId);
}

class NoopNotificationPlatformAdapter implements NotificationPlatformAdapter {
  const NoopNotificationPlatformAdapter();

  @override
  Future<void> schedule(ScheduledNotification notification) async {}

  @override
  Future<void> cancel(int platformId) async {}
}

class LocalPlaceholderNotificationService implements NotificationService {
  factory LocalPlaceholderNotificationService({
    required AppLogger logger,
    NotificationPlatformAdapter adapter =
        const NoopNotificationPlatformAdapter(),
    NotificationPermissionState initialPermissionState =
        const NotificationPermissionState.notDetermined(),
    NotificationPermissionState requestResult =
        const NotificationPermissionState.granted(),
  }) {
    return LocalPlaceholderNotificationService._(
      logger,
      adapter,
      initialPermissionState,
      requestResult,
    );
  }

  LocalPlaceholderNotificationService._(
    this._logger,
    this._adapter,
    this._permissionState,
    this._requestResult,
  );

  final AppLogger _logger;
  final NotificationPlatformAdapter _adapter;
  final NotificationPermissionState _requestResult;
  NotificationPermissionState _permissionState;

  @override
  Future<NotificationPermissionState> permissionState() async {
    return _permissionState;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    if (!_permissionState.canRequest) {
      _logger.info(
        'notificationService',
        'requestPermission',
        'Notification permission request was skipped.',
        metadata: {'status': _permissionState.status.name},
      );
      return _permissionState;
    }

    _permissionState = _requestResult;
    _logger.info(
      'notificationService',
      'requestPermission',
      'Notification permission placeholder completed.',
      metadata: {'status': _permissionState.status.name},
    );
    return _permissionState;
  }

  @override
  Future<NotificationPreparationResult> prepareIntent(
    NotificationIntent intent,
  ) async {
    try {
      final normalized = _validateIntent(intent);
      return NotificationPreparationResult(
        intent: normalized,
        permissionState: _permissionState,
        platformSchedulingEnabled: false,
        message:
            'Notification intent is valid. Platform scheduling will be added later.',
      );
    } on NotificationValidationFailure catch (error, stackTrace) {
      _logger.warning(
        'notificationService',
        'prepareIntent',
        'Notification intent validation failed.',
        metadata: {
          'category': intent.category.name,
          'errorType': error.runtimeType.toString(),
        },
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationValidationFailure(
        'Notification intent is invalid.',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'notificationService',
        'prepareIntent',
        'Notification intent preparation failed.',
        metadata: {'errorType': error.runtimeType.toString()},
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationFailure(
        'Notification intent could not be prepared.',
      );
    }
  }

  @override
  Future<ScheduledNotification> scheduleIntent(NotificationIntent intent) async {
    try {
      final normalized = _validateSchedulableIntent(intent);
      _ensureSchedulingPermission('scheduleIntent');
      final notification = ScheduledNotification(
        platformId: deterministicNotificationIdFor(normalized),
        intent: normalized,
        scheduledAt: normalized.scheduledAt!,
      );
      await _adapter.schedule(notification);
      _logger.info(
        'notificationService',
        'scheduleIntent',
        'Notification intent scheduled through adapter.',
        metadata: {
          'category': normalized.category.name,
          'platformId': notification.platformId,
        },
      );
      return notification;
    } on NotificationValidationFailure catch (error) {
      _logValidationFailure('scheduleIntent', intent, error);
      throw const NotificationValidationFailure(
        'Notification intent is invalid.',
      );
    } on NotificationFailure {
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'notificationService',
        'scheduleIntent',
        'Notification scheduling adapter failed.',
        metadata: {'errorType': error.runtimeType.toString()},
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationSchedulingFailure(
        'Notification could not be scheduled.',
      );
    }
  }

  @override
  Future<void> cancelIntent(NotificationIntent intent) async {
    try {
      final normalized = _validateSchedulableIntent(intent);
      _ensureSchedulingPermission('cancelIntent');
      final platformId = deterministicNotificationIdFor(normalized);
      await _adapter.cancel(platformId);
      _logger.info(
        'notificationService',
        'cancelIntent',
        'Notification intent canceled through adapter.',
        metadata: {
          'category': normalized.category.name,
          'platformId': platformId,
        },
      );
    } on NotificationValidationFailure catch (error) {
      _logValidationFailure('cancelIntent', intent, error);
      throw const NotificationValidationFailure(
        'Notification intent is invalid.',
      );
    } on NotificationFailure {
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'notificationService',
        'cancelIntent',
        'Notification cancellation adapter failed.',
        metadata: {'errorType': error.runtimeType.toString()},
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationSchedulingFailure(
        'Notification could not be canceled.',
      );
    }
  }

  @override
  Future<ScheduledNotification> rescheduleIntent({
    required NotificationIntent previousIntent,
    required NotificationIntent nextIntent,
  }) async {
    try {
      final previous = _validateSchedulableIntent(previousIntent);
      final next = _validateSchedulableIntent(nextIntent);
      _ensureSchedulingPermission('rescheduleIntent');
      final previousPlatformId = deterministicNotificationIdFor(previous);
      await _adapter.cancel(previousPlatformId);
      final notification = ScheduledNotification(
        platformId: deterministicNotificationIdFor(next),
        intent: next,
        scheduledAt: next.scheduledAt!,
      );
      await _adapter.schedule(notification);
      _logger.info(
        'notificationService',
        'rescheduleIntent',
        'Notification intent rescheduled through adapter.',
        metadata: {
          'category': next.category.name,
          'previousPlatformId': previousPlatformId,
          'platformId': notification.platformId,
        },
      );
      return notification;
    } on NotificationValidationFailure catch (error) {
      _logValidationFailure('rescheduleIntent', nextIntent, error);
      throw const NotificationValidationFailure(
        'Notification intent is invalid.',
      );
    } on NotificationFailure {
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'notificationService',
        'rescheduleIntent',
        'Notification rescheduling adapter failed.',
        metadata: {'errorType': error.runtimeType.toString()},
        error: error,
        stackTrace: stackTrace,
      );
      throw const NotificationSchedulingFailure(
        'Notification could not be rescheduled.',
      );
    }
  }

  NotificationIntent _validateIntent(NotificationIntent intent) {
    final normalized = intent.normalized();
    if (normalized.title.isEmpty) {
      throw const NotificationValidationFailure(
        'Notification title must not be empty.',
      );
    }
    if (normalized.body.isEmpty) {
      throw const NotificationValidationFailure(
        'Notification body must not be empty.',
      );
    }
    if (normalized.title.length > 120) {
      throw const NotificationValidationFailure(
        'Notification title is too long.',
      );
    }
    if (normalized.body.length > 240) {
      throw const NotificationValidationFailure(
        'Notification body is too long.',
      );
    }
    final hasOwnerType = normalized.ownerType != null;
    final hasOwnerId = normalized.ownerId != null;
    if (hasOwnerType != hasOwnerId) {
      throw const NotificationValidationFailure(
        'Notification owner type and identifier must be provided together.',
      );
    }
    if (_containsSensitiveMetadataKey(normalized.metadata)) {
      throw const NotificationValidationFailure(
        'Notification metadata contains unsupported sensitive keys.',
      );
    }
    return normalized;
  }

  NotificationIntent _validateSchedulableIntent(NotificationIntent intent) {
    final normalized = _validateIntent(intent);
    if (normalized.scheduledAt == null) {
      throw const NotificationValidationFailure(
        'Notification schedule time is required.',
      );
    }
    return normalized;
  }

  void _ensureSchedulingPermission(String operation) {
    if (_permissionState.isGranted) {
      return;
    }
    final error = NotificationPermissionFailure(
      _permissionState.status == NotificationPermissionStatus.unavailable
          ? 'Notifications are unavailable.'
          : 'Notification permission is required.',
    );
    _logger.warning(
      'notificationService',
      operation,
      'Notification scheduling permission check failed.',
      metadata: {
        'status': _permissionState.status.name,
        'errorType': error.runtimeType.toString(),
      },
      error: error,
      stackTrace: StackTrace.current,
    );
    throw const NotificationPermissionFailure(
      'Notification permission is required.',
    );
  }

  void _logValidationFailure(
    String operation,
    NotificationIntent intent,
    NotificationValidationFailure error,
  ) {
    _logger.warning(
      'notificationService',
      operation,
      'Notification intent validation failed.',
      metadata: {
        'category': intent.category.name,
        'errorType': error.runtimeType.toString(),
      },
      error: error,
      stackTrace: StackTrace.current,
    );
  }

  bool _containsSensitiveMetadataKey(Map<String, Object?> metadata) {
    return metadata.keys.any((key) {
      final lowerKey = key.toLowerCase();
      return lowerKey.contains('password') ||
          lowerKey.contains('secret') ||
          lowerKey.contains('token') ||
          lowerKey.contains('securestorage') ||
          lowerKey.contains('notecontent') ||
          lowerKey.contains('financialcontent');
    });
  }
}

int deterministicNotificationIdFor(NotificationIntent intent) {
  final normalized = intent.normalized();
  final input = [
    normalized.category.name,
    normalized.title,
    normalized.body,
    normalized.scheduledAt?.toIso8601String() ?? '',
    normalized.ownerType ?? '',
    normalized.ownerId ?? '',
  ].join('|');

  var hash = 0x811c9dc5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  final id = hash & 0x7fffffff;
  return id == 0 ? 1 : id;
}

final notificationPlatformAdapterProvider =
    Provider<NotificationPlatformAdapter>((ref) {
      return const NoopNotificationPlatformAdapter();
    });

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalPlaceholderNotificationService(
    logger: ref.watch(appLoggerProvider),
    adapter: ref.watch(notificationPlatformAdapterProvider),
  );
});

final notificationPermissionStateProvider =
    FutureProvider<NotificationPermissionState>((ref) {
      return ref.watch(notificationServiceProvider).permissionState();
    });
