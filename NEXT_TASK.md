# Next Task

## Task ID

`PHASE-2A-DRIFT-FOUNDATION`

## Goal

Add the first local persistence foundation for Momentum OS using Drift and SQLite without implementing productivity CRUD.

Create only the database opening path, schema version 1 foundation, UUID service, migration test harness, and repository boundary scaffolding needed for later vertical slices.

## Scope

Included:

- Add initial Drift and SQLite packages compatible with the current Flutter and Dart versions.
- Add code generation packages required by Drift.
- Create the application database class.
- Establish schema version 1.
- Add a safe database opening path for the local app.
- Add a UUID v4 service for future persistent entities.
- Add repository boundary scaffolding only where it has immediate foundation value.
- Add a migration test harness that can verify fresh database creation.
- Keep database details out of widgets and screens.
- Update documentation for persistence foundation contracts.

Excluded:

- Areas CRUD
- Goals CRUD
- Projects CRUD
- Tasks CRUD
- Events CRUD
- Notes CRUD
- Spaces CRUD
- Templates
- AI persistence
- Search indexing
- Notification scheduling
- Settings persistence beyond foundation contracts
- Backup/export implementation
- Cloud synchronization

## Architecture Requirements

- Read all repository documentation before editing.
- Use Drift with SQLite as documented in the approved architecture.
- Use UUID v4 identifiers for future persistent entities.
- Keep persistence behind repositories or explicit database boundaries.
- Do not let widgets or screens access Drift directly.
- Keep schema versioning explicit.
- Add generated files only through the required build command.
- Do not add unrelated packages or feature implementations.
- Document any genuine architecture change in `docs/DECISIONS.md` before implementation.

## Files likely affected

- `pubspec.yaml`
- `pubspec.lock`
- `lib/core/database/`
- `lib/core/services/`
- `lib/shared/repositories/`
- `test/`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA_MODEL.md`
- `docs/FEATURE_MATRIX.md`
- `docs/DECISIONS.md` only if a real new decision is made
- `CHANGELOG.md`

## Required validation

Run from the Flutter project root:

- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `dart format .`
- `flutter analyze`
- `flutter test`

## Acceptance criteria

- Drift and SQLite packages are installed.
- Database opens successfully in tests.
- Schema version 1 exists.
- Fresh database creation is tested.
- UUID v4 service exists and is tested.
- Repository boundaries prevent direct widget access to Drift.
- No productivity CRUD is implemented.
- Generated code is current.
- `flutter analyze` reports no issues.
- `flutter test` passes.
- Documentation is updated.
- `NEXT_TASK.md` is changed to the next bounded task.

## Stop condition

Stop after the Drift foundation, tests, generated files, and documentation pass validation.

Do not implement Areas, Goals, Projects, Tasks, Events, Notes, Spaces, Templates, real AI, Search indexing, Notifications, Settings persistence, analytics, backup/export, or cloud functionality.
