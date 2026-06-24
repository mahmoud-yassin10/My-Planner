import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/errors/persistence_failure.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/preferences/drift_settings_repository.dart';
import 'package:momentum_os/core/services/utc_clock.dart';
import 'package:momentum_os/shared/repositories/settings_repository.dart';

void main() {
  late AppDatabase database;
  late DriftSettingsRepository repository;
  late DateTime fixedNow;

  setUp(() {
    fixedNow = DateTime.utc(2026, 6, 24, 9, 30);
    database = AppDatabase.inMemory();
    repository = DriftSettingsRepository(
      database: database,
      clock: FixedUtcClock(fixedNow),
      logger: AppLogger(sink: (_) {}),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('returns generic defaults when no settings are stored', () async {
    expect(await repository.current(), AppSettingsPreferences.defaults);
  });

  test('updates typed settings and stores UTC update timestamps', () async {
    final preferences = AppSettingsPreferences.defaults.copyWith(
      themeMode: AppThemePreference.dark,
      accentColorValue: 0xFF1D4ED8,
      localeTag: 'en',
      firstDayOfWeek: DateTime.sunday,
      timeFormat: TimeFormatPreference.twentyFourHour,
    );

    await repository.update(preferences);

    expect(await repository.current(), preferences);

    final rows = await database.select(database.appSettings).get();
    expect(rows, isNotEmpty);
    expect(rows.every((row) => row.updatedAt.isUtc), isTrue);
    expect(rows.every((row) => row.updatedAt == fixedNow), isTrue);
  });

  test('observes setting changes', () async {
    final preferences = AppSettingsPreferences.defaults.copyWith(
      themeMode: AppThemePreference.light,
    );
    final iterator = StreamIterator(repository.watch());

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, AppSettingsPreferences.defaults);

    await repository.update(preferences);

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, preferences);

    await iterator.cancel();
  });

  test(
    'persists settings between repository instances using the same database',
    () async {
      final preferences = AppSettingsPreferences.defaults.copyWith(
        timeFormat: TimeFormatPreference.twelveHour,
      );

      await repository.update(preferences);

      final secondRepository = DriftSettingsRepository(
        database: database,
        clock: FixedUtcClock(fixedNow),
        logger: AppLogger(sink: (_) {}),
      );

      expect(await secondRepository.current(), preferences);
    },
  );

  test('reset returns settings to defaults', () async {
    await repository.update(
      AppSettingsPreferences.defaults.copyWith(
        themeMode: AppThemePreference.dark,
        localeTag: 'en',
      ),
    );

    await repository.reset();

    expect(await repository.current(), AppSettingsPreferences.defaults);
  });

  test('validates typed settings before writing', () async {
    final invalid = AppSettingsPreferences.defaults.copyWith(firstDayOfWeek: 8);

    expect(
      () => repository.update(invalid),
      throwsA(isA<PersistenceValidationFailure>()),
    );
  });

  test('translates read failures at repository boundary', () async {
    await database.customStatement('DROP TABLE app_settings');

    expect(repository.current, throwsA(isA<PersistenceReadFailure>()));
  });
}
