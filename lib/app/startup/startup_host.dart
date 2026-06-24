import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../core/widgets/foundation_states.dart';
import '../theme/app_theme.dart';

typedef AppInitializer = Future<void> Function();

Future<void> defaultAppInitializer() async {}

class StartupHost extends ConsumerStatefulWidget {
  const StartupHost({
    super.key,
    required this.initializer,
    required this.child,
  });

  final AppInitializer initializer;
  final Widget child;

  @override
  ConsumerState<StartupHost> createState() => _StartupHostState();
}

class _StartupHostState extends ConsumerState<StartupHost> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _isStarting = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _error = null;
      _stackTrace = null;
      _isStarting = true;
    });

    try {
      await widget.initializer();
      if (!mounted) {
        return;
      }
      setState(() {
        _isStarting = false;
      });
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(
            'startup',
            'initialize',
            'Application startup failed.',
            error: error,
            stackTrace: stackTrace,
          );

      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
        _isStarting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      return const MaterialApp(
        title: 'Momentum OS',
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: FoundationLoadingState(message: 'Starting Momentum OS'),
        ),
      );
    }

    if (_error != null) {
      return StartupErrorApp(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _initialize,
      );
    }

    return widget.child;
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    required this.onRetry,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum OS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: FoundationErrorState(
          title: 'Momentum OS could not start',
          message: 'Something went wrong during startup. You can retry safely.',
          actionLabel: 'Retry startup',
          onRetry: onRetry,
        ),
      ),
    );
  }
}
