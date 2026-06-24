# Momentum OS Architecture

## 1. Architectural goals

The architecture must support:

- Local-first operation
- Feature isolation
- Testability
- Replaceable integrations
- Safe schema evolution
- Future synchronization
- Provider-independent AI
- Configurable rather than hard-coded domain extensions

## 2. Approved technology stack

| Concern | Technology |
|---|---|
| UI | Flutter |
| State management | Riverpod |
| Routing | GoRouter |
| Local persistence | Drift with SQLite |
| Immutable models | Freezed where useful |
| Serialization | `json_serializable` |
| Preferences | Typed preferences repository |
| Secure values | `flutter_secure_storage` |
| Notifications | `flutter_local_notifications` |
| Background work | `workmanager` |
| Deep links | `app_links` with GoRouter |
| Charts | `fl_chart` |
| External URLs | `url_launcher` |
| Files | `file_picker`, `path_provider` |
| Sharing | `share_plus` |
| IDs | UUID v4 |
| Logging | Structured application logger |
| Unit/widget tests | `flutter_test` |
| Mocking | `mocktail` |
| Integration tests | `integration_test` |
| Cloud later | Supabase PostgreSQL |
| Sync later | PowerSync |
| AI later | Secure server-side function |

Supabase and PowerSync are explicitly excluded from the initial local-only phases.

## 3. Architectural style

Use feature-first organization with clear domain, data, and presentation boundaries.

Target structure:

```text
lib/
  app/
    app.dart
    bootstrap.dart
    routing/
    theme/
    shell/

  core/
    database/
    errors/
    logging/
    notifications/
    preferences/
    search/
    security/
    services/
    utils/
    widgets/

  features/
    home/
    planner/
    areas/
    goals/
    projects/
    tasks/
    events/
    focus/
    spaces/
    templates/
    notes/
    insights/
    ai/
    notifications/
    settings/
    backup/

  shared/
    models/
    repositories/
    widgets/
```

A typical feature:

```text
feature/
  data/
    data_sources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    services/
  presentation/
    controllers/
    screens/
    widgets/
```

Use only the layers that provide real value for a feature. Do not add empty abstractions merely to satisfy a diagram.

## 4. Dependency direction

Allowed direction:

```text
presentation → domain ← data
                    ↑
                  core
```

Rules:

- Presentation depends on domain contracts and providers.
- Data implements domain repository contracts.
- Domain must not import Flutter presentation packages.
- Database details remain inside data/core database layers.
- Widgets never execute Drift queries directly.
- Services that touch platform APIs sit behind interfaces.
- Cross-feature coordination occurs through explicit use cases, services, repositories, or shared contracts.

## 5. Application bootstrap

`bootstrap.dart` will eventually:

1. Initialize Flutter bindings.
2. Configure structured logging.
3. Initialize the database.
4. Initialize typed preferences and secure storage.
5. Configure notification services.
6. Construct the root Riverpod scope.
7. Capture uncaught Flutter and platform errors.
8. Start the application.

Initialization failure must produce a recoverable error screen rather than an unexplained startup crash.

## 6. State management

Riverpod is the approved state-management and dependency-injection mechanism.

Guidelines:

- Repository and service implementations are exposed through providers.
- Async state uses explicit loading, data, and error handling.
- Feature controllers coordinate user actions.
- UI widgets render state and forward intents.
- Avoid global mutable singletons.
- Keep provider lifetimes deliberate.
- Persisted state belongs in repositories, not providers alone.

## 7. Routing

GoRouter is the approved router.

Requirements:

- Centralized route names and path definitions
- Shell route for primary navigation
- Typed parameters where practical
- Deep-link-compatible detail routes
- Redirects based on app readiness, not hidden side effects
- Route-level error handling
- Navigation tests for important flows

## 8. Persistence

Drift with SQLite is the local source of truth.

Persistence rules:

- Repository methods expose domain-oriented operations.
- Multi-table changes use transactions.
- Database schema versions are explicit.
- Migrations are tested.
- UUID v4 is generated before inserts.
- Timestamps are stored consistently in UTC and converted for display.
- Archive and soft-delete semantics are explicit per entity.
- Raw JSON is reserved for truly dynamic values, not stable relational concepts.
- Query performance is reviewed before adding denormalized caches.

## 9. Preferences and secure data

Use a typed preferences repository for non-sensitive configuration.

Use `flutter_secure_storage` only for secrets or security-sensitive values. A future remote AI token should not be stored as an embedded application secret; provider calls must pass through a secure backend.

## 10. Error handling

Use explicit failure types at integration boundaries.

Expected categories:

- Validation failure
- Persistence failure
- Migration failure
- Platform-service failure
- Permission failure
- File/import failure
- Notification scheduling failure
- AI proposal/validation failure
- Unexpected application failure

Errors should be logged with context and translated into user-actionable messages in presentation code.

## 11. Logging

Use structured logging with:

- Severity
- Feature or component
- Operation
- Correlation identifier where useful
- Error and stack trace
- Safe metadata

Never log secrets, full private note contents, or sensitive financial data by default.

## 12. AI architecture

AI is an integration, not the database owner.

```text
User request
  → AiService
  → structured proposal
  → AiActionValidator
  → preview/edit/approval
  → domain use case
  → repository transaction
  → action log
  → optional undo
```

Initial implementation uses `MockAiService`. A later `RemoteAiService` calls a secure backend.

## 13. Notifications and background work

Notification scheduling and background work must remain behind replaceable services.

- Domain rules produce reminder intent.
- Platform adapters schedule or cancel operating-system jobs.
- Persistent reminder records permit rescheduling after restart or timezone changes.
- Background jobs must be idempotent.

## 14. Future synchronization boundary

Future cloud synchronization should be introduced beneath repository boundaries.

Preparation from day one:

- UUID identifiers
- UTC timestamps
- `updatedAt`
- optional `deletedAt`
- reserved sync status/version metadata
- deterministic serialization
- migration discipline

Do not add PowerSync or remote repositories before the local product is stable.

## 15. Performance principles

- Avoid loading entire tables for list screens.
- Use indexed filters for common queries.
- Paginate or window large record collections.
- Debounce search.
- Keep heavy computation outside build methods.
- Profile before adding caching complexity.
- Use immutable state updates where practical.

## 16. Security principles

- No secrets in source control.
- No embedded AI provider keys.
- Validate imported data.
- Restrict file access to selected application paths.
- Protect backup/restore flows from accidental overwrite.
- Add biometric lock in the security phase.
- Treat logs and exported files as potentially sensitive.

## 17. Architecture change process

A change to the approved stack or major boundary requires:

1. Problem statement
2. Considered alternatives
3. Decision and rationale
4. Consequences
5. Migration impact
6. Entry in `docs/DECISIONS.md`
7. Relevant architecture/data/test document updates
