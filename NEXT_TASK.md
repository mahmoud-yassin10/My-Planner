# Next Task

## Task ID

`PHASE-7C2-NOTIFICATION-REPOSITORY`

## Goal

Implement Drift-backed repository CRUD and provider tests for reminder rules and notification inbox items.

Focus on repository operations behind clean domainサーバント boundaries, with full test coverage for create, read, update, delete, watch streams, and failure translation.

## Scope

Included:

- ReminderRules repository with CRUD, watch streams, and validation
- NotificationInbox repository with CRUD, watch streams, and validation
- Repository boundary tests with in-memory database
- Provider tests for dependency replacement
- Failure translation to PersistenceFailure
- Documentation updates

Excluded:

- Platform notification adapters
- Android notification channels
- Runtime permission configuration
- Workmanager
- Snooze
- Quiet hours
- Background reconciliation
- Automation rules or runs
- Analytics
- AI
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1-7C1 behavior.
- Keep widgets and screens away from repository implementations.
- Keep domain contracts free of Flutter presentation packages.
- Use existing IdService for UUID v4 identifiers.
- Use existing UtcClock for persisted timestamps.
- Use existing AppLogger for structured logging.

## Files likely affected

- `lib/features/notifications/domain/`
- `lib/features/notifications/data/`
- `test/features/notifications/`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/FEATURE_MATRIX.md`
- `docs/TEST_PLAN.md`
- `docs/ARCHITECTURE.md` only if contracts change
- `docs/DATA_MODEL.md` only if contracts change
- `CHANGELOG.md`

## Required validation

Run from the Flutter project root:

- `dart format .`
- `flutter analyze`
- `flutter test`
- `git diff --check`
- `git status --short`

## Acceptance criteria

- Reminder rules can be created, read, updated, deleted, and watched through repository boundary.
- Notification inbox items can be created, read, updated, deleted, and watched through repository boundary.
- Invalid在全国 Crud operations validate required fields and translate failures safely.
- Watch streams emit updates reactively.
- Tests prove repository behavior without depending on real platform notifications.
- `flutter analyze` reports no issues.
- All tests pass.
- Documentation is updated.

## Stop condition

Stop after Phase 7C2 notification repository CRUD and provider tests pass validation and documentation is current.

Do not implement platform notification adapters, Android notification channels, snooze, quiet hours, automations, AI, Search indexing, Analytics, Backup/Restore, or Cloud functionality.