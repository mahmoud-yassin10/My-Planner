import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/app/theme/app_theme.dart';
import 'package:momentum_os/features/templates/application/template_controller.dart';
import 'package:momentum_os/features/templates/domain/template_models.dart';
import 'package:momentum_os/features/templates/presentation/templates_foundation_panel.dart';

void main() {
  testWidgets('Template panel renders loading state', (tester) async {
    await _pumpTemplates(
      tester,
      override: templatesSnapshotProvider.overrideWith(
        (ref) => const Stream.empty(),
      ),
    );

    expect(find.text('Loading templates'), findsOneWidget);
  });

  testWidgets('Template panel renders empty state', (tester) async {
    await _pumpTemplates(
      tester,
      override: templatesSnapshotProvider.overrideWith(
        (ref) => Stream.value(const TemplatesSnapshot()),
      ),
    );

    expect(
      find.byKey(const ValueKey('templatesFoundationTitle')),
      findsOneWidget,
    );
    expect(find.text('No templates available'), findsOneWidget);
    expect(
      find.text('Template packs will be added in a later phase.'),
      findsOneWidget,
    );
  });

  testWidgets('Template panel renders error state with retry', (tester) async {
    await _pumpTemplates(
      tester,
      override: templatesSnapshotProvider.overrideWith(
        (ref) => Stream<TemplatesSnapshot>.error(StateError('failed')),
      ),
    );

    expect(find.text('Templates could not load'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('Template panel renders definitions and installations', (
    tester,
  ) async {
    await _pumpTemplates(
      tester,
      override: templatesSnapshotProvider.overrideWith(
        (ref) => Stream.value(_snapshot),
      ),
    );

    expect(find.text('Generic template'), findsOneWidget);
    expect(find.text('Installed'), findsOneWidget);
    expect(find.text('Installation history'), findsOneWidget);
    expect(find.text('generic_template'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
  });
}

Future<void> _pumpTemplates(
  WidgetTester tester, {
  required dynamic override,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [override],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: TemplatesFoundationPanel()),
      ),
    ),
  );
  await tester.pump();
}

final _now = DateTime.utc(2026, 6, 24, 9);

final _snapshot = TemplatesSnapshot(
  definitions: const [
    TemplateDefinition(
      key: 'generic_template',
      name: 'Generic template',
      description: 'Reusable configuration descriptor.',
      version: '1.0.0',
    ),
  ],
  installations: [
    TemplateInstallation(
      id: 'template-installation-1',
      templateKey: 'generic_template',
      templateVersion: '1.0.0',
      installedAt: _now,
      updatedAt: _now,
      configurationSnapshotJson: '{}',
      status: TemplateInstallationStatus.installed,
    ),
  ],
);
