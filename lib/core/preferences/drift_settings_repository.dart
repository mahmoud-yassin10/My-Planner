import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/settings_repository.dart';
import '../database/app_database.dart';
import '../errors/persistence_failure.dart';
import '../logging/app_logger.dart';
import '../services/utc_clock.dart';

class DriftSettingsRepository implements SettingsRepository {
  const DriftSettingsRepository({
    required AppDatabase database,
    required UtcClock clock,
    required AppLogger logger,
  }) : this._(database, clock, logger);

  const DriftSettingsRepository._(this._database, this._clock, this._logger);

  final AppDatabase _database;
  final UtcClock _clock;
  final AppLogger _logger;

  @override
  Future<AppSettingsPreferences> current() async {
    try {
      final rows = await _database.select(_database.appSettings).get();
      return _preferencesFrom(rows);
    } catch (error, stackTrace) {
      _logFailure('current', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read app settings.');
    }
  }

  @override
  Stream<AppSettingsPreferences> watch() {
    return _database
        .select(_database.appSettings)
        .watch()
        .map(_preferencesFrom)
        .handleError((Object error, StackTrace stackTrace) {
          _logFailure('watch', error, stackTrace);
          throw const PersistenceReadFailure('Unable to watch app settings.');
        });
  }

  @override
  Future<void> update(AppSettingsPreferences preferences) async {
    _validate(preferences);

    try {
      await _database.transaction(() async {
        await _writePreferences(preferences);
      });
    } catch (error, stackTrace) {
      _logFailure('update', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to update app settings.');
    }
  }

  @override
  Future<void> reset() async {
    try {
      await _database.transaction(() async {
        await _database.delete(_database.appSettings).go();
      });
    } catch (error, stackTrace) {
      _logFailure('reset', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to reset app settings.');
    }
  }

  Future<void> _writePreferences(AppSettingsPreferences preferences) async {
    final now = _clock.now();
    final values = <String, String>{
      _SettingKeys.themeMode: preferences.themeMode.name,
      if (preferences.accentColorValue != null)
        _SettingKeys.accentColorValue: preferences.accentColorValue.toString(),
      if (preferences.localeTag != null)
        _SettingKeys.localeTag: preferences.localeTag!,
      _SettingKeys.firstDayOfWeek: preferences.firstDayOfWeek.toString(),
      _SettingKeys.timeFormat: preferences.timeFormat.name,
    };

    await _database.batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          _database.appSettings,
          AppSettingsCompanion.insert(
            key: entry.key,
            value: entry.value,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }

      if (preferences.accentColorValue == null) {
        batch.deleteWhere(
          _database.appSettings,
          (table) => table.key.equals(_SettingKeys.accentColorValue),
        );
      }

      if (preferences.localeTag == null) {
        batch.deleteWhere(
          _database.appSettings,
          (table) => table.key.equals(_SettingKeys.localeTag),
        );
      }
    });
  }

  AppSettingsPreferences _preferencesFrom(List<AppSettingRow> rows) {
    final values = {for (final row in rows) row.key: row.value};

    return AppSettingsPreferences(
      themeMode: _enumValue(
        AppThemePreference.values,
        values[_SettingKeys.themeMode],
        AppThemePreference.system,
      ),
      accentColorValue: int.tryParse(
        values[_SettingKeys.accentColorValue] ?? '',
      ),
      localeTag: values[_SettingKeys.localeTag],
      firstDayOfWeek:
          int.tryParse(values[_SettingKeys.firstDayOfWeek] ?? '') ??
          DateTime.monday,
      timeFormat: _enumValue(
        TimeFormatPreference.values,
        values[_SettingKeys.timeFormat],
        TimeFormatPreference.system,
      ),
    );
  }

  T _enumValue<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) {
      return fallback;
    }

    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }

    return fallback;
  }

  void _validate(AppSettingsPreferences preferences) {
    if (preferences.firstDayOfWeek < DateTime.monday ||
        preferences.firstDayOfWeek > DateTime.sunday) {
      throw const PersistenceValidationFailure(
        'firstDayOfWeek must be between 1 and 7.',
      );
    }

    if (preferences.localeTag != null &&
        preferences.localeTag!.trim().isEmpty) {
      throw const PersistenceValidationFailure('localeTag must not be empty.');
    }
  }

  void _logFailure(String operation, Object error, StackTrace stackTrace) {
    _logger.error(
      'settingsRepository',
      operation,
      'Settings repository operation failed.',
      metadata: {'errorType': error.runtimeType.toString()},
      error: error,
      stackTrace: stackTrace,
    );
  }
}

abstract final class _SettingKeys {
  static const themeMode = 'themeMode';
  static const accentColorValue = 'accentColorValue';
  static const localeTag = 'localeTag';
  static const firstDayOfWeek = 'firstDayOfWeek';
  static const timeFormat = 'timeFormat';
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return DriftSettingsRepository(
    database: ref.watch(appDatabaseProvider),
    clock: ref.watch(utcClockProvider),
    logger: ref.watch(appLoggerProvider),
  );
});
