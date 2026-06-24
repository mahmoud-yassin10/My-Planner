import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLogLevel { debug, info, warning, error }

typedef AppLogSink = void Function(AppLogRecord record);

class AppLogRecord {
  const AppLogRecord({
    required this.level,
    required this.component,
    required this.operation,
    required this.message,
    this.metadata = const {},
    this.error,
    this.stackTrace,
  });

  final AppLogLevel level;
  final String component;
  final String operation;
  final String message;
  final Map<String, Object?> metadata;
  final Object? error;
  final StackTrace? stackTrace;
}

class AppLogger {
  AppLogger({AppLogSink? sink}) : _sink = sink ?? _developerSink;

  final AppLogSink _sink;

  void debug(
    String component,
    String operation,
    String message, {
    Map<String, Object?> metadata = const {},
  }) {
    _write(
      AppLogLevel.debug,
      component,
      operation,
      message,
      metadata: metadata,
    );
  }

  void info(
    String component,
    String operation,
    String message, {
    Map<String, Object?> metadata = const {},
  }) {
    _write(AppLogLevel.info, component, operation, message, metadata: metadata);
  }

  void warning(
    String component,
    String operation,
    String message, {
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write(
      AppLogLevel.warning,
      component,
      operation,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    String component,
    String operation,
    String message, {
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write(
      AppLogLevel.error,
      component,
      operation,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _write(
    AppLogLevel level,
    String component,
    String operation,
    String message, {
    Map<String, Object?> metadata = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _sink(
      AppLogRecord(
        level: level,
        component: component,
        operation: operation,
        message: message,
        metadata: _safeMetadata(metadata),
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  static Map<String, Object?> _safeMetadata(Map<String, Object?> metadata) {
    return Map.unmodifiable(
      metadata.map((key, value) {
        final lowerKey = key.toLowerCase();
        final shouldRedact =
            lowerKey.contains('key') ||
            lowerKey.contains('password') ||
            lowerKey.contains('secret') ||
            lowerKey.contains('token') ||
            lowerKey.contains('securestorage') ||
            lowerKey.contains('notecontent') ||
            lowerKey.contains('financialcontent');

        return MapEntry(key, shouldRedact ? '<redacted>' : value);
      }),
    );
  }

  static void _developerSink(AppLogRecord record) {
    developer.log(
      record.message,
      name: '${record.component}.${record.operation}',
      level: switch (record.level) {
        AppLogLevel.debug => 500,
        AppLogLevel.info => 800,
        AppLogLevel.warning => 900,
        AppLogLevel.error => 1000,
      },
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }
}

final appLoggerProvider = Provider<AppLogger>((ref) => AppLogger());
