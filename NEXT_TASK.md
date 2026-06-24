# Next Task

## Task ID

`PHASE-4A-PLANNER-FOUNDATION`

## Goal

Add the initial Planner scheduling foundation without implementing later Spaces, Templates, AI, Analytics, Backup, or Cloud systems.

Focus on event and time-block persistence boundaries, basic day/week/month/agenda surfaces, and scheduling relationships with existing tasks.

## Scope

Included:

- Event and meeting domain models, repository contract, Drift tables, and migration
- Time-block domain model, repository contract, Drift tables, and migration
- Basic day, week, month, and agenda Planner views using implemented records only
- Task scheduling fields surfaced through repository/controller boundaries where already present
- Initial conflict and free-window helpers needed by the basic Planner UI
- Recurrence and reminder contracts only, without platform notification scheduling
- Focus-session contract only if needed to preserve Phase 4 architecture boundaries
- Loading, empty, content, and error states for Planner views
- Focused database, repository, migration, controller, and widget tests
- Documentation updates

Excluded:

- Local notification scheduling
- Background jobs
- Full recurrence engine
- Spaces engine
- Templates
- AI persistence or real AI provider
- Search indexing
- Analytics dashboards or charts
- Backup files or restore flows
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, and Phase 3 productivity-core behavior.
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

- Planner events and time blocks are persisted through repository boundaries.
- Basic day, week, month, and agenda views render implemented records with accessible empty/error/loading states.
- Existing tasks can be displayed in scheduling context without breaking Phase 3 task-core behavior.
- Generated code and schema snapshots are current.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 4A Planner foundation passes validation and documentation is current.

Do not implement full recurrence, platform notifications, Spaces, Templates, AI, Search indexing, Analytics, Backup/Restore, or Cloud functionality.
