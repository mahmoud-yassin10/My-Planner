# Next Task

## Task ID

`PHASE-3B-TASK-CORE`

## Goal

Extend the productivity core using the Phase 3A hierarchy foundation.

Implement Tasks, subtasks, tags, and notes only, with domain models, Drift tables, repositories, controllers where useful, validation, archive/delete behavior, focused UI updates, migrations, and tests.

## Scope

Included:

- Tasks linked optionally to Areas, Goals, Projects, and Milestones
- Subtasks through `parentTaskId`
- Task status, priority, energy requirement, estimates, due dates, scheduled windows, completion metadata, archive metadata, and notes field
- Task dependency table only if needed for documented dependency behavior in this phase
- Tags
- Entity-tag relationships for Phase 3A/3B entities
- Notes with generic entity links where needed
- UUID v4 identifiers generated before insert
- UTC `createdAt` and `updatedAt`
- Explicit archive, restore, completion, and delete semantics
- Drift schema version 3 migration from version 2
- Repository contracts and Drift-backed implementations
- Riverpod providers exposing interfaces
- Loading, empty, content, and error states for implemented screens
- Focused unit, repository, database, migration, widget, and integration-style tests
- Documentation updates

Excluded:

- Planner calendar events
- Recurrence engine
- Reminders and notifications
- Focus sessions
- Spaces engine
- Templates
- AI persistence
- Search indexing
- Analytics
- Backup files or restore flows
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Use the existing Drift database and increment schema version to 3.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Use typed repositories and Riverpod providers.
- Preserve Phase 1 navigation, Phase 2 settings behavior, and Phase 3A hierarchy behavior.
- Do not implement planner events, Spaces, templates, AI, search indexing, notifications, analytics, backup/restore, or cloud features.

## Files likely affected

- `lib/core/database/`
- `lib/features/goals/`
- `lib/features/planner/`
- `lib/features/tasks/`
- `lib/features/tags/`
- `lib/features/notes/`
- `test/`
- `drift_schemas/`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA_MODEL.md`
- `docs/FEATURE_MATRIX.md`
- `docs/TEST_PLAN.md`
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

- Tasks, subtasks, tags, and notes are implemented only.
- Drift schema version 3 and migration from version 2 are tested.
- Repository boundaries prevent UI access to Drift.
- UUID and UTC timestamp conventions are followed.
- Archive/delete/complete semantics are explicit and tested.
- Screens include relevant loading, empty, content, and error states.
- No excluded Phase 4+ feature is implemented.
- Generated code and schema snapshots are current.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 3B task core passes validation and documentation is current.

Do not implement Planner events, recurrence, reminders, Spaces, Templates, AI, Search indexing, Notifications, Analytics, Backup/Restore, or Cloud functionality.
