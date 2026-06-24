# Next Task

## Task ID

`PHASE-3A-HIERARCHY-CORE`

## Goal

Implement the first productivity-core vertical slice for Momentum OS using the Phase 2 persistence foundation.

Create Areas, Goals hierarchy, Projects, and Milestones only, with domain models, Drift tables, repositories, controllers where useful, placeholder-to-real UI updates, validation, archive behavior, and focused tests.

## Scope

Included:

- Areas
- Goals with parent-child hierarchy
- Projects linked optionally to Areas and Goals
- Milestones linked to Goals or Projects
- UUID v4 identifiers generated before insert
- UTC `createdAt` and `updatedAt`
- Archive metadata where supported
- Explicit delete semantics
- Drift schema version 2 migration from version 1
- Repository contracts and Drift-backed implementations
- Riverpod providers exposing interfaces
- Loading, empty, content, and error states for the implemented screens
- Focused unit, repository, database, migration, widget, and integration-style tests
- Documentation updates

Excluded:

- Tasks and subtasks
- Events and planner persistence
- Notes and tags
- Spaces engine
- Templates
- AI persistence
- Search indexing
- Notifications
- Analytics
- Backup files or restore flows
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Use the existing Drift database and increment schema version to 2.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Use typed repositories and Riverpod providers.
- Use transactions for multi-table writes where needed.
- Preserve Phase 1 navigation and Phase 2 settings behavior.
- Do not implement tasks, events, notes, spaces, templates, AI, search, notifications, analytics, backup/restore, or cloud features.

## Files likely affected

- `lib/core/database/`
- `lib/features/areas/`
- `lib/features/goals/`
- `lib/features/projects/`
- `lib/features/milestones/`
- `lib/shared/repositories/`
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

- Areas, Goals hierarchy, Projects, and Milestones are implemented only.
- Drift schema version 2 and migration from version 1 are tested.
- Repository boundaries prevent UI access to Drift.
- UUID and UTC timestamp conventions are followed.
- Archive/delete semantics are explicit and tested.
- Screens include relevant loading, empty, content, and error states.
- No excluded Phase 3B+ feature is implemented.
- Generated code and schema snapshots are current.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 3A hierarchy core passes validation and documentation is current.

Do not implement Tasks, Events, Notes, Spaces, Templates, AI, Search, Notifications, Analytics, Backup/Restore, or Cloud functionality.
