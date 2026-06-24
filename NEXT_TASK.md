# Next Task

## Task ID

`PHASE-7A-NOTIFICATION-FOUNDATION`

## Goal

Add local notification infrastructure without scheduling real feature reminders yet.

Focus on replaceable notification service contracts, permission-state modeling, notification intent validation, and safe repository boundaries.

## Scope

Included:

- Notification domain models for generic notification intents
- Replaceable notification service contract
- Local placeholder implementation suitable for tests before platform scheduling is wired
- Permission-state model and validation behavior
- Repository or controller boundary only if persistence is needed for foundation state
- Safe failure types and structured logging for notification operations
- Loading, empty, content, and error states for any new notification UI
- Focused unit, provider, and widget tests
- Documentation updates

Excluded:

- Platform notification scheduling from tasks, events, goals, templates, AI, or automations
- Background jobs
- Snooze behavior
- Quiet hours
- Notification inbox persistence
- Reminder rules table
- Automation rules or runs
- AI
- Search indexing
- Analytics dashboards or charts
- Backup files or restore flows
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, Phase 3 productivity-core behavior, Phase 4 Planner behavior, Phase 5 Spaces behavior, and Phase 6 template behavior.
- Keep widgets and screens away from platform APIs.
- Keep domain contracts free of Flutter presentation packages.
- Use replaceable service/provider boundaries for notification operations.
- Do not schedule real platform notifications from feature data in this phase.

## Files likely affected

- `lib/core/notifications/`
- `lib/features/notifications/`
- `test/`
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

- Notification intent and permission contracts are testable without platform scheduling.
- Notification operations are replaceable behind providers.
- Invalid intents fail safely and log through structured logging.
- No task/event/goal/template data schedules platform notifications yet.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 7A notification foundation passes validation and documentation is current.

Do not implement real feature reminder scheduling, background jobs, snooze, quiet hours, automations, AI, Search indexing, Analytics, Backup/Restore, platform reminder scheduling, or Cloud functionality.
