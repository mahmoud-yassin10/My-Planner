import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum_os/core/errors/persistence_failure.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/features/notifications/domain/notification_persistence_models.dart';
import 'package:momentum_os/features/notifications/domain/notification_repository.dart';

/// Drift-based implementation of NotificationPersistenceRepository.
///
/// This implementation handles all database operations for reminder rules
/// and notification inbox records, translating Drift/SQLite failures into
/// safe PersistenceFailure types.
class DriftNotificationRepository implements NotificationPersistenceRepository {
  DriftNotificationRepository({
    required this._database,
    required this._idService,
    required this._clock,
    required this._logger,
  });

  final AppDatabase _database;
  final IdService _idService;
  final UtcClock _clock;
  final AppLogger _logger;

  @override
  Future<void> createReminderRule(CreateReminderRuleRequest request) async {
    try {
      final now = _clock.now().toUtc();
      final id = _idService.newId();
      
      // Use Drift Companion for insertion
      await _database.into(_database.reminderRules).insert(
        ReminderRulesCompanion.insert(
          id: id,
          ownerType: Value(request.ownerType),
          ownerId: Value(request.ownerId),
          category: request.category,
          title: request.title,
          body: request.body,
          scheduledAt: request.scheduledAt,
          enabled: request.enabled,
          recurrenceValue: Value(request.recurrenceValue),
          platformNotificationId: Value(request.platformNotificationId),
          createdAt: now,
          updatedAt: now,
        ),
      );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'createReminderRule',
        'Failed to create reminder rule',
        metadata: {'category': request.category},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to create reminder rule: ${e.toString()}');
    }
  }

  @override
  Future<ReminderRule?> readReminderRule(String id) async {
    try {
      final row = await (_database.select(_database.reminderRules)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (row == null) {
        return null;
      }

      return ReminderRule(
        id: row.id,
        ownerType: row.ownerType,
        ownerId: row.ownerId,
        category: row.category,
        title: row.title,
        body: row.body,
        scheduledAt: row.scheduledAt,
        enabled: row.enabled,
        recurrenceValue: row.recurrenceValue,
        platformNotificationId: row.platformNotificationId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        canceledAt: row.canceledAt,
      );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'readReminderRule',
        'Failed to read reminder rule',
        metadata: {'ruleId': id},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceReadFailure('Failed to read reminder rule: ${e.toString()}');
    }
  }

  @override
  Stream<ReminderRule?> watchReminderRule(String id) {
    return (_database.select(_database.reminderRules)
          ..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) {
      if (row == null) return null;
      return ReminderRule(
        id: row.id,
        ownerType: row.ownerType,
        ownerId: row.ownerId,
        category: row.category,
        title: row.title,
        body: row.body,
        scheduledAt: row.scheduledAt,
        enabled: row.enabled,
        recurrenceValue: row.recurrenceValue,
        platformNotificationId: row.platformNotificationId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        canceledAt: row.canceledAt,
      );
    });
  }

  @override
  Stream<List<ReminderRule>> watchReminderRules() {
    return _database.select(_database.reminderRules).watch().map((rows) {
      return rows
          .map((row) => ReminderRule(
                id: row.id,
                ownerType: row.ownerType,
                ownerId: row.ownerId,
                category: row.category,
                title: row.title,
                body: row.body,
                scheduledAt: row.scheduledAt,
                enabled: row.enabled,
                recurrenceValue: row.recurrenceValue,
                platformNotificationId: row.platformNotificationId,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
                canceledAt: row.canceledAt,
              ))
          .toList();
    });
  }

