# Momentum OS Test Plan

## 1. Objectives

Testing must protect:

- Core planning rules
- Persistence integrity
- Schema migrations
- Navigation
- Configurable Spaces
- Template install/uninstall safety
- Reminder scheduling
- AI approval and undo
- Backup/restore
- Accessibility-critical behavior
- Startup reliability

## 2. Test layers

### Unit tests

Use for:

- Domain entities and validation
- Controllers and use cases
- Scheduling calculations
- Goal/project progress
- Recurrence
- Free-time detection
- Automation conditions
- AI action validation
- Serialization
- Import/export transformation

### Repository and database tests

Use an isolated Drift database for:

- CRUD
- Queries and filters
- Transactions
- Relationship integrity
- Archive/restore/delete
- Migrations
- Space field/value typing
- Template install/uninstall
- Backup serialization

Phase 2 adds focused tests for database open/close, schema version 1, foreign-key enablement, fresh database creation, schema snapshot presence, UUID v4 and deterministic ID services, UTC clock behavior, typed settings defaults/updates/watch streams/persistence/reset/validation, repository failure translation, Riverpod provider boundaries, database startup success/failure/retry recovery, backup envelope round-trip, and seed/template contract validation.

Phase 3A adds focused tests for schema version 2, migration from version 1, generated Drift migration verification, hierarchy repository create/watch/archive/restore/delete behavior, validation of milestone ownership and goal hierarchy cycles, repository-boundary failure translation, hierarchy provider boundaries, and Goals screen hierarchy rendering.

Phase 3B adds focused tests for schema version 3, generated Drift migration verification from version 2, task/subtask/tag/note repository behavior, task completion/archive/restore/delete semantics, task hierarchy cycle validation, repository-boundary failure translation, task-core provider boundaries, and Planner task-core rendering.

### Widget tests

Cover:

- Loading, empty, content, and error states
- Forms and validation
- Quick Add
- Navigation controls
- Entity cards
- Dialogs and undo
- Accessibility labels
- Theme behavior

### Integration tests

Cover critical user journeys:

- Launch and initialization
- Create Area → Goal → Project → Task
- Schedule and complete a Task
- Start and finish a Focus Session
- Create a Space and record
- Install and remove a template safely
- Schedule a reminder
- Approve and undo a mock AI action
- Backup, reset, and restore

### Manual Android verification

Use a physical Android device for:

- Startup
- Navigation
- System back
- Keyboard/forms
- Date/time pickers
- Notifications
- Background scheduling
- External URL/WhatsApp launching
- File picker and sharing
- Biometric lock
- Backup restore
- Performance and scrolling

## 3. Required commands

Normal change:

```powershell
dart format .
flutter analyze
flutter test
```

Generated-model or Drift change:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev make-migrations
dart format .
flutter analyze
flutter test
```

Android build:

```powershell
flutter build apk --debug
```

Connected device:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb devices
& $adb install -r "build\app\outputs\flutter-apk\app-debug.apk"
```

## 4. Baseline quality gate

A task is not complete unless:

- Formatting succeeds.
- Analyzer has no unresolved issues.
- All relevant focused tests pass.
- Full `flutter test` passes.
- New behavior has appropriate tests.
- Documentation is updated.
- Known limitations are reported.
- Generated files are current where applicable.

## 5. Migration testing

For each database schema version:

1. Test fresh creation.
2. Test upgrade from every supported prior snapshot.
3. Verify row counts and important field values.
4. Verify foreign-key behavior.
5. Verify indexes and common queries.
6. Verify archive/delete metadata.
7. Verify no user data is silently discarded.
8. Test failure reporting where a migration cannot proceed.

## 6. Template safety testing

Every template must test:

- Installation into an empty app
- Installation beside existing unrelated Spaces
- Duplicate install handling
- Editable installed configuration
- Upgrade of template definitions
- Removal while preserving records
- Removal while archiving records
- Export/delete flow
- No shell or dashboard crash after removal

## 7. AI safety testing

Test:

- Invalid tool proposal rejection
- Preview before write
- User edits to proposal
- Approval and cancellation
- Transaction failure
- Action logging
- Safe undo
- Undo not offered when unsafe
- No direct AI database access
- No secret in logs or persisted messages

## 8. Notification testing

Test:

- Schedule
- Cancel
- Reschedule
- Recurrence
- Snooze
- Quiet hours
- Timezone/date-format changes
- Restart recovery
- Permission denial
- Invalid/deleted target
- Duplicate prevention

## 9. Backup and restore testing

Test:

- Complete JSON round-trip
- Version metadata
- Empty database
- Realistic dataset
- Invalid/corrupt file
- Older supported backup
- Relationship integrity
- User confirmation before overwrite
- Rollback or recovery after failure
- Exclusion of secrets

## 10. Performance checks

Use realistic seeded datasets to check:

- Startup
- Task and event queries
- Planner scrolling
- Search
- Space table/board views
- Dashboard aggregation
- Chart computation
- Backup/export

Optimize based on measurement rather than speculation.

## 11. Accessibility checks

Verify:

- Screen-reader labels
- Text scaling
- Contrast
- Touch targets
- Focus order
- Keyboard interaction where relevant
- Non-color status cues
- Error announcements
