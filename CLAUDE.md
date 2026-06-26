# Momentum OS - Claude Code Instructions

## Project Identity

Momentum OS is a clean Flutter-based, local-first personal planner and operating-system application.

The application must remain:

* Generic and configurable
* Local-first
* Modular
* Testable
* Maintainable
* Compatible with future cloud synchronization
* Free from hard-coded personal activities or current life details

Do not redesign the product from scratch or replace its fundamental architecture unless the user explicitly approves the change and it is documented in the repository.

## Permanent Source of Truth

Repository documentation is the permanent source of truth, not chat history or model memory.

Before editing code, read:

1. `AGENTS.md`
2. `PROJECT_STATUS.md`
3. `NEXT_TASK.md`
4. `docs/PRODUCT_SPEC.md`
5. `docs/ARCHITECTURE.md`
6. `docs/DATA_MODEL.md`
7. `docs/DESIGN_SYSTEM.md`
8. `docs/NAVIGATION.md`
9. `docs/FEATURE_MATRIX.md`
10. `docs/DECISIONS.md`
11. `docs/TEST_PLAN.md`
12. `docs/IMPLEMENTATION_PLAN.md`
13. `CHANGELOG.md`

When repository files conflict with old chat messages, prefer the latest verified repository decision.

When documentation appears stale relative to verified code and commit history:

1. Inspect the implementation.
2. Inspect recent Git history.
3. Establish the actual project state.
4. Fix the implementation first when necessary.
5. Reconcile the documentation before declaring the task complete.

Never rely on chat memory alone for project state.

## Available Skills and Tools

This Claude Code environment may expose reusable skills, agents, MCP tools, or plugins.

Before implementing:

1. Inspect the available skills.
2. Read only the skills relevant to the current task.
3. Use a skill when it materially improves correctness, speed, debugging, testing, or validation.
4. Do not invoke broad or unrelated skills.
5. Do not allow a skill to override repository architecture, scope, or documentation.
6. Prefer repository-native scripts and commands over inventing new workflows.
7. Use Git or GitHub publication skills only after validation passes and only when the current task explicitly authorizes committing or pushing.

Relevant skill categories may include:

* Flutter and Dart
* Drift and SQLite
* Riverpod
* Testing
* Debugging
* Code review
* Git
* GitHub
* Documentation
* Security
* Accessibility

Do not install new tools or packages merely because a skill suggests them.

New core dependencies require:

* A concrete technical justification
* Confirmation that the approved stack is insufficient
* A documented architecture decision
* User approval when the change is substantial

## Terminal-First Workflow

Development is performed on Windows.

The normal project root is:

```text
C:\Mahmoud\Coding\My Planner
```

Prefer copy-paste-ready PowerShell commands whenever a terminal command can create, inspect, configure, move, edit, generate, test, build, install, or automate something faster than manual clicking.

Prefer scripts for repeated operations.

Before running commands, verify the project directory:

```powershell
Set-Location "C:\Mahmoud\Coding\My Planner"
```

Warn before destructive commands.

Never use destructive Git commands on existing work unless the user explicitly authorizes them.

Do not run:

```text
git reset --hard
git clean -fd
git checkout -- <file>
git restore <file>
git push --force
git push --force-with-lease
```

Do not:

* Rewrite Git history
* Discard uncommitted changes
* Stash changes without explicit approval
* Overwrite unrelated work
* Delete generated history or migration snapshots without justification

## Working Method

Work on one clearly defined task or subtask at a time.

Before implementing:

1. Identify the current phase from `PROJECT_STATUS.md`.
2. Read `NEXT_TASK.md`.
3. Run `git branch --show-current`.
4. Run `git status --short`.
5. Inspect the relevant diff.
6. Confirm the requested scope internally.
7. Avoid implementing later-phase work.
8. Avoid unrelated refactoring.
9. Preserve working behavior.

Every task should have:

```text
Goal:
Scope:
Files likely affected:
Commands to run:
Acceptance criteria:
Stop condition:
```

Do not treat the entire project as one large implementation task.

Break substantial work into bounded units with explicit completion criteria.

When the user says `continue`, continue from `NEXT_TASK.md`, not from assumptions.

