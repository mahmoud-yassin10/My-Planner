# Next Task

## Task ID

`PHASE-5A-SPACES-FOUNDATION`

## Goal

Add the initial configurable Spaces foundation without implementing templates, AI, analytics dashboards, backup/restore, or cloud synchronization.

Focus on Space definitions, record types, custom fields, statuses, records, relationships, and saved filters/views behind repository boundaries.

## Scope

Included:

- Space definition domain model, repository contract, Drift table, and migration
- Record type domain model, repository contract, Drift table, and migration
- Custom field definitions with type-safe validation for initial field types
- Editable status definitions for records
- Space records with generic field-value storage appropriate for Phase 5A only
- Relationships between Space records and supported core entities through repository boundaries
- Saved filters and basic saved views contracts
- Spaces screen loading, empty, content, and error states
- Focused database, repository, migration, controller, domain, and widget tests
- Documentation updates

Excluded:

- Templates
- AI persistence or real AI provider
- Search indexing
- Analytics dashboards or charts
- Backup files or restore flows
- Cloud synchronization

## Architecture Requirements

- Read all required repository documentation before editing.
- Preserve Phase 1 navigation, Phase 2 persistence behavior, Phase 3 productivity-core behavior, and Phase 4 Planner behavior.
- Keep widgets and screens away from Drift.
- Keep domain contracts free of Drift and presentation packages.
- Use repository/controller boundaries for Spaces persistence and validation behavior.
- Do not add templates, AI, search indexing, analytics, backup/restore, platform notifications, or cloud features.

## Files likely affected

- `lib/features/spaces/`
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

- Space definitions, record types, fields, statuses, records, relationships, filters, and views remain behind repository/controller boundaries.
- The Spaces destination renders implemented records with accessible empty/error/loading states.
- Initial custom field validation is deterministic and type-safe.
- No template installer/uninstaller behavior is implemented yet.
- Generated code and schema snapshots are current.
- `flutter analyze` reports no issues.
- All tests pass.
- Debug APK builds.
- Documentation is updated.

## Stop condition

Stop after Phase 5A Spaces foundation passes validation and documentation is current.

Do not implement Templates, AI, Search indexing, Analytics, Backup/Restore, platform Notifications, or Cloud functionality.
