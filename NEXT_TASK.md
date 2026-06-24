# Next Task

## Task ID

`PHASE-1B-GLOBAL-FOUNDATION`

## Goal

Extend the Momentum OS foundation with safe global entry points, reusable UI state components, structured logging basics, and recoverable startup error handling.

Keep this as a foundation task only. Do not implement real productivity data, persistence, AI behavior, search indexing, notifications scheduling, or settings storage.

## Scope

Included:

- Add a global Quick Add entry point in the application shell.
- Add placeholder routes and screens for:
  - AI
  - Search
  - Notifications
  - Settings
- Keep all placeholder screens generic and free of personal examples.
- Keep route names and paths centralized.
- Add reusable UI components for:
  - Loading state
  - Empty state
  - Error state
- Add a structured logging foundation suitable for later feature use.
- Add recoverable startup error handling in the bootstrap flow.
- Add focused widget and unit tests for the new routes, global entry points, reusable states, logging basics, and startup error screen.
- Update project documentation.

Excluded:

- Drift or SQLite
- Persistence repositories
- Areas, goals, projects, tasks, events, or notes CRUD
- Real Quick Add creation flows
- Real AI providers or AI action proposals
- Search indexing or search results
- Notification scheduling or permissions
- Settings persistence
- Analytics computation
- Templates
- Cloud synchronization
- Embedded API keys or secrets

## Architecture requirements

- Read all repository documentation before editing.
- Keep using Riverpod for dependency injection.
- Keep using GoRouter for all routes.
- Keep route definitions centralized.
- Keep theme tokens centralized.
- Use feature-first organization where a feature has meaningful code.
- Do not create unused domain or data layers.
- Screens must not contain persistence or future business logic.
- Logging must avoid secrets and private content by default.
- Startup failures must show a recoverable user-facing error screen.
- Do not introduce packages outside the approved architecture without documenting a decision first.

## Files likely affected

- `lib/app/bootstrap.dart`
- `lib/app/app.dart`
- `lib/app/routing/`
- `lib/app/shell/`
- `lib/core/logging/`
- `lib/core/widgets/`
- `lib/features/ai/presentation/`
- `lib/features/search/presentation/`
- `lib/features/notifications/presentation/`
- `lib/features/settings/presentation/`
- `test/`
- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/FEATURE_MATRIX.md`
- `docs/DECISIONS.md` only if a real new decision is made
- `CHANGELOG.md`

## Required validation

Run from the Flutter project root:

- `flutter pub get`
- `dart format .`
- `flutter analyze`
- `flutter test`

## Acceptance criteria

- Quick Add is reachable from the app shell as a placeholder entry point.
- AI, Search, Notifications, and Settings placeholder routes are reachable.
- Placeholder routes do not implement real feature behavior.
- Reusable loading, empty, and error state widgets exist and are tested.
- Structured logging foundation exists and is tested without logging secrets.
- Bootstrap can surface a recoverable startup error screen.
- `flutter analyze` reports no issues.
- `flutter test` passes.
- Documentation is updated.
- `NEXT_TASK.md` is changed to the next bounded task.

## Stop condition

Stop after global placeholder entry points, reusable states, logging foundation, startup error recovery, tests, and documentation pass validation.

Do not implement Drift, persistence, productivity CRUD, real AI, real Search, notification scheduling, settings persistence, analytics, templates, or cloud functionality.