## Approved Flutter Stack

Use the approved stack:

* Flutter
* Dart
* Riverpod
* GoRouter
* Drift with SQLite
* Freezed where useful
* `json_serializable`
* `flutter_secure_storage`
* `flutter_local_notifications`
* `workmanager`
* `fl_chart`
* `url_launcher`
* UUID v4
* `flutter_test`
* `mocktail`
* `integration_test`

Do not introduce alternative core packages without explaining the reason and documenting the decision.

Do not add Freezed merely to avoid writing a small immutable Dart model.

Use Freezed only when it provides clear value and remains consistent with the feature architecture.

## Architecture Rules

Maintain feature-first architecture.

Required boundaries:

* Widgets must not access Drift directly.
* Screens must not contain persistence logic.
* Business logic belongs in controllers, services, use cases, or domain layers.
* Repositories abstract data persistence.
* Domain models must not depend on presentation packages.
* Domain repository contracts must not expose Drift rows.
* Domain repository contracts must not expose Drift companions.
* Domain repository contracts must not expose Drift columns.
* Domain repository contracts must not expose Drift `Value` objects.
* Drift-specific mapping belongs in the data layer.
* Integrations must be replaceable.
* AI must not write directly to the database.
* No API secrets may be embedded in the Flutter application.
* Use `MockAiService` before integrating a real AI provider.
* Use the existing `IdService` for UUID v4 identifiers.
* Use the existing `UtcClock` for persisted timestamps.
* Use the existing `AppLogger` for structured logging.
* Use existing failure boundaries such as `PersistenceFailure`.

Widgets and presentation controllers may depend on repository contracts.

Repository implementations may depend on Drift.

Domain models must remain pure Dart unless a documented architectural decision states otherwise.

Avoid unnecessary architecture ceremony, but do not bypass core boundaries for speed.

## Local-First Rules

Momentum OS must remain local-first.

The local database is the authoritative source of application data until a later synchronization phase is explicitly approved.

Implement data structures so future synchronization remains possible:

* Use stable UUID v4 identifiers.
* Store timestamps consistently in UTC.
* Keep repository boundaries replaceable.
* Avoid database-generated integer identity keys for domain entities.
* Preserve created and updated timestamps.
* Consider archive, restore, and conflict-resolution needs.
* Do not tightly couple domain models to SQLite.

Cloud synchronization must not be introduced automatically.

## No Hard-Coded Personal Details

Do not permanently hard-code:

* AUC
* ECPC
* Competitive programming
* Machine learning
* FlyRanks
* Freelancing
* Particular clients
* Current internships
* Specific courses
* EGP
* Personal income targets
* Fixed CRM stages
* Personal reminder times
* Mahmoud's current schedule

These may exist only as:

* Editable templates
* Optional example data
* User-created Spaces
* Configurable fields
* Removable modules
* User-controlled settings

The application must continue working when every optional template is removed.

Do not make the application architecture depend on a specific person, activity, company, university, currency, schedule, or workflow.

## Code Quality

Write production-quality code rather than temporary demonstrations.

Include where relevant:

* Loading states
* Empty states
* Error states
* Input validation
* Structured logging
* Safe null handling
* Accessible labels
* Repository abstractions
* Tests
* Migration considerations
* Undo support for destructive actions
* Undo support for AI-assisted actions

Do not silently ignore analyzer warnings or informational findings.

Do not suppress lints to hide a real issue.

Do not add placeholder implementations without clearly documenting them.

Read the complete error output, not only the final line.

Fix root causes rather than hiding failures.

Preserve existing behavior unless the task explicitly changes it.

## Date and Time Rules

Use the existing `UtcClock` for application-generated timestamps.

Do not call `DateTime.now()` directly inside repositories or business logic when an injectable clock is available.

Persist timestamps in UTC.

Normalize user-supplied persisted timestamps to UTC when appropriate.

Convert to local time only for presentation.

Tests involving time should use a fixed or fake clock.

## Identifier Rules

Use the existing `IdService` for new domain identifiers.

Do not:

