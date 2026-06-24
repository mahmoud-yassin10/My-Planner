# Next Task

## Task ID

`PHASE-6A-TEMPLATE-INFRASTRUCTURE`

## Goal

Add removable template infrastructure without installing real template packs, creating example records, or hard-coding personal workflows.

Focus on a generic template registry contract, installation metadata, uninstall choices, repository boundaries, and tests.

## Scope

Included:

- Template definition domain model for bundled configuration descriptors
- Template installation metadata model
- Drift table and migration only if required for installation tracking
- Repository/controller boundary for listing template definitions and installation state
- Install/uninstall foundation that records metadata but does not create productivity or Space records
- Uninstall-choice contract for preserve, archive, export, and delete outcomes without implementing export files
- Safe validation that templates remain generic and removable
- Settings or Spaces screen entry point only if needed to reach the foundation state
- Loading, empty, content, and error states for any new template UI
- Focused repository, database, migration, provider, domain, and widget tests
- Documentation updates

Excluded:

- Real template packs for freelancing, finance, opportunities, learning, competitive programming, machine learning, university, fitness, reading, or content creation
- Example records or demo data
- Template-created Areas, Goals, Projects, Tasks, Notes, Events, or Space records
- AI persistence or real AI provider
- Search indexing
- Analytics dashboards or charts
- Backup files or restore flows
- Cloud synchronization
- Platform notification scheduling

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, Phase 3 productivity-core behavior, Phase 4 Planner behavior, and Phase 5 Spaces behavior.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Use repository/controller boundaries for template installation metadata.
- Templates must be optional, editable later, removable, and safe when zero templates are installed.
- Do not add AI, search indexing, analytics, backup/restore, platform notifications, or cloud features.

## Files likely affected

- `lib/features/templates/`
- `lib/core/database/`
- `test/features/templates/`
- `test/repositories/`
- `test/database/`
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

- Template definitions and installation metadata remain behind repository/controller boundaries.
- Installing a template records metadata only and does not create fake records.
- Uninstall choices are modeled and validated without implementing export files.
- Zero installed templates remains a supported state.
- Generated code and schema snapshots are current if schema generation is touched.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 6A template infrastructure passes validation and documentation is current.

Do not implement real template packs, example records, AI, Search indexing, Analytics, Backup/Restore, platform Notifications, or Cloud functionality.
