# Next Task

## Task ID

`PHASE-3C-PRODUCTIVITY-CORE-COMPLETE`

## Goal

Complete the Phase 3 productivity-core foundation without adding Planner events or later-phase systems.

Focus on integration, edit flows, relationship visibility, accessibility polish, and test coverage for the already implemented Phase 3A and Phase 3B entities.

## Scope

Included:

- Area, Goal, Project, Milestone, Task, Tag, and Note integration polish
- Edit flows for implemented entities where missing
- Restore flows where archive is already supported
- Clear relationship visibility between hierarchy records, tasks, tags, and notes
- Empty, loading, content, and error state consistency across Goals and Planner
- Validation-message polish for implemented forms
- Repository query helpers needed by the implemented UI only
- Focused tests for edit, restore, relationship visibility, and validation UX
- Documentation updates

Excluded:

- Calendar events
- Planner day/week/month views
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
- Preserve schema version 3 unless a documented bug requires a schema change.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Preserve Phase 1 navigation, Phase 2 settings behavior, Phase 3A hierarchy behavior, and Phase 3B task-core behavior.
- Do not implement Planner events, Spaces, templates, AI, search indexing, notifications, analytics, backup/restore, or cloud features.

## Files likely affected

- `lib/features/goals/`
- `lib/features/planner/`
- `lib/features/tasks/`
- `test/`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/FEATURE_MATRIX.md`
- `docs/TEST_PLAN.md`
- `CHANGELOG.md`
- Architecture and data-model documents only if contracts change

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

- Phase 3 productivity-core screens expose usable create, edit, archive, restore, complete, tag, and note-link behavior where supported by existing repositories.
- Relationship visibility is clear and generic.
- Repository boundaries remain intact.
- No excluded Phase 4+ feature is implemented.
- Generated code and schema snapshots remain current.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 3C productivity-core completion passes validation and documentation is current.

Do not implement Planner events, recurrence, reminders, Spaces, Templates, AI, Search indexing, Notifications, Analytics, Backup/Restore, or Cloud functionality.
