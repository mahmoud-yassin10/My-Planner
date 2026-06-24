import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';
import 'notification_models.dart';

abstract interface class NotificationService {
  Future<NotificationPermissionState> permissionState();

  Future<NotificationPermissionState> requestPermission();

  Future<NotificationPreparationResult> prepareIntent(
    NotificationIntent intent,
  );
}

class LocalPlaceholderNotificationService implements NotificationService {
  factory LocalPlaceholderNotificationService({
    required AppLogger logger,
    NotificationPermissionState initialPermissionState =
        const NotificationPermissionState.notDetermined(),
    NotificationPermissionState requestResult =
        const NotificationPermissionState.granted(),
  }) {
    return LocalPlaceholderNotificationService._(
      logger,
      initialPermissionState,
      requestResult,
    );
  }

  LocalPlaceholderNotificationService._(
    this._logger,
    this._permissionState,
    this._requestResult,
  );

  final AppLogger _logger;
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

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalPlaceholderNotificationService(
    logger: ref.watch(appLoggerProvider),
  );
});

final notificationPermissionStateProvider =
    FutureProvider<NotificationPermissionState>((ref) {
      return ref.watch(notificationServiceProvider).permissionState();
    });
