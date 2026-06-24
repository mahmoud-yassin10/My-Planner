import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/app/app.dart';
import 'package:momentum_os/app/routing/app_router.dart';
import 'package:momentum_os/app/shell/quick_add_sheet.dart';
import 'package:momentum_os/app/startup/startup_host.dart';
import 'package:momentum_os/core/logging/app_logger.dart';
import 'package:momentum_os/core/widgets/foundation_states.dart';

void main() {
  group('app shell navigation', () {
    testWidgets('Home is the initial destination', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      expect(
        find.byKey(const ValueKey('homeDestinationTitle')),
        findsOneWidget,
      );
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('Navigation to Planner', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await _tapDestination(tester, 'Planner');

      expect(
        find.byKey(const ValueKey('plannerDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Navigation to Spaces', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await _tapDestination(tester, 'Spaces');

      expect(
        find.byKey(const ValueKey('spacesDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Navigation to Goals', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await _tapDestination(tester, 'Goals');

      expect(
        find.byKey(const ValueKey('goalsDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Navigation to Insights', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await _tapDestination(tester, 'Insights');

      expect(
        find.byKey(const ValueKey('insightsDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Compact widths use bottom navigation shell', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      expect(
        find.byKey(const ValueKey('compactNavigationShell')),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('Wider widths use navigation rail shell', (tester) async {
      await _pumpApp(tester, size: const Size(900, 900));

      expect(find.byKey(const ValueKey('wideNavigationShell')), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('global actions', () {
    testWidgets('Quick Add is visible and opens', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      expect(find.byTooltip('Open Quick Add'), findsOneWidget);

      await tester.tap(find.byTooltip('Open Quick Add'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('quickAddTitle')), findsOneWidget);
      expect(
        find.text('Creation flows will be added in a later phase.'),
        findsOneWidget,
      );
    });

    testWidgets('Quick Add shows generic options', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await tester.tap(find.byTooltip('Open Quick Add'));
      await tester.pumpAndSettle();

      for (final label in quickAddOptionLabels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('AI route is reachable', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await tester.tap(find.byTooltip('Open AI Copilot'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ai copilotDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Search route is reachable', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await tester.tap(find.byTooltip('Open Global Search'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('searchDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Notifications route is reachable', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await tester.tap(find.byTooltip('Open Notification Inbox'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('notificationsDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Settings route is reachable', (tester) async {
      await _pumpApp(tester, size: const Size(390, 844));

      await tester.tap(find.byTooltip('Open Settings'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('settingsDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('global action tooltips provide accessible labels', (
      tester,
    ) async {
      await _pumpApp(tester, size: const Size(390, 844));

      expect(find.byTooltip('Open Quick Add'), findsOneWidget);
      expect(find.byTooltip('Open AI Copilot'), findsOneWidget);
      expect(find.byTooltip('Open Global Search'), findsOneWidget);
      expect(find.byTooltip('Open Notification Inbox'), findsOneWidget);
      expect(find.byTooltip('Open Settings'), findsOneWidget);
    });
  });

  group('foundation states', () {
    testWidgets('Loading state renders accessibly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FoundationLoadingState(message: 'Loading foundation'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading foundation'), findsOneWidget);
    });

    testWidgets('Empty state renders title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FoundationEmptyState(
            title: 'Nothing here',
            message: 'Content will appear here later.',
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Content will appear here later.'), findsOneWidget);
    });

    testWidgets('Error state renders title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FoundationErrorState(
            title: 'Something failed',
            message: 'Try again later.',
          ),
        ),
      );

      expect(find.text('Something failed'), findsOneWidget);
      expect(find.text('Try again later.'), findsOneWidget);
    });

    testWidgets('Error retry action is invoked', (tester) async {
      var retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: FoundationErrorState(
            title: 'Something failed',
            message: 'Try again later.',
            actionLabel: 'Try again',
            onRetry: () => retries++,
          ),
        ),
      );

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(retries, 1);
    });
  });

  group('structured logger', () {
    test('records levels and safe metadata', () {
      final records = <AppLogRecord>[];
      final logger = AppLogger(sink: records.add);

      logger.debug('test', 'debugOperation', 'debug message');
      logger.info(
        'test',
        'infoOperation',
        'info message',
        metadata: {'safeCount': 2, 'apiKey': 'do-not-log'},
      );
      logger.warning('test', 'warningOperation', 'warning message');

      expect(records.map((record) => record.level), [
        AppLogLevel.debug,
        AppLogLevel.info,
        AppLogLevel.warning,
      ]);
      expect(records[1].component, 'test');
      expect(records[1].operation, 'infoOperation');
      expect(records[1].metadata['safeCount'], 2);
      expect(records[1].metadata['apiKey'], '<redacted>');
    });

    test('records errors and stack traces', () {
      final records = <AppLogRecord>[];
      final logger = AppLogger(sink: records.add);
      final error = StateError('failed');
      final stackTrace = StackTrace.current;

      logger.error(
        'test',
        'errorOperation',
        'error message',
        error: error,
        stackTrace: stackTrace,
      );

      expect(records.single.level, AppLogLevel.error);
      expect(records.single.error, same(error));
      expect(records.single.stackTrace, same(stackTrace));
    });
  });

  group('startup handling', () {
    testWidgets('Startup success shows the app', (tester) async {
      await _pumpStartupHost(
        tester,
        initializer: () async {},
        records: <AppLogRecord>[],
      );

      expect(
        find.byKey(const ValueKey('homeDestinationTitle')),
        findsOneWidget,
      );
    });

    testWidgets('Startup failure shows recoverable screen', (tester) async {
      final records = <AppLogRecord>[];

      await _pumpStartupHost(
        tester,
        records: records,
        initializer: () async => throw StateError('startup failed'),
      );

      expect(find.text('Momentum OS could not start'), findsOneWidget);
      expect(find.text('Retry startup'), findsOneWidget);
      expect(records.single.level, AppLogLevel.error);
      expect(records.single.operation, 'initialize');
    });

    testWidgets('Startup retry can recover', (tester) async {
      final records = <AppLogRecord>[];
      var attempts = 0;

      await _pumpStartupHost(
        tester,
        records: records,
        initializer: () async {
          attempts++;
          if (attempts == 1) {
            throw StateError('startup failed once');
          }
        },
      );

      expect(find.text('Momentum OS could not start'), findsOneWidget);

      await tester.tap(find.text('Retry startup'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(
        find.byKey(const ValueKey('homeDestinationTitle')),
        findsOneWidget,
      );
      expect(records.single.level, AppLogLevel.error);
    });
  });

  testWidgets('Route error handling renders safe screen', (tester) async {
    await _pumpWithSize(
      tester,
      const Size(390, 844),
      ProviderScope(
        overrides: [
          appInitialLocationProvider.overrideWithValue('/not-a-real-route'),
        ],
        child: const MomentumApp(),
      ),
    );

    expect(find.text('Route unavailable'), findsOneWidget);
    expect(
      find.text('This destination is not available in the app foundation yet.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpApp(WidgetTester tester, {required Size size}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: MomentumApp()));
  await tester.pumpAndSettle();
}

Future<void> _pumpStartupHost(
  WidgetTester tester, {
  required AppInitializer initializer,
  required List<AppLogRecord> records,
}) async {
  await _pumpWithSize(
    tester,
    const Size(390, 844),
    ProviderScope(
      overrides: [
        appLoggerProvider.overrideWithValue(AppLogger(sink: records.add)),
      ],
      child: StartupHost(initializer: initializer, child: const MomentumApp()),
    ),
  );
}

Future<void> _pumpWithSize(
  WidgetTester tester,
  Size size,
  Widget widget,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

Future<void> _tapDestination(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}
