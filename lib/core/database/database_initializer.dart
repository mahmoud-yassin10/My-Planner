import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';
import 'app_database.dart';

class DatabaseInitializer {
  const DatabaseInitializer({required this.openDatabase, required this.logger});

  final AppDatabase Function() openDatabase;
  final AppLogger logger;

  Future<void> initialize() async {
    AppDatabase? database;

    try {
      database = openDatabase();
      await database.verifyReady();
      final foreignKeysEnabled = await database.foreignKeysEnabled();
      if (!foreignKeysEnabled) {
        throw const DatabaseInitializationException(
          'Foreign keys are disabled',
        );
      }
    } catch (error, stackTrace) {
      logger.error(
        'database',
        'initialize',
        'Database initialization failed.',
        metadata: {'errorType': error.runtimeType.toString()},
        error: error,
        stackTrace: stackTrace,
      );
      throw DatabaseInitializationException(error.runtimeType.toString());
    } finally {
      await database?.close();
    }
  }
}

class DatabaseInitializationException implements Exception {
  const DatabaseInitializationException(this.reason);

  final String reason;

  @override
  String toString() => 'DatabaseInitializationException($reason)';
}

final databaseInitializerProvider = Provider<DatabaseInitializer>((ref) {
  return DatabaseInitializer(
    openDatabase: AppDatabase.production,
    logger: ref.watch(appLoggerProvider),
  );
});
