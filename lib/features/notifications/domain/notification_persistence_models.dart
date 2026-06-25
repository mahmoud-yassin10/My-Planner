/// Domain models for notification persistence.
///
/// These are pure Dart classes representing reminder rules and notification
/// inbox items. They do not import Drift and are safe to use in domain layers.

/// Reminder-rule domain model.
///
/// Represents a scheduled notification rule that can be created,
/// updated, enabled/disabled, and canceled.
class ReminderRule {
  final String id;
  final String? ownerType;
  final String? ownerId;
  final String category;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool enabled;
  final String? recurrenceValue;
  final int? platformNotificationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? canceledAt;

  const ReminderRule({
    required this.id,
    this.ownerType,
    this.ownerId,
    required this.category,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.enabled,
    this.recurrenceValue,
    this.platformNotificationId,
    required this.createdAt,
    required this.updatedAt,
    this.canceledAt,
  });

  ReminderRule copyWith({
    String? id,
    String? ownerType,
    String? ownerId,
    String? category,
    String? title,
    String? body,
    DateTime? scheduledAt,
    bool? enabled,
    String? recurrenceValue,
    int? platformNotificationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? canceledAt,
  }) {
    return ReminderRule(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      enabled: enabled ?? this.enabled,
      recurrenceValue: recurrenceValue ?? this.recurrenceValue,
      platformNotificationId: platformNotificationId ?? this.platformNotificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }

  bool get isCanceled => canceledAt != null;
  bool get isActive => !isCanceled && enabled;
}

/// Notification-inbox item domain model.
///
/// Represents a delivered or scheduled notification record.
class NotificationInboxItem {
  final String id;
  final String? reminderRuleId;
  final String? ownerType;
  final String? ownerId;
  final String category;
  final String title;
  final String body;
  final DateTime? scheduledAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime? canceledAt;
  final int? platformNotificationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationInboxItem({
    required this.id,
    this.reminderRuleId,
    this.ownerType,
    this.ownerId,
    required this.category,
    required this.title,
    required this.body,
    this.scheduledAt,
    this.deliveredAt,
    this.readAt,
    this.canceledAt,
    this.platformNotificationId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCanceled => canceledAt != null;
  bool get isRead => readAt != null;
  bool get isDelivered => deliveredAt != null;
  bool get isActive => !isCanceled && !isRead;
}

/// Request models for creating/updating reminder rules.
class CreateReminderRuleRequest {
  final String? ownerType;
  final String? ownerId;
  final String category;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool enabled;
  final String? recurrenceValue;
  final int? platformNotificationId;

  const CreateReminderRuleRequest({
    this.ownerType,
    this.ownerId,
    required this.category,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.enabled,
    this.recurrenceValue,
    this.platformNotificationId,
  });
}

class UpdateReminderRuleRequest {
  final bool enabled;
  final String? recurrenceValue;
  final int? platformNotificationId;

  const UpdateReminderRuleRequest({
    required this.enabled,
    this.recurrenceValue,
    this.platformNotificationId,
  });
}

/// Request models for creating/updating notification inbox items.
class CreateNotificationInboxItemRequest {
  final String? reminderRuleId;
  final String? ownerType;
  final String? ownerId;
  final String category;
  final String title;
  final String body;
  final DateTime? scheduledAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime? canceledAt;
  final int? platformNotificationId;

  const CreateNotificationInboxItemRequest({
    this.reminderRuleId,
    this.ownerType,
    this.ownerId,
    required this.category,
    required this.title,
    required this.body,
    this.scheduledAt,
    this.deliveredAt,
    this.readAt,
    this.canceledAt,
    this.platformNotificationId,
  });
}