# Momentum OS Agent Rules

## Required reading

Before changing code, read these files in order:

1. `PROJECT_STATUS.md`
2. `NEXT_TASK.md`
3. `docs/PRODUCT_SPEC.md`
4. `docs/ARCHITECTURE.md`
5. `docs/DATA_MODEL.md`
6. `docs/DESIGN_SYSTEM.md`
7. `docs/NAVIGATION.md`
8. `docs/FEATURE_MATRIX.md`
9. `docs/DECISIONS.md`
10. `docs/TEST_PLAN.md`
11. `docs/IMPLEMENTATION_PLAN.md`
12. `CHANGELOG.md`

Repository documentation is the source of truth. When a chat message conflicts with a newer documented decision, follow the repository documentation.

## Scope control

- Work only on the phase and task described in `NEXT_TASK.md`.
- Do not implement features from later phases.
- Do not perform unrelated refactors.
- Preserve existing working behavior.
- Stop when the requested acceptance criteria are met.
- Record any scope change in `docs/DECISIONS.md` before implementation.

## Product rules

Momentum OS must remain generic, configurable, local-first, modular, testable, and ready for future synchronization.

Do not hard-code personal activities, organizations, currencies, schedules, CRM stages, courses, internships, or income targets. These may exist only as editable templates, example data, user-created Spaces, or user-controlled settings.

The app must remain functional when all optional templates are removed.

## Architecture boundaries

- Use Flutter, Riverpod, GoRouter, Drift with SQLite, Freezed where useful, and `json_serializable`.
- Widgets and screens must not access Drift directly.
- Screens must not contain persistence or business logic.
- Repositories abstract persistence.
- Controllers and domain services coordinate use cases.
- Domain models must not depend on presentation packages.
- Integrations must be replaceable behind interfaces.
- AI must propose structured actions and must not write directly to the database.
- No API key or secret may be embedded in the Flutter application.
- Use `MockAiService` before any real AI provider.
- Use UUID v4 identifiers for persistent entities.
- Do not add a core package without documenting the reason in `docs/DECISIONS.md`.

## Implementation quality

Include relevant:

- Loading, empty, success, and error states
- Input validation
- Safe null handling
- Structured logging
- Accessible labels and touch targets
- Repository abstractions
- Unit, widget, database, and integration tests
- Migration considerations
- Undo for destructive and AI-assisted actions

Do not hide analyzer warnings, swallow exceptions silently, or leave undocumented placeholder implementations.

## Required validation

After normal code changes, run:

```powershell
dart format .
flutter analyze
flutter test
```

After Drift, Freezed, or generated-model changes, run:

```powershell
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
```

When Android verification is required, run:

```powershell
flutter build apk --debug
```

Do not report a task as complete while required checks fail. Distinguish new failures from pre-existing failures.

## Documentation requirements

After every meaningful task, update as applicable:

- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/FEATURE_MATRIX.md`
- `docs/DECISIONS.md`
- `CHANGELOG.md`
- Architecture and data-model documents when their contracts change

Every handoff must include:

```text
Completed:
Files changed:
Commands run:
Tests passed:
Known issues:
Decisions made:
Next task:
Files required in the next chat:
```

## Git rules

Before committing:

```powershell
git status
git diff
dart format .
flutter analyze
flutter test
```

Use focused commits. Do not combine unrelated phases. Do not place untested work on `main`. Real-device verification is required before declaring a release-ready version on `main`.

## Codex task rules

Every Codex prompt must:

- Tell Codex to read the repository documents first.
- Limit work to one bounded task.
- List files and features in scope.
- Prohibit unrelated changes.
- Require formatting, analysis, and tests.
- Require documentation updates.
- Define acceptance criteria and a stop condition.
- Require a report of changed files and commands executed.

Audit Codex output and diffs before accepting it.