  @override
  Future<void> updateReminderRuleEnabled(String id, bool enabled) async {
    try {
      final now = _clock.now().toUtc();
      
      await (_database.update(_database.reminderRules)
            ..where((t) => t.id.equals(id)))
        .write(
          ReminderRulesCompanion(
            enabled: Value(enabled),
            updatedAt: Value(now),
          ),
        );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'updateReminderRuleEnabled',
        'Failed to update reminder rule enabled state',
        metadata: {'ruleId': id, 'enabled': enabled},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to update reminder rule: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelReminderRule(String id) async {
    try {
      final now = _clock.now().toUtc();
      
      await (_database.update(_database.reminderRules)
            ..where((t) => t.id.equals(id)))
        .write(
          ReminderRulesCompanion(
            canceledAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'cancelReminderRule',
        'Failed to cancel reminder rule',
        metadata: {'ruleId': id},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to cancel reminder rule: ${e.toString()}');
    }
  }

  @override
  Future<void> createNotificationInbox(CreateNotificationInboxItemRequest request) async {
    try {
      final now = _clock.now().toUtc();
      final id = _idService.newId();
      
      // Use Drift Companion for insertion
      await _database.into(_database.notificationInbox).insert(
        NotificationInboxCompanion.insert(
          id: id,
          reminderRuleId: Value(request.reminderRuleId),
          ownerType: Value(request.ownerType),
          ownerId: Value(request.ownerId),
          category: request.category,
          title: request.title,
          body: request.body,
          scheduledAt: Value(request.scheduledAt),
          deliveredAt: Value(request.deliveredAt),
          readAt: Value(request.readAt),
          canceledAt: Value(request.canceledAt),
          platformNotificationId: Value(request.platformNotificationId),
          createdAt: now,
          updatedAt: now,
        ),
      );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'createNotificationInbox',
        'Failed to create notification inbox record',
        metadata: {'category': request.category},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to create notification inbox record: ${e.toString()}');
    }
  }

  @override
  Future<NotificationInboxItem?> readNotificationInbox(String id) async {
    try {
      final row = await (_database.select(_database.notificationInbox)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (row == null) {
        return null;
      }

      return NotificationInboxItem(
        id: row.id,
        reminderRuleId: row.reminderRuleId,
        ownerType: row.ownerType,
        ownerId: row.ownerId,
        category: row.category,
        title: row.title,
        body: row.body,
        scheduledAt: row.scheduledAt,
        deliveredAt: row.deliveredAt,
        readAt: row.readAt,
        canceledAt: row.canceledAt,
        platformNotificationId: row.platformNotificationId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'readNotificationInbox',
        'Failed to read notification inbox record',
        metadata: {'inboxId': id},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceReadFailure('Failed to read notification inbox record: ${e.toString()}');
    }
  }

  @override
  Stream<NotificationInboxItem?> watchNotificationInbox(String id) {
    return (_database.select(_database.notificationInbox)
          ..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) {
      if (row == null) return null;
      return NotificationInboxItem(
        id: row.id,
        reminderRuleId: row.reminderRuleId,
        ownerType: row.ownerType,
        ownerId: row.ownerId,
        category: row.category,
        title: row.title,
        body: row.body,
        scheduledAt: row.scheduledAt,
        deliveredAt: row.deliveredAt,
        readAt: row.readAt,
        canceledAt: row.canceledAt,
        platformNotificationId: row.platformNotificationId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    });
  }

  @override
  Stream<List<NotificationInboxItem>> watchActiveInbox() {
    return (_database.select(_database.notificationInbox)
          ..where((t) => t.canceledAt.isNull()))
        .watch()
        .map((rows) {
      return rows
          .map((row) => NotificationInboxItem(
                id: row.id,
                reminderRuleId: row.reminderRuleId,
                ownerType: row.ownerType,
                ownerId: row.ownerId,
                category: row.category,
                title: row.title,
                body: row.body,
                scheduledAt: row.scheduledAt,
                deliveredAt: row.deliveredAt,
                readAt: row.readAt,
                canceledAt: row.canceledAt,
                platformNotificationId: row.platformNotificationId,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
              ))
          .toList();
    });
  }

  @override
  Stream<List<NotificationInboxItem>> watchAllInbox() {
    return _database.select(_database.notificationInbox).watch().map((rows) {
      return rows
          .map((row) => NotificationInboxItem(
                id: row.id,
                reminderRuleId: row.reminderRuleId,
                ownerType: row.ownerType,
                ownerId: row.ownerId,
                category: row.category,
                title: row.title,
                body: row.body,
                scheduledAt: row.scheduledAt,
                deliveredAt: row.deliveredAt,
                readAt: row.readAt,
                canceledAt: row.canceledAt,
                platformNotificationId: row.platformNotificationId,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
              ))
          .toList();
    });
  }

  @override
  Future<void> markNotificationInboxRead(String id) async {
    try {
      final now = _clock.now().toUtc();
      
      await (_database.update(_database.notificationInbox)
            ..where((t) => t.id.equals(id)))
        .write(
          NotificationInboxCompanion(
            readAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'markNotificationInboxRead',
        'Failed to mark notification inbox as read',
        metadata: {'inboxId': id},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to mark notification inbox as read: ${e.toString()}');
    }
  }

  @override
  Future<void> markNotificationInboxUnread(String id) async {
    try {
      final now = _clock.now().toUtc();
      
      await (_database.update(_database.notificationInbox)
            ..where((t) => t.id.equals(id)))
        .write(
          NotificationInboxCompanion(
            readAt: Value(null),
            updatedAt: Value(now),
          ),
        );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'markNotificationInboxUnread',
        'Failed to mark notification inbox as unread',
        metadata: {'inboxId': id},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to mark notification inbox as unread: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelNotificationInbox(String id) async {
    try {
      final now = _clock.now().toUtc();
      
      await (_database.update(_database.notificationInbox)
            ..where((t) => t.id.equals(id)))
        .write(
          NotificationInboxCompanion(
            canceledAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'cancelNotificationInbox',
        'Failed to cancel notification inbox record',
        metadata: {'inboxId': id},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to cancel notification inbox record: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotificationInbox(String id) async {
    try {
      await (_database.delete(_database.notificationInbox)
            ..where((t) => t.id.equals(id)))
        .go();
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'notifications',
        'deleteNotificationInbox',
        'Failed to delete notification inbox record',
        metadata: {'inboxId': id},
        error: e,
        stackTrace: stackTrace,
      );
      throw PersistenceWriteFailure('Failed to delete notification inbox record: ${e.toString()}');
    }
  }
}

/// Riverpod provider exposing NotificationPersistenceRepository.
///
/// This provider constructs DriftNotificationRepository with the required
/// dependencies: database, ID service, clock, and logger.
final notificationRepositoryProvider = Provider<NotificationPersistenceRepository>((ref) {
  return DriftNotificationRepository(
    database: ref.watch(appDatabaseProvider),
    idService: ref.watch(idServiceProvider),
    clock: ref.watch(utcClockProvider),
    logger: ref.watch(appLoggerProvider),
  );
});