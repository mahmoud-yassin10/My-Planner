import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import 'app.dart';
import 'startup/startup_host.dart';

const uncaughtFlutterFrameworkErrorMessage =
    'Uncaught Flutter framework error.';

void bootstrap({
  AppInitializer initializer = defaultAppInitializer,
  AppLogger? logger,
}) {
  WidgetsFlutterBinding.ensureInitialized();

  final appLogger = logger ?? AppLogger();
  configureFlutterFrameworkErrorLogging(appLogger);

  runApp(
    ProviderScope(
      overrides: [appLoggerProvider.overrideWithValue(appLogger)],
      child: StartupHost(initializer: initializer, child: const MomentumApp()),
    ),
  );
}

void Function(FlutterErrorDetails details)?
configureFlutterFrameworkErrorLogging(AppLogger appLogger) {
  final previousOnError = FlutterError.onError;

  FlutterError.onError = (details) {
    appLogger.error(
      'flutter',
      'frameworkError',
      uncaughtFlutterFrameworkErrorMessage,
      metadata: {'exceptionType': details.exception.runtimeType.toString()},
      error: details.exception,
      stackTrace: details.stack,
    );

    if (previousOnError != null) {
      previousOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  return previousOnError;
}
