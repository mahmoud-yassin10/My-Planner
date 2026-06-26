import 'dart:async';
import 'package:momentum_os/features/notifications/domain/notification_persistence_models.dart';

/// Repository contract for reminder rules and notification inbox.
///
/// This interface hides Drift implementation details from presentation
/// layers and provides safe failure translation.
abstract interface class NotificationPersistenceRepository {
  /// Create a new reminder rule.
  Future<void> createReminderRule(CreateReminderRuleRequest request);

  /// Read a reminder rule by ID.
  Future<ReminderRule?> readReminderRule(String id);

  /// Watch a single reminder rule.
  Stream<ReminderRule?> watchReminderRule(String id);

  /// Watch all reminder rules.
  Stream<List<ReminderRule>> watchReminderRules();

  /// Enable or disable a reminder rule.
  Future<void> updateReminderRuleEnabled(String id, bool enabled);

  /// Cancel a reminder rule.
  Future<void> cancelReminderRule(String id);

  /// Create a notification inbox record.
  Future<void> createNotificationInbox(
    CreateNotificationInboxItemRequest request,
  );

  /// Read a notification inbox record by ID.
  Future<NotificationInboxItem?> readNotificationInbox(String id);

  /// Watch a single notification inbox record.
  Stream<NotificationInboxItem?> watchNotificationInbox(String id);

  /// Watch active notification inbox records (not canceled, not read).
  Stream<List<NotificationInboxItem>> watchActiveInbox();

  /// Watch all notification inbox records.
  Stream<List<NotificationInboxItem>> watchAllInbox();

  /// Mark a notification inbox record as read.
  Future<void> markNotificationInboxRead(String id);

  /// Mark a notification inbox record as unread.
  Future<void> markNotificationInboxUnread(String id);

  /// Cancel a notification inbox record.
  Future<void> cancelNotificationInbox(String id);

  /// Permanently delete a notification inbox record.
  Future<void> deleteNotificationInbox(String id);
}
