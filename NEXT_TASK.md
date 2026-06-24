# Next Task

## Task ID

`PHASE-6B-TEMPLATE-PACK-DEFINITIONS`

## Goal

Add bundled template definition descriptors for the planned template categories without creating example records or installing real user data.

Focus on safe, generic, removable descriptors that can be installed through the Phase 6A metadata infrastructure.

## Scope

Included:

- Bundled template definition descriptors for the planned Phase 6 categories
- Generic configuration payloads only; no records, activities, people, employers, courses, currencies, schedules, or personal targets
- Validation that descriptor keys, versions, and configuration payloads remain safe and removable
- Template foundation panel rendering of available definitions
- Tests proving install still records metadata only
- Tests proving zero installed templates remains supported
- Documentation updates

Excluded:

- Example records or demo data
- Template-created Areas, Goals, Projects, Tasks, Notes, Events, Spaces, or Space records
- Template editing UI beyond descriptor visibility
- Export files or backup/restore flows
- AI persistence or real AI provider
- Search indexing
- Analytics dashboards or charts
- Cloud synchronization
- Platform notification scheduling

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, Phase 3 productivity-core behavior, Phase 4 Planner behavior, Phase 5 Spaces behavior, and Phase 6A template infrastructure behavior.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Use the Phase 6A template registry and repository boundaries.
- Do not create hard-coded personal workflows or data.
- Do not create productivity or Space records from templates in this phase.

## Files likely affected

- `lib/features/templates/`
- `test/features/templates/`
- `test/repositories/template_repository_test.dart`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
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

- Planned template categories are represented as safe descriptors only.
- Installing a template still records metadata only and does not create records.
- Descriptor validation rejects example records or demo data.
- Zero installed templates remains a supported state.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 6B template descriptor definitions pass validation and documentation is current.

Do not implement example records, template-created records, AI, Search indexing, Analytics, Backup/Restore, platform Notifications, or Cloud functionality.
