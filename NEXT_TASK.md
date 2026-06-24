# Next Task

## Task ID

`PHASE-4B-PLANNER-COMPLETE`

## Goal

Finish Phase 4 Planner scheduling behavior without implementing later Spaces, Templates, AI, Analytics, Backup, or Cloud systems.

Focus on completing the Planner vertical slice around already implemented events, time blocks, tasks, recurrence logic, reminders contracts, focus sessions, free-time/conflict behavior, and estimated versus actual effort.

## Scope

Included:

- Event and time-block edit, archive, restore, and delete flows where supported
- Task scheduling and rescheduling controls using existing task scheduling fields
- Recurrence rule evaluation for local schedule expansion only
- Reminder contract persistence and validation without platform notification scheduling
- Focus session domain model, repository contract, Drift tables, and UI surface
- Planned versus actual duration updates through task and focus-session boundaries
- Conflict detection and free-window behavior surfaced clearly in Planner views
- Loading, empty, content, and error state consistency across Planner views
- Focused database, repository, migration, controller, domain, and widget tests
- Documentation updates

Excluded:

- Local notification scheduling
- Background jobs
- Platform notification scheduling
- Spaces engine
- Templates
- AI persistence or real AI provider
- Search indexing
- Analytics dashboards or charts
- Backup files or restore flows
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, Phase 3 productivity-core behavior, and Phase 4A Planner foundation behavior.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Use repository/controller boundaries for Planner persistence and scheduling behavior.
- Do not add platform notification scheduling, Spaces, templates, AI, search indexing, analytics, backup/restore, or cloud features.

## Files likely affected

- `lib/features/planner/`
- `lib/core/database/`
- `test/`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/FEATURE_MATRIX.md`
- `docs/TEST_PLAN.md`
- `docs/DATA_MODEL.md`
- `docs/ARCHITECTURE.md` only if contracts change
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

- Planner events, time blocks, focus sessions, and scheduled tasks remain behind repository/controller boundaries.
- Day, week, month, and agenda views support implemented scheduling behavior with accessible empty/error/loading states.
- Recurrence expansion is deterministic and local-only.
- Reminder contracts are validated but do not schedule platform notifications.
- Conflict and free-window behavior is covered by tests.
- Planned versus actual effort can be recorded through implemented Phase 4 boundaries.
- Generated code and schema snapshots are current.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 4B Planner completion passes validation and documentation is current.

Do not implement full recurrence, platform notifications, Spaces, Templates, AI, Search indexing, Analytics, Backup/Restore, or Cloud functionality.
