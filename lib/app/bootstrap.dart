import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import 'app.dart';
import 'startup/startup_host.dart';

void bootstrap({
  AppInitializer initializer = defaultAppInitializer,
  AppLogger? logger,
}) {
  WidgetsFlutterBinding.ensureInitialized();

  final appLogger = logger ?? AppLogger();
  final previousOnError = FlutterError.onError;

  FlutterError.onError = (details) {
    appLogger.error(
      'flutter',
      'frameworkError',
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );

    if (previousOnError != null) {
      previousOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  runApp(
    ProviderScope(
      overrides: [appLoggerProvider.overrideWithValue(appLogger)],
      child: StartupHost(initializer: initializer, child: const MomentumApp()),
    ),
  );
}
