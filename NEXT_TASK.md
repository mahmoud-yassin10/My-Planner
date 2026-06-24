# Next Task

## Task ID

`PHASE-7B-REMINDER-SCHEDULING`

## Goal

Add local reminder scheduling behind the Phase 7A notification service boundary.

Focus on a replaceable platform-adapter shape, safe scheduling and cancellation contracts, permission-denial handling, and tests that prove scheduling behavior without wiring feature data into reminders yet.

## Scope

Included:

- Platform-notification adapter abstraction for scheduling and canceling generic notification intents
- Local notification service implementation that delegates to the adapter only after validation
- Deterministic notification identifier strategy for scheduled intents
- Permission-denied and unavailable-platform behavior
- Schedule, cancel, and reschedule operations for generic intents
- Safe failure types and structured logging for scheduling operations
- Tests using injected fake adapters; do not depend on console output
- Documentation updates

Excluded:

- Task, event, goal, template, Space, AI, or automation reminders
- Reminder rules table
- Notification inbox persistence
- Background jobs
- Snooze behavior
- Quiet hours
- Automation rules or runs
- Search indexing
- Analytics dashboards or charts
- Backup files or restore flows
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, Phase 3 productivity-core behavior, Phase 4 Planner behavior, Phase 5 Spaces behavior, Phase 6 template behavior, and Phase 7A notification foundation behavior.
- Keep widgets and screens away from platform APIs.
- Keep domain contracts free of Flutter presentation packages.
- Keep scheduling behind replaceable service/provider boundaries.
- Do not schedule reminders from feature records in this phase.
- Do not add persistence unless the task is explicitly updated to include reminder rules or notification inbox storage.

## Files likely affected

- `lib/core/notifications/`
- `lib/features/notifications/`
- `test/core/`
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

- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `dart run drift_dev make-migrations`
- `dart format .`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- `git diff --check`
- `git status --short`

## Acceptance criteria

- Generic notification intents can be scheduled, canceled, and rescheduled through a replaceable boundary.
- Invalid intents and permission-denied states fail safely and log through structured logging.
- Tests prove adapter calls without depending on real platform notifications.
- No task/event/goal/template/Space data schedules reminders yet.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 7B reminder scheduling foundation passes validation and documentation is current.

Do not implement feature-driven reminders, reminder rules persistence, notification inbox persistence, background jobs, snooze, quiet hours, automations, AI, Search indexing, Analytics, Backup/Restore, or Cloud functionality.