* Create a parallel `UuidService`
* Instantiate UUID generators throughout the codebase
* Generate identifiers inside widgets
* Use auto-incrementing integer IDs for domain entities
* Require callers to generate IDs when the repository owns creation

Identifiers should be stable UUID v4 strings unless a documented data-model decision says otherwise.

## Logging and Failure Rules

Use `AppLogger` for structured logging.

Log:

* Feature
* Operation
* Relevant non-sensitive metadata
* Original error
* Stack trace when available

Do not log:

* Secrets
* Tokens
* Passwords
* Private message bodies
* Sensitive financial details
* Full user-generated content unless required and safely redacted

Repositories should translate storage failures into project failure types such as `PersistenceFailure`.

Do not expose raw Drift or SQLite exceptions to presentation code.

## Drift and Generated Files

For schema or generated-model changes:

1. Edit source definitions only.
2. Never manually edit generated Drift files.
3. Regenerate using repository-supported commands.
4. Inspect generated names rather than guessing them.
5. Keep schema snapshots current.
6. Preserve every prior migration.
7. Add an explicit migration for the new schema version.
8. Add focused migration tests.
9. Verify representative previous-version data survives.
10. Verify foreign keys.
11. Verify indexes.
12. Do not delete old schema snapshots.

Generated files may include:

```text
lib/core/database/app_database.g.dart
lib/core/database/app_database.steps.dart
test/drift/app_database/generated/schema.dart
test/drift/app_database/generated/schema_v*.dart
drift_schemas/app_database/drift_schema_v*.json
```

Do not manually modify these files unless repository documentation explicitly identifies an exception.

Preferred generation commands:

```powershell
dart run build_runner build
dart run drift_dev make-migrations
```

The current `build_runner` version may ignore the removed `--delete-conflicting-outputs` option.

Do not use that option unless the installed version explicitly supports it.

## Migration Rules

When incrementing the schema version:

1. Update the central schema version constant.
2. Update `AppDatabase.latestSchemaVersion`.
3. Add source table or column definitions.
4. Regenerate Drift code.
5. Regenerate schema snapshots.
6. Preserve generated `stepByStep` migration handling.
7. Implement the exact migration step.
8. Add migration tests from the previous version.
9. Verify representative data preservation.
10. Verify fresh database creation.
11. Verify foreign keys remain enabled.
12. Verify indexes exist.
13. Update data-model documentation.
14. Update the changelog and phase documentation.

Never replace a generated migration strategy with an unrelated manual strategy unless a documented decision approves it.

## Required Validation

After normal code changes, run from the Flutter project root:

```powershell
dart format .
flutter analyze
flutter test
```

After generated-model or Drift changes:

```powershell
dart run build_runner build
dart run drift_dev make-migrations
dart format .
flutter analyze
flutter test
```

When Android verification is required:

```powershell
flutter build apk --debug
```

Do not claim completion while analysis or tests fail.

Report exact failures and distinguish new failures from existing failures.

When debugging:

1. Run the smallest relevant focused test.
2. Fix the root cause.
3. Rerun the focused test.
4. Run the complete required validation afterward.

## Testing Rules

Use:

* Unit tests for domain rules
* Repository tests for persistence behavior
* Provider tests for dependency replacement
* Widget tests for loading, empty, content, and error states
* Migration tests for every schema change
* Integration tests for critical multi-feature workflows

Tests should be:

* Deterministic
* Isolated
* Fast where possible
* Clear about expected behavior
* Independent of real network services
* Independent of current clock time
* Independent of personal data

Do not weaken or delete valid tests merely to make the test suite pass.

When a test fails, determine whether:

* The implementation is wrong
* The test is stale
* Generated artifacts are stale
* The documented behavior changed

Fix the correct layer.

## UI and Accessibility Rules

Use the approved Material 3 design system.

Every meaningful screen should account for:

* Loading
* Empty
* Content
* Error
* Disabled states where relevant

Use accessible labels for interactive controls.

Maintain adequate touch-target sizes.

Do not rely only on color to communicate state.

Preserve responsive behavior for compact and wider layouts.

Avoid fixed-height layouts that can overflow on compact screens unless the fixed size is proven safe.

## AI Rules

AI integration belongs in replaceable service boundaries.

