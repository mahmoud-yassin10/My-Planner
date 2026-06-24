import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/app/theme/app_theme.dart';
import 'package:momentum_os/features/spaces/application/spaces_controller.dart';
import 'package:momentum_os/features/spaces/domain/spaces_models.dart';
import 'package:momentum_os/features/spaces/presentation/spaces_screen.dart';

void main() {
  testWidgets('Spaces screen renders loading state', (tester) async {
    await _pumpSpaces(
      tester,
      override: spacesSnapshotProvider.overrideWith(
        (ref) => const Stream.empty(),
      ),
    );

    expect(find.text('Loading Spaces'), findsOneWidget);
  });

  testWidgets('Spaces screen renders empty state', (tester) async {
    await _pumpSpaces(
      tester,
      override: spacesSnapshotProvider.overrideWith(
        (ref) => Stream.value(const SpacesSnapshot()),
      ),
    );

    expect(
      find.byKey(const ValueKey('spacesDestinationTitle')),
      findsOneWidget,
    );
    expect(find.text('No Spaces yet'), findsOneWidget);
    expect(
      find.text('Generic Spaces records will appear here after setup.'),
      findsOneWidget,
    );
  });

  testWidgets('Spaces screen renders error state with retry', (tester) async {
    await _pumpSpaces(
      tester,
      override: spacesSnapshotProvider.overrideWith(
        (ref) => Stream<SpacesSnapshot>.error(StateError('failed')),
      ),
    );

    expect(find.text('Spaces could not load'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('Spaces screen renders content state', (tester) async {
    await _pumpSpaces(
      tester,
      override: spacesSnapshotProvider.overrideWith(
        (ref) => Stream.value(_contentSnapshot),
      ),
    );

    expect(find.text('Spaces'), findsWidgets);
    expect(find.text('Space A'), findsOneWidget);
    expect(find.text('Record Type A'), findsOneWidget);
    expect(find.text('New Space'), findsOneWidget);
    expect(find.text('Record Type'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Field A'), findsOneWidget);
    expect(find.text('Status A'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Record A'), findsOneWidget);
    expect(find.text('related'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Filter A'), findsOneWidget);
    expect(find.text('View A'), findsOneWidget);
  });
}

Future<void> _pumpSpaces(
  WidgetTester tester, {
  required dynamic override,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [override],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: SpacesScreen()),
      ),
    ),
  );
  await tester.pump();
}

final _now = DateTime.utc(2026, 6, 24, 9);

final _contentSnapshot = SpacesSnapshot(
  spaces: [
    SpaceDefinition(
      id: 'space-1',
      name: 'Space A',
      description: 'Generic records',
      sortOrder: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  recordTypes: [
    SpaceRecordType(
      id: 'record-type-1',
      spaceId: 'space-1',
      name: 'Record Type A',
      sortOrder: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  fields: [
    SpaceFieldDefinition(
      id: 'field-1',
      recordTypeId: 'record-type-1',
      name: 'Field A',
      fieldKey: 'field_a',
      fieldType: SpaceFieldType.text,
      isRequired: true,
      sortOrder: 0,
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  statuses: [
    SpaceStatusDefinition(
      id: 'status-1',
      recordTypeId: 'record-type-1',
      name: 'Status A',
      sortOrder: 0,
      isDefault: true,
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  records: [
    SpaceRecord(
      id: 'record-1',
      recordTypeId: 'record-type-1',
      title: 'Record A',
      fieldsJson: '{"field_a":"Value A"}',
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  links: [
    SpaceRecordLink(
      id: 'link-1',
      sourceRecordId: 'record-1',
      targetType: 'task',
      targetId: 'task-1',
      relationshipType: 'related',
      createdAt: _now,
    ),
  ],
  filters: [
    SpaceSavedFilter(
      id: 'filter-1',
      spaceId: 'space-1',
      name: 'Filter A',
      filterJson: '{}',
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  views: [
    SpaceSavedView(
      id: 'view-1',
      spaceId: 'space-1',
      name: 'View A',
      viewType: SpaceViewType.list,
      configJson: '{}',
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
);
