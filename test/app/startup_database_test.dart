import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/app/app.dart';
import 'package:momentum_os/app/startup/startup_host.dart';
import 'package:momentum_os/core/database/app_database.dart';
import 'package:momentum_os/core/database/database_initializer.dart';
import 'package:momentum_os/core/logging/app_logger.dart';

void main() {
  testWidgets('database startup success shows the app', (tester) async {
    final records = <AppLogRecord>[];

    await _pumpStartup(
      tester,
      records: records,
      initializer: DatabaseInitializer(
        openDatabase: AppDatabase.inMemory,
        logger: AppLogger(sink: records.add),
      ),
    );

    expect(find.byKey(const ValueKey('homeDestinationTitle')), findsOneWidget);
    expect(records, isEmpty);
  });

  testWidgets('database startup failure shows recoverable startup screen', (
    tester,
  ) async {
    final records = <AppLogRecord>[];

    await _pumpStartup(
      tester,
      records: records,
      initializer: DatabaseInitializer(
        openDatabase: () => throw StateError('database unavailable'),
        logger: AppLogger(sink: records.add),
      ),
    );

    expect(find.text('Momentum OS could not start'), findsOneWidget);
    expect(find.text('Retry startup'), findsOneWidget);
    expect(records.map((record) => record.operation), contains('initialize'));
  });

  testWidgets('database startup retry can recover', (tester) async {
    final records = <AppLogRecord>[];
    var attempts = 0;

    await _pumpStartup(
      tester,
      records: records,
      initializer: DatabaseInitializer(
        openDatabase: () {
          attempts++;
          if (attempts == 1) {
            throw StateError('database unavailable once');
          }
          return AppDatabase.inMemory();
        },
        logger: AppLogger(sink: records.add),
      ),
    );

    expect(find.text('Momentum OS could not start'), findsOneWidget);

    await tester.tap(find.text('Retry startup'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.byKey(const ValueKey('homeDestinationTitle')), findsOneWidget);
  });
}

Future<void> _pumpStartup(
  WidgetTester tester, {
  required List<AppLogRecord> records,
  required DatabaseInitializer initializer,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseInitializerProvider.overrideWithValue(initializer),
        appLoggerProvider.overrideWithValue(AppLogger(sink: records.add)),
      ],
      child: StartupHost(
        initializer: defaultAppInitializer,
        child: const MomentumApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