AI must not:

* Write directly to Drift
* Bypass validation
* Execute destructive changes without approval
* Store API secrets in the Flutter application
* Silently modify user data

AI-assisted actions must use:

1. Structured proposals
2. Validation
3. Preview
4. User approval
5. Repository or controller execution
6. Action history
7. Undo where practical

Use `MockAiService` before adding a real provider.

## Documentation Updates

At the end of every meaningful task or phase, update as relevant:

* `PROJECT_STATUS.md`
* `NEXT_TASK.md`
* `docs/FEATURE_MATRIX.md`
* `docs/DECISIONS.md`
* `CHANGELOG.md`

Also update:

* `docs/ARCHITECTURE.md` when architecture changes
* `docs/DATA_MODEL.md` when schema or persistence changes
* `docs/TEST_PLAN.md` when test coverage expectations change
* `docs/IMPLEMENTATION_PLAN.md` when phase boundaries or sequencing change
* `docs/NAVIGATION.md` when routing changes
* `docs/DESIGN_SYSTEM.md` when shared design behavior changes
* `docs/PRODUCT_SPEC.md` when product requirements change

Documentation must describe verified implementation state, not intended future work.

Do not claim a phase is complete merely because contracts or placeholders exist.

## Git Rules

Use focused commits.

Before committing:

```powershell
git status --short
git diff
dart format .
flutter analyze
flutter test
git diff --check
```

Stage only intended files.

Do not use `git add -A` when the working tree contains unrelated changes.

Prefer explicit paths:

```powershell
git add path\to\file1 path\to\file2
```

Before committing, inspect:

```powershell
git diff --cached --check
git diff --cached --stat
git status --short
```

Commit messages should describe the completed unit of work.

Do not combine unrelated phases in one commit.

Do not place untested work on `main`.

Do not commit or push unless the current task explicitly permits it.

Never force-push unless the user explicitly authorizes it and understands the risk.

## Debugging Workflow

When an error occurs:

1. Read the complete error.
2. Inspect the affected files.
3. Inspect the relevant recent diff.
4. Reproduce using the smallest appropriate command.
5. Fix the root cause.
6. Run focused tests.
7. Run full required validation.
8. Record important fixes or decisions in project documentation.

Prefer commands that collect useful diagnostics automatically.

Do not stop after producing an inspection report when the task requires implementation.

Do not ask the user to perform an edit that Claude Code can safely perform itself.

Do not repeatedly apply speculative fixes without rerunning the failing command.

## Scope Control

Do not perform unrelated refactoring.

Do not upgrade dependencies during a feature task unless required by the task.

Do not alter architecture because a different design appears preferable.

Do not start later phases before the current bounded task is validated and documented.

When additional problems are discovered:

* Fix them only when they block the current task and the correction remains within scope.
* Otherwise document them as known issues or future tasks.
* Do not silently expand scope.

## Unattended Execution Rules

When explicitly told to operate unattended:

* Execute the requested work yourself.
* Do not ask unnecessary questions.
* Do not stop after inspection.
* Continue through implementation, focused testing, full validation, documentation, and authorized Git actions.
* Read complete command output.
* Fix failures within scope.
* Stop only when acceptance criteria pass or a genuine blocker requires user intervention.

Do not claim a command ran unless it actually ran.

Do not claim tests passed without the command output.

Do not claim a push succeeded without verifying it.

## Completion Standard

A task is complete only when:

* The requested scope is satisfied.
* Architecture boundaries are preserved.
* Formatting passes.
* Analyzer reports no issues.
* Relevant focused tests pass.
* The full test suite passes.
* Generated artifacts are current when applicable.
* Documentation is reconciled.
* Git status is understood.
* Known issues are reported honestly.
* Commit and push are completed only when explicitly authorized.

Do not claim completion when analyzer warnings or tests remain unresolved.

## Required Final Handoff

Every meaningful implementation handoff must include:

```text
Completed:
Files changed:
Commands run:
Tests passed:
Known issues:
Decisions made:
Next task:
Files required in the next chat:
Exact git status --short:
```

When commit or push was authorized, also include:

```text
Commit:
Push:
Branch:
```