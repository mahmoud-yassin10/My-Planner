# Momentum OS

Momentum OS is a configurable, local-first personal planner and operating-system application built with Flutter.

It is designed to coordinate goals, projects, tasks, events, focus sessions, notes, finances, opportunities, clients, learning, reminders, analytics, and AI-assisted planning without hard-coding one person's current activities.

## Current state

The repository is in **Phase 0 — Documentation and clean project creation**.

The Flutter Android starter project exists and passes its initial analysis and test suite. Product, architecture, data, navigation, design, testing, implementation, and agent-governance documents are maintained in this repository.

See:

- [`PROJECT_STATUS.md`](PROJECT_STATUS.md)
- [`NEXT_TASK.md`](NEXT_TASK.md)
- [`docs/PRODUCT_SPEC.md`](docs/PRODUCT_SPEC.md)
- [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md)
- [`AGENTS.md`](AGENTS.md)

## Product principles

- Local-first
- Generic and configurable
- Feature-first architecture
- Replaceable integrations
- No embedded secrets
- Preview and approval before AI writes
- Future cloud synchronization compatibility
- Optional, editable, removable templates

## Initial platform

- Flutter
- Android
- Riverpod
- GoRouter
- Drift with SQLite
- Material 3

iOS, web, desktop, cloud synchronization, multiple users, and real AI providers are future-compatible concerns, not initial delivery targets.

## Local validation

From the project root:

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
```

Android debug build:

```powershell
flutter build apk --debug
```

## Repository

Remote repository:

```text
https://github.com/mahmoud-yassin10/My-Planner.git
```
