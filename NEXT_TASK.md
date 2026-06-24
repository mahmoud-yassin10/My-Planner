# Next Task

## Task ID

`PHASE-5B-SPACES-VIEWS-FOUNDATION`

## Goal

Add configured Space view rendering and lifecycle polish on top of the Phase 5A Spaces foundation without implementing templates, AI, analytics dashboards, backup/restore, or cloud synchronization.

Focus on rendering saved view configurations for existing Space records and adding safe archive/restore/delete lifecycle operations for implemented Spaces entities.

## Scope

Included:

- Repository/controller lifecycle operations for implemented Spaces entities
- Archive and restore support where Phase 5A tables include reversible archive metadata
- Explicit permanent delete behavior with foreign-key protection tests
- Basic saved-view rendering for list, table, board, and card view types using existing saved view configuration
- Deterministic validation for saved view configuration JSON
- Spaces screen view-selection state and accessible empty/error/loading states
- Focused repository, database, controller, widget, and migration-regression tests
- Documentation updates

Excluded:

- Template installer/uninstaller behavior
- Template packs or example records
- Calendar view implementation
- AI persistence or real AI provider
- Search indexing
- Analytics dashboards or charts
- Backup files or restore flows
- Cloud synchronization
- Platform notification scheduling

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, Phase 3 productivity-core behavior, Phase 4 Planner behavior, and Phase 5A Spaces foundation behavior.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Use repository/controller boundaries for Spaces persistence and validation behavior.
- Do not add templates, AI, search indexing, analytics, backup/restore, platform notifications, or cloud features.
- Do not change schema version unless the Phase 5B implementation truly requires a schema contract change.

## Files likely affected

- `lib/features/spaces/`
- `test/features/spaces/`
- `test/repositories/spaces_repository_test.dart`
- `test/database/app_database_test.dart`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/FEATURE_MATRIX.md`
- `docs/TEST_PLAN.md`
- `docs/DATA_MODEL.md` only if contracts change
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

- Existing Phase 5A Spaces records remain available through repository/controller boundaries.
- Saved list, table, board, and card views render generic records without hard-coded personal examples.
- Space lifecycle operations are deterministic and tested.
- Delete behavior is explicit and foreign-key protected where relevant.
- No template installer/uninstaller behavior is implemented.
- Generated code and schema snapshots remain current if schema generation is touched.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 5B Spaces view foundation passes validation and documentation is current.

Do not implement Templates, AI, Search indexing, Analytics, Backup/Restore, platform Notifications, or Cloud functionality.
