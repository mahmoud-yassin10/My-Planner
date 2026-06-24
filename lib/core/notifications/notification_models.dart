enum NotificationIntentCategory {
  task,
  meeting,
  followUp,
  paymentDue,
  goalReview,
  morningPlan,
  eveningReview,
  weeklyReview,
  learningRevision,
  custom,
}

enum NotificationPermissionStatus {
  notDetermined,
  granted,
  denied,
  permanentlyDenied,
  unavailable,
}

class NotificationPermissionState {
  const NotificationPermissionState({
    required this.status,
    required this.canRequest,
    required this.description,
  });

  const NotificationPermissionState.notDetermined()
    : this(
        status: NotificationPermissionStatus.notDetermined,
        canRequest: true,
        description: 'Notification permission has not been requested yet.',
      );

  const NotificationPermissionState.granted()
    : this(
        status: NotificationPermissionStatus.granted,
        canRequest: false,
        description: 'Notification permission is available.',
      );

  const NotificationPermissionState.denied()
    : this(
        status: NotificationPermissionStatus.denied,
        canRequest: true,
        description: 'Notification permission is currently denied.',
      );

  const NotificationPermissionState.permanentlyDenied()
    : this(
        status: NotificationPermissionStatus.permanentlyDenied,
        canRequest: false,
        description:
            'Notification permission must be changed in system settings.',
      );

  const NotificationPermissionState.unavailable()
    : this(
        status: NotificationPermissionStatus.unavailable,
        canRequest: false,
        description: 'Notifications are unavailable on this platform.',
      );

  final NotificationPermissionStatus status;
  final bool canRequest;
  final String description;

  bool get isGranted => status == NotificationPermissionStatus.granted;
}

class NotificationIntent {
  const NotificationIntent({
    required this.category,
    required this.title,
    required this.body,
    this.scheduledAt,
    this.ownerType,
    this.ownerId,
    this.metadata = const {},
  });

  final NotificationIntentCategory category;
  final String title;
  final String body;
  final DateTime? scheduledAt;
  final String? ownerType;
  final String? ownerId;
  final Map<String, Object?> metadata;

  NotificationIntent normalized() {
    return NotificationIntent(
      category: category,
      title: title.trim(),
      body: body.trim(),
      scheduledAt: scheduledAt?.toUtc(),
      ownerType: _trimOrNull(ownerType),
      ownerId: _trimOrNull(ownerId),
      metadata: Map.unmodifiable(metadata),
    );
  }

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

class NotificationPreparationResult {
  const NotificationPreparationResult({
    required this.intent,
    required this.permissionState,
    required this.platformSchedulingEnabled,
    required this.message,
  });

  final NotificationIntent intent;
  final NotificationPermissionState permissionState;
  final bool platformSchedulingEnabled;
  final String message;
}

class ScheduledNotification {
  const ScheduledNotification({
    required this.platformId,
    required this.intent,
    required this.scheduledAt,
  });

  final int platformId;
  final NotificationIntent intent;
  final DateTime scheduledAt;
}

class NotificationFailure implements Exception {
  const NotificationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotificationValidationFailure extends NotificationFailure {
  const NotificationValidationFailure(super.message);
}

class NotificationPermissionFailure extends NotificationFailure {
  const NotificationPermissionFailure(super.message);
}

class NotificationSchedulingFailure extends NotificationFailure {
  const NotificationSchedulingFailure(super.message);
}
