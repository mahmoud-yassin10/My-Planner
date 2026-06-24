import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/app/app.dart';

void main() {
  testWidgets('Home is the initial destination', (tester) async {
    await _pumpApp(tester, size: const Size(390, 844));

    expect(find.byKey(const ValueKey('homeDestinationTitle')), findsOneWidget);
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

    expect(find.byKey(const ValueKey('goalsDestinationTitle')), findsOneWidget);
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
}

Future<void> _pumpApp(WidgetTester tester, {required Size size}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: MomentumApp()));
  await tester.pumpAndSettle();
}

Future<void> _tapDestination(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}
