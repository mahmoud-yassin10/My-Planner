# Momentum OS — Master Implementation Specification

## Document purpose

This document is the consolidated execution map for completing Momentum OS.

It does not replace the detailed repository documents. It connects them, records the current verified implementation boundary, identifies missing product work, defines the remaining numbered stages, and establishes the approval gate between stages.

The permanent source of truth remains the repository. Every agent must read the detailed documents and verify the local checkout before relying on this summary.

## Repository

- Repository: `mahmoud-yassin10/My-Planner`
- Normal local path: `C:\Mahmoud\Coding\My Planner`
- Active development branch: `feature/drift-foundation`
- Initial target: Android
- Framework: Flutter
- Operating model: local-first

## Required companion documents

Before changing code, read:

1. `CLAUDE.md`
2. `AGENTS.md`
3. `PROJECT_STATUS.md`
4. `NEXT_TASK.md`
5. `docs/PRODUCT_SPEC.md`
6. `docs/ARCHITECTURE.md`
7. `docs/DATA_MODEL.md`
8. `docs/DESIGN_SYSTEM.md`
9. `docs/NAVIGATION.md`
10. `docs/FEATURE_MATRIX.md`
11. `docs/DECISIONS.md`
12. `docs/TEST_PLAN.md`
13. `docs/IMPLEMENTATION_PLAN.md`
14. `CHANGELOG.md`
15. This file

## Authority and conflict resolution

This document consolidates the plan but does not silently override approved decisions.

When documents conflict:

1. Inspect the latest verified implementation and tests.
2. Inspect recent Git history.
3. Prefer the latest dated entry in `docs/DECISIONS.md` for an approved architectural change.
4. Preserve the product intent in `docs/PRODUCT_SPEC.md`.
5. Preserve architecture and data boundaries in `docs/ARCHITECTURE.md` and `docs/DATA_MODEL.md`.
6. Treat `PROJECT_STATUS.md` and `NEXT_TASK.md` as the current execution state only after they are reconciled with code.
7. Update stale documentation during the current bounded task.
8. Never rely on chat memory or a model-generated summary alone.

Do not change architecture merely to resolve a documentation inconsistency. Establish the intended behavior first.

---

# 1. Product definition

Momentum OS is a generic, configurable, local-first personal planner and operating-system application.

It connects long-term direction to daily execution through:

```text
Area → Goal → Project → Milestone → Task → Focus Session → Result
```

It also supports:

- Calendar events and meetings
- Time blocks
- Notes and linked knowledge
- Configurable Spaces
- Optional templates
- Reminders and local notifications
- Controlled automations
- Analytics and configurable dashboards
- AI-assisted planning through safe proposals
- Backup, restore, export, security, and diagnostics
- Future cloud synchronization beneath repository boundaries

Momentum OS is not a hard-coded personal dashboard and not a collection of fixed modules tied to one person's current schedule.

## 1.1 Product principles

The application must remain:

- Generic and configurable
- Local-first
- Modular
- Testable
- Maintainable
- Accessible
- Safe under destructive actions
- Compatible with future synchronization
- Independent of embedded API secrets
- Functional when every optional template is removed

## 1.2 Prohibited hard-coding

Do not permanently hard-code:

- AUC
- ECPC
- Competitive programming
- Machine learning
- FlyRanks
- Freelancing
- Specific clients
- Current internships
- Specific courses
- EGP
- Personal income targets
- Fixed CRM stages
- Personal reminder times
- Mahmoud's current schedule
- Any current employer, university, routine, or target

These may appear only as editable templates, optional example data, user-created Spaces, configurable fields, removable modules, or user-controlled settings.

---

# 2. Approved technical architecture

## 2.1 Approved stack

Use:

- Flutter
- Dart
- Riverpod
- GoRouter
- Drift with SQLite
- Freezed where it provides real value
- `json_serializable`
- `flutter_secure_storage`
- `flutter_local_notifications`
- `workmanager`
- `fl_chart`
- `url_launcher`
- UUID v4
- `flutter_test`
- `mocktail`
- `integration_test`

Use existing approved supporting packages already present in the repository.

Do not introduce an alternative core package without:

1. Demonstrating that the approved stack is insufficient.
2. Documenting alternatives.
3. Recording a decision in `docs/DECISIONS.md`.
4. Updating affected architecture and test documents.
5. Receiving user approval when the change is substantial.

## 2.2 Feature-first boundaries

Maintain:

```text
presentation → domain ← data
                    ↑
                  core
```

Rules:

- Widgets never access Drift directly.
- Screens never contain persistence logic.
- Presentation renders state and forwards user intent.
- Controllers, services, and use cases coordinate behavior.
- Repositories abstract persistence.
- Data implementations map between Drift and pure domain models.
- Domain contracts never expose Drift rows, companions, columns, or `Value`.
- Platform integrations remain behind replaceable interfaces.
- AI never writes directly to the database.
- Cross-feature coordination uses explicit services, use cases, repositories, or shared contracts.
- Avoid empty architecture ceremony, but never bypass the core boundaries for speed.

## 2.3 Local-first and synchronization readiness

The local Drift database is authoritative in the local phases.

Use:

- UUID v4 identifiers
- UTC persisted timestamps
- Immutable `createdAt`
- Meaningful `updatedAt`
- Explicit archive and delete behavior
- Tested migrations
- Deterministic serialization
- Repository boundaries that can later support remote implementations

Do not add authentication, Supabase, PowerSync, or cross-device synchronization before the local product is stable and Stage 11 is explicitly approved.

## 2.4 Shared infrastructure

Use the existing:

- `IdService` for UUID v4
- `UtcClock` for persisted timestamps
- `AppLogger` for structured logging
- Persistence and platform failure boundaries
- Riverpod providers for replaceable dependencies
- Recoverable startup architecture

Do not create parallel services such as `UuidService`, `ClockService`, or a second application database.

## 2.5 AI safety boundary

The AI flow must remain:

```text
User request
→ AiService
→ structured proposal
→ validation
→ preview and optional edit
→ explicit approval
→ domain use case or controller
→ repository transaction
→ action history
→ optional undo
```

No provider secret may be embedded in the client.

---

# 3. Navigation and product surfaces

The five persistent destinations are:

1. Home
2. Planner
3. Spaces
4. Goals
5. Insights

Global actions are:

- Quick Add
- AI Copilot
- Global Search
- Notification Inbox
- Settings/Profile

Every meaningful surface must support appropriate:

- Loading state
- Empty state
- Content state
- Error state
- Disabled state
- Accessible labels
- Compact and wider layouts

Avoid fixed-height layouts that overflow on compact screens.

---

# 4. Status terminology

The repository must distinguish the following statuses.

## 4.1 `Foundation complete`

Contracts, boundaries, placeholders, or a narrow infrastructure slice exist and are tested.

This does not mean the full user-facing feature is finished.

Examples:

- Notification service contract without a production platform adapter
- Template descriptors without materialized editable configurations
- Reminder policy fields without operating-system scheduling
- Placeholder route without functional CRUD

## 4.2 `Phase-scoped complete`

Everything explicitly included in that historical bounded phase is implemented, validated, documented, and committed.

This does not automatically mean every item in the full product specification is complete.

## 4.3 `Product complete`

The full documented user-facing behavior exists, including:

- Persistence
- Domain rules
- UI states
- Platform configuration
- Migrations
- Focused tests
- Full tests
- Documentation
- Required build verification
- Manual verification where required

Do not label a numbered stage complete merely because tables, interfaces, or placeholder screens exist.

---

# 5. Current implementation baseline

This section records the last known project boundary. The executing agent must verify it against the local checkout before editing.

## 5.1 Completed historical phases

The following phase-scoped work is considered complete unless the local audit proves otherwise.

### Phase 0 — Project and documentation foundation

Completed:

- Clean Flutter Android project
- Git and GitHub setup
- Repository documentation structure
- Product specification
- Architecture specification
- Data-model plan
- Design system
- Navigation plan
- Feature matrix
- Decision log
- Test plan
- Implementation plan
- Agent rules
- Initial validation and publication

### Phase 1 — Application foundation

Completed:

- Riverpod root scope
- GoRouter shell
- `/` redirect to `/home`
- Five-destination adaptive navigation
- Material 3 light and dark themes
- Placeholder destination screens
- Global action entry points
- Reusable loading, empty, and error states
- Structured logging foundation
- Recoverable startup errors
- Route-level error handling
- Foundation tests

### Phase 2 — Persistence foundation

Completed:

- Drift and SQLite setup
- Explicit schema versioning
- Production and in-memory database opening
- Foreign-key enablement
- Generated migration snapshots and harness
- UUID v4 service
- UTC clock
- Typed settings repository
- Repository boundaries
- Persistence failure translation
- Seed/template contract
- Backup serialization contract
- Database, provider, startup, and repository tests

### Phase 3 — Productivity core

Completed phase-scoped slices:

- Areas
- Goal hierarchy and cycle validation
- Projects
- Milestones
- Tasks and subtasks
- Tags and entity tags
- Notes and note links
- Create, edit, archive, restore, and supported delete flows
- Repository and controller boundaries
- Goals and Planner rendering
- Schema migrations through version 3
- Focused repository, provider, migration, and widget tests

### Phase 4 — Planner

Completed phase-scoped slices:

- Day, week, month, and agenda views
- Planner events
- Time blocks
- Existing scheduled tasks in planner context
- Local recurrence expansion for supported rules
- Reminder policy contract validation
- Conflict detection
- Free-window helpers
- Task scheduling actions
- Actual-duration actions
- Focus sessions
- Schema migrations through version 5
- Planner repository, provider, migration, domain, and widget tests

### Phase 5 — Spaces engine

Completed phase-scoped slices:

- Space definitions
- Record types
- Custom field definitions
- Editable statuses
- Generic records
- Generic record links
- Saved filters
- Saved view contracts
- List, table, board, and card rendering
- Archive, restore, and supported permanent deletion
- Foreign-key failure translation
- Schema version 6
- Repository, provider, migration, and widget tests

### Phase 6 — Template infrastructure

Completed phase-scoped slices:

- Template descriptor model
- Injectable registry
- Installation metadata
- Uninstall-choice contract
- Bundled descriptors for planned categories
- Metadata-only installation foundation
- Schema version 7
- Repository, provider, migration, and widget tests

Important limitation:

Template installation is known to be metadata-oriented. Full product completion still requires actual editable configuration materialization and robust uninstall outcomes unless a later decision explicitly keeps templates metadata-only.

## 5.2 Stage 7 work already completed or substantially implemented

The local checkout must verify the exact state, but the last known boundary includes:

- Generic notification intent model
- Permission-state model
- Replaceable notification service interface
- Riverpod notification service provider
- Safe validation and structured logging
- Schedule, cancel, and reschedule contracts behind an adapter boundary
- Focused notification service tests
- Notifications foundation screen
- Database schema version 8 work
- `reminder_rules` persistence table
- `notification_inbox` persistence table
- v7 → v8 migration artifacts
- Foreign-key and notification-query index work
- Focused database and migration-test work

## 5.3 Current immediate task

The last known current bounded task is:

```text
Complete Drift-backed notification persistence repository CRUD,
watch streams, validation, failure translation, Riverpod providers,
and focused repository/provider tests.
```

Before relying on that statement, inspect:

```powershell
git branch --show-current
git status --short
git log --oneline --decorate -10
Get-Content PROJECT_STATUS.md
Get-Content NEXT_TASK.md
```

Reconcile stale status documents before completing the current task.

---

# 6. Known incomplete product work outside the current notification task

Earlier phases may be phase-scoped complete while the full product still lacks the following.

These items must not be forgotten. Each is assigned to a later completion stage or backlog gate.

## 6.1 Home

Still required for full product completion:

- Configurable dashboard layout
- Reorder, hide, restore, and configure widgets
- Date and greeting widget
- Next-event widget
- Priority and due-task widgets
- Overdue and follow-up widgets
- Free-window and workload widgets
- Goal progress
- Focus-time summary
- Generic Space metrics
- Morning plan and evening review
- Deterministic insight widgets before AI is enabled

Primary ownership:

- Stage 8 for metrics and dashboard configuration
- Stage 9 for AI suggestions
- Stage 10 for final polish

## 6.2 Global Quick Add

The existing foundation may still be a placeholder.

Full completion requires a generic, validated capture flow for supported entities without embedding personal shortcuts.

Primary ownership:

- Stage 10 product-completion backlog
- Stage 9 may add AI-assisted proposals, but manual Quick Add must remain functional without AI

## 6.3 Global Search

Full product completion requires:

- Search contract
- Local indexing or query strategy
- Search across core entities and supported Space records
- Filtering and result grouping
- Empty and error states
- Deep links to results
- Performance tests for realistic local data

Primary ownership:

- Stage 10

Search must not wait for cloud functionality.

## 6.4 Planner gaps

Verify and complete where absent:

- Upcoming view
- Overdue view
- Unscheduled view
- Recurring view
- Waiting view
- Completed view
- Low-energy view
- Deep-work view
- Bulk actions
- Search, filter, and sort
- Task dependencies
- Richer meeting participants, preparation, outcomes, and follow-ups
- Robust recurrence coverage beyond the current limited rules
- Reminder integration with persisted rules and platform scheduling

Primary ownership:

- Stage 7 for reminders
- Stage 10 for non-notification planner completion and polish

## 6.5 Spaces gaps

Verify and complete where absent:

- Calendar view
- Timeline view
- Chart view
- Generic forms
- Duplicate and reorder operations
- Space-level analytics
- Space automations
- Broader field types from the product specification
- File references, relationship fields, formulas, progress fields, and status fields where not yet supported

Primary ownership:

- Stage 8 for analytics and charts
- Stage 7 for automations
- Stage 10 for remaining Spaces completion

Do not implement every possible database feature without evidence. Complete the documented initial types and views with tests.

## 6.6 Templates gaps

Full product behavior requires:

- Templates that materialize editable configuration
- Optional example data
- No required example data
- Deterministic installation transactions
- Versioned template upgrades
- Uninstall choices that actually preserve, archive, export, or delete created records
- Complete independence when zero templates are installed

Primary ownership:

- Stage 10 unless a documented decision schedules a dedicated earlier completion task

## 6.7 Notes and knowledge gaps

Verify and complete where absent:

- Markdown or approved structured content behavior
- Pinning
- Search
- Backlinks
- Attachments or file references
- Templates
- Rich links to supported entities and Space records
- AI summary and extraction only in Stage 9

Primary ownership:

- Stage 10 for local features
- Stage 9 for AI assistance

## 6.8 Settings gaps

Full completion requires:

- Profile-independent local preferences
- Theme and accent
- Locale
- Currency as configurable data
- Date and time formats
- First day of week
- Notification settings
- Quiet hours
- Spaces and templates management
- Backup, restore, and export
- Security and biometric lock
- Diagnostics and logs
- Database and app version
- Safe demo-data reset if demo data exists

Primary ownership:

- Stage 7 for notification settings and quiet hours
- Stage 10 for backup, security, diagnostics, and final settings integration

## 6.9 Deep links and external links

Verify and complete:

- Deep-link-compatible detail routes
- Safe external URL launching
- Notification taps routing to supported targets
- Search results routing to supported targets

Primary ownership:

- Stage 7 for notification taps
- Stage 10 for complete deep-link and external-link verification

---

# 7. Remaining stage plan

The agent may divide a numbered stage into internal subtasks, focused commits, and test passes.

The agent must not stop for user approval after every internal subtask unless a genuine decision or blocker requires it.

The agent must stop after completing the entire numbered stage, produce a handoff, and wait for explicit user approval before starting the next numbered stage.

---

# 8. Stage 7 — Notifications and automations

## 8.1 Goal

Deliver complete local notification, reminder, inbox, background, snooze, quiet-hours, and limited automation behavior behind replaceable boundaries.

## 8.2 Stage 7 required capabilities

### A. Notification contracts

Required:

- Generic notification intent
- Permission states
- Replaceable notification service
- Replaceable platform adapter
- Deterministic platform notification identifiers
- Safe validation
- Structured logging
- Explicit failures for denied, unavailable, invalid, and platform-error states

This foundation is believed to be complete but must be audited.

### B. Reminder and inbox persistence

Required:

- Schema version 8 or the verified current version
- `reminder_rules`
- `notification_inbox`
- Explicit v7 → v8 migration
- Foreign keys
- Query indexes
- Fresh-database tests
- Migration data-preservation tests
- Domain models
- Repository contracts
- Drift implementation
- Riverpod providers

Required reminder behavior:

- Create
- Read by ID
- Update
- Enable
- Disable
- Cancel
- List and watch
- Owner filtering
- Due-reminder queries
- Platform notification ID assignment and clearing
- UTC timestamps
- UUID generation
- Validation
- Failure translation

Required inbox behavior:

- Create
- Read by ID
- List and watch newest-first
- Read/unread state
- Unread count
- Mark read
- Mark all read where required
- Owner filtering
- Cancellation state where supported
- Nullable reminder reference
- Correct `SET NULL` behavior when a reminder rule is removed

### C. Production local-notification adapter

Required:

- `flutter_local_notifications` integration
- Idempotent initialization
- Android notification channel creation
- Permission inspection
- Runtime permission request where supported
- Schedule
- Reschedule
- Cancel
- Cancel-all only when required
- Correct plugin version API
- Error translation
- Structured logging
- Testable adapter seam
- Riverpod production wiring
- Test overrides

Android configuration must be based on the installed plugin version, not guessed.

Verify:

- Android 13+ permission requirements
- Scheduled-notification receivers
- Boot rescheduling requirements
- Notification icon
- Exact-alarm behavior
- Desugaring
- Compile SDK requirements

Do not add permissions speculatively.

### D. Persisted scheduling coordination

Required:

- Connect persisted reminder rules to the notification service
- Persist platform notification identifiers
- Prevent duplicate scheduling
- Reschedule when a rule changes
- Cancel platform jobs when a rule is disabled or canceled
- Recover from partial failure
- Use transactions where consistency requires them
- Keep persistence and platform operations coordinated through a service or use case
- Do not let the platform adapter write to Drift

### E. Restart and timezone reconciliation

Required:

- Reconcile enabled future reminders after app restart
- Handle timezone or clock changes according to supported platform behavior
- Avoid duplicate jobs
- Remove or repair stale platform identifiers
- Record meaningful failures
- Keep reconciliation idempotent
- Add tests for repeated runs

Platform boot behavior must be implemented only to the degree supported by Android and the chosen package.

### F. Feature-driven reminders

Add generic reminder creation or linking for supported entities without hard-coded personal workflows.

Minimum supported owners should be chosen from existing stable entities and documented.

Likely candidates:

- Tasks
- Planner events or meetings
- Goals or goal reviews
- Generic Space records
- Custom reminders

Requirements:

- Feature code produces domain reminder requests.
- Reminder persistence and scheduling remain behind services.
- Deleting or archiving an owner has defined behavior.
- Invalid or past scheduling is handled predictably.
- Feature widgets do not access platform APIs.

Do not add every notification category at once if a smaller generic owner model satisfies the product contract.

### G. Notification inbox UI

Required:

- Loading
- Empty
- Content
- Error
- Read/unread indication
- Mark read
- Mark all read where required
- Filtering by category or owner where useful
- Safe tap behavior
- Deep link to supported owner
- Graceful behavior when the owner no longer exists
- Accessible controls
- Compact-screen safety

### H. Snooze

Required:

- Supported snooze durations or a custom time
- New scheduled occurrence
- Persistent state
- Cancellation or replacement of the previous platform job
- Duplicate prevention
- Clear history or relationship to the original reminder
- Tests using a fixed clock

Do not hard-code Mahmoud's reminder preferences.

### I. Quiet hours

Required:

- User-controlled quiet-hours settings
- Disabled state
- Start and end times
- Overnight windows
- Timezone-aware evaluation
- Defined policy for reminders inside quiet hours
- Predictable rescheduling or suppression
- Settings UI
- Tests around boundaries and overnight windows

The policy must be documented. Do not silently drop reminders.

### J. Background work

Use `workmanager` only where justified.

Required:

- Replaceable background-work boundary
- Idempotent jobs
- Unique job names
- Duplicate prevention
- Safe retry behavior
- Logging
- No direct UI dependency
- Reconciliation job where platform behavior requires it
- Tests for the pure job logic
- Android debug build validation

Do not create frequent background polling without a documented need.

### K. Automation foundation

Implement a limited generic:

```text
Trigger → Conditions → Actions
```

Required minimum:

- Automation rule domain model
- Persistent rule storage when needed
- Enabled and disabled states
- Limited supported trigger registry
- Limited condition registry
- Limited action registry
- Validation
- Run history
- Idempotency key or equivalent duplicate protection
- Success and failure states
- Error summary
- Structured logs
- User visibility
- Safe disable behavior

Actions must call existing domain services or repositories.

Automations must not bypass validation or write raw database rows.

Initial automation scope should be deliberately small and generic.

### L. Stage 7 integration

Required:

- Notification settings
- Startup initialization
- Recoverable initialization failures
- Notification tap routing
- End-to-end service wiring
- Focused unit tests
- Repository tests
- Provider tests
- Widget tests
- Migration tests
- Integration tests for critical scheduling flows
- Android debug APK build
- Real-device verification for permission, schedule, delivery, tap, cancellation, and restart behavior where practical

## 8.3 Stage 7 exclusions

Do not implement:

- Analytics dashboards
- AI proposals
- Backup and restore
- Cloud synchronization
- Real remote AI
- Personal hard-coded reminder categories
- Unrelated feature redesign

## 8.4 Stage 7 acceptance criteria

Stage 7 is complete only when:

- Permission denial and unavailability are handled safely.
- A persisted reminder can be scheduled, changed, disabled, canceled, and recovered.
- Duplicate jobs are prevented.
- Platform identifiers remain consistent with persisted records.
- Scheduling survives restart where the platform permits.
- Notification inbox behavior is persistent and usable.
- Snooze works without duplicates.
- Quiet hours are configurable and tested.
- Background jobs are idempotent.
- Limited automations run through approved boundaries.
- Automation runs are logged and idempotent.
- Notification UI states are complete.
- Analyzer has no issues.
- All tests pass.
- Debug APK builds.
- Required device checks are recorded.
- Documentation is current.
- The branch is clean after focused commits and push.

## 8.5 Stage 7 stop condition

After all Stage 7 acceptance criteria pass:

1. Update all required documentation.
2. Record full validation.
3. Commit and push focused changes.
4. Produce the required handoff.
5. Stop.
6. Wait for explicit user approval before Stage 8.

---

# 9. Stage 8 — Analytics, Insights, and configurable dashboards

## 9.1 Goal

Deliver deterministic analytics derived from stored local data and expose them through configurable Insights and Home dashboard surfaces.

## 9.2 Required capabilities

### A. Metric contracts

Implement generic metric definitions for:

- Tasks created
- Tasks completed
- Completion rate
- Overdue rate
- Planned time
- Actual time
- Planned versus actual variance
- Focus time
- Area balance
- Goal progress
- Project progress
- Space record counts
- Space status distributions
- Generic funnels where configured
- Financial trends only when stable finance data exists
- Learning consistency only through generic configurable data

Do not hard-code metrics for a personal template.

### B. Query and computation layer

Required:

- Domain metric definitions
- Repository or query-service boundary
- Deterministic date ranges
- UTC-safe boundaries
- Efficient aggregate queries
- No heavy computation in widget build methods
- Clear insufficient-data behavior
- Testable pure calculations
- Indexed filters where necessary

### C. Filters

Support documented combinations of:

- Date range
- Area
- Space
- Goal
- Project
- Tag
- Status
- Metric
- Chart type

Filters must remain generic and composable.

### D. Dashboard configuration

Required:

- Configurable Insights dashboards
- Configurable Home widgets
- Add, remove, reorder, hide, restore
- Persisted configuration
- Safe defaults
- Zero configured widgets state
- Invalid configuration recovery
- Responsive layout

### E. Charts

Use `fl_chart`.

Required initial chart types should be selected based on documented metrics, likely:

- Line
- Bar
- Pie or donut
- Progress
- Status distribution

Requirements:

- Accessible labels or summaries
- Empty and insufficient states
- No misleading chart with insufficient data
- No fixed personal colors or categories
- Performance tests for realistic local datasets

### F. Insight cards

Implement deterministic, non-AI insight cards.

Examples:

- Completion trend
- Overdue change
- Plan-versus-actual difference
- Focus-time trend
- Area imbalance
- Goal at risk based on stored progress and deadlines

Every insight must:

- Explain the underlying data
- Avoid pretending correlation is causation
- Handle insufficient data
- Be reproducible in tests

### G. Stage 8 integration

Required:

- Insights destination becomes functional
- Home dashboard gains configurable analytics widgets
- Loading, empty, content, and error states
- Widget, domain, repository, provider, and performance tests
- Documentation
- Debug APK verification when UI/platform changes justify it

## 9.3 Data-model policy

Do not increment the schema merely to cache derived metrics.

Add persistence only for:

- Dashboard configuration
- Saved metric definitions
- Saved filters
- Materialized aggregates proven necessary by profiling

Any schema change requires migration tests and documentation.

## 9.4 Stage 8 exclusions

Do not implement:

- AI-generated insights
- Real AI provider
- Cloud analytics
- Server telemetry
- Hard-coded personal dashboards
- Backup/restore
- Unrelated feature completion

## 9.5 Stage 8 acceptance criteria

Stage 8 is complete only when:

- Metrics derive from stored local data.
- Filters are deterministic and tested.
- Insights and Home dashboards are configurable.
- Empty and insufficient states are clear.
- Charts are generic and accessible.
- No dashboard is tied permanently to an optional template.
- Performance is acceptable with realistic local data.
- Analyzer and tests pass.
- Documentation is current.
- Changes are committed and pushed.
- Final working tree is clean.

## 9.6 Stage 8 stop condition

After Stage 8 is complete:

1. Update documentation.
2. Record validation.
3. Commit and push.
4. Produce the full handoff.
5. Stop.
6. Wait for explicit user approval before Stage 9.

---

# 10. Stage 9 — Safe AI contracts and Mock AI

## 10.1 Goal

Deliver a complete provider-independent AI interaction and action-proposal system using `MockAiService`, without a real provider or embedded secret.

## 10.2 Required capabilities

### A. AI service boundary

Required:

- `AiService`
- `MockAiService`
- Injectable provider
- Explicit request and response models
- Cancellation and failure handling
- No direct dependency on Drift
- No embedded provider secrets

### B. Tool registry

Implement a typed tool registry for a deliberately limited set of safe proposals.

Potential initial tools:

- Propose tasks
- Propose task updates
- Propose a plan
- Propose time blocks
- Propose reminders
- Propose goal review notes
- Summarize selected local records
- Extract task candidates from user-provided text

Tools must propose; they must not execute writes directly.

### C. Structured proposal schemas

Required:

- Typed proposal payloads
- Versioning
- Validation
- Human-readable summary
- Detailed preview
- Affected entities
- Risk level
- Rejection reason
- Editable fields where safe

Reject malformed or unsupported proposals.

### D. Preview, edit, approval, and rejection

Required UI:

- Loading
- Error
- Proposal preview
- Edit where supported
- Approve
- Reject
- Partial failure handling
- Clear warning for destructive proposals
- Accessible controls

No write occurs before explicit approval.

### E. Execution boundary

Approved actions must execute through:

- Controllers
- Use cases
- Repositories
- Transactions where necessary

Never through raw Drift access from AI code.

### F. Action history

Persist or otherwise reliably record:

- Proposal
- Approved payload
- Validation result
- Status
- Applied timestamp
- Failure
- Undo availability
- Undo timestamp

Do not store secrets.

### G. Undo

Required for safely reversible actions.

Undo must:

- Validate current state
- Avoid overwriting unrelated later changes
- Record result
- Fail safely when no longer possible
- Explain why undo is unavailable

### H. Mock AI behavior

`MockAiService` must:

- Return deterministic outputs
- Support test scenarios
- Simulate failures
- Simulate invalid proposals
- Require no network
- Require no API key

### I. AI Copilot surface

Replace the placeholder with:

- Conversation or request entry
- Mock response
- Structured proposals
- Preview and approval
- History
- Error states
- Privacy explanation
- Clear statement that no external provider is active

### J. AI-assisted local features

Where included:

- Notes summary
- Task extraction
- Planning suggestions
- Daily suggestion
- Reminder proposals

All remain mock/local proposal flows.

## 10.3 Stage 9 exclusions

Do not implement:

- Real remote AI provider
- Direct client-side provider secret
- Automatic writes
- Cloud synchronization
- Unreviewed background AI
- Reading private messages
- Full WhatsApp integration

## 10.4 Stage 9 acceptance criteria

Stage 9 is complete only when:

- AI is provider-independent.
- Mock AI works without network access.
- Every write is previewed and explicitly approved.
- Invalid proposals are rejected.
- Approved actions use domain boundaries.
- Action history is available.
- Safe undo works where supported.
- No external provider or embedded secret exists.
- Analyzer and tests pass.
- Documentation is current.
- Changes are committed and pushed.
- Final working tree is clean.

## 10.5 Stage 9 stop condition

After Stage 9 is complete:

1. Update documentation.
2. Record validation.
3. Commit and push.
4. Produce the full handoff.
5. Stop.
6. Wait for explicit user approval before Stage 10.

---

# 11. Stage 10 — Search, backup, export, security, and product completion

## 11.1 Goal

Complete the remaining local product gaps, deliver safe data portability and local security, and prepare a stable device-tested build.

## 11.2 Required capabilities

### A. Global search

Complete the search behavior described in Section 6.3.

### B. Backup and restore

Required:

- Versioned JSON backup format
- Export of supported local entities and settings
- Integrity metadata
- Validation before restore
- Preview or summary before destructive replacement
- Transactional restore where possible
- Safe rollback on failure
- Migration of older backup versions
- Tests proving round-trip data preservation
- Explicit handling of unknown or unsupported fields

### C. CSV export

Support useful generic exports for stable entities and Space records.

Requirements:

- Deterministic column names
- Configurable fields
- Correct escaping
- UTC or documented display timestamps
- No hidden personal assumptions

### D. Security

Required:

- Biometric lock where supported
- Secure-storage-backed security settings
- Safe fallback when biometrics are unavailable
- No sensitive secrets in normal preferences
- App lifecycle lock behavior
- Tests for pure policy logic
- Real-device verification

### E. Diagnostics and logs

Required:

- App version
- Database schema version
- Safe diagnostic summary
- Exportable redacted logs where appropriate
- No secrets or private content by default
- Recoverable error information

### F. Accessibility audit

Required:

- Labels
- Touch targets
- Contrast
- Keyboard/focus behavior where relevant
- Screen-reader review
- Text scaling
- Compact-screen overflow
- Empty/error-state clarity

### G. Performance audit

Required:

- Realistic local datasets
- Query profiling
- Large-list behavior
- Search performance
- Chart performance
- Startup performance
- Avoid full-table loading where inappropriate
- Add indexes only when justified

### H. Earlier product-gap closure

Audit and complete the missing items listed in Section 6, including:

- Manual Quick Add
- Remaining Planner views and filters
- Remaining Spaces views and forms
- Template materialization and uninstall behavior
- Notes and backlinks
- Settings integration
- Deep links
- External URL safety

Do not broaden the product beyond the approved specification.

### I. Stable build and real-device verification

Required:

- Full test suite
- Integration tests for critical workflows
- Debug APK
- Real-device install
- Database migration test on device where feasible
- Notification verification
- Backup/restore verification
- Biometric verification where available
- Accessibility and layout review
- Documented known issues

## 11.3 Stage 10 acceptance criteria

Stage 10 is complete only when:

- Backup round-trip preserves data.
- Restore failures are safe.
- CSV export works.
- Search is functional.
- Security settings work on supported devices.
- Diagnostics are useful and redacted.
- Critical accessibility issues are addressed.
- Critical performance issues are addressed.
- Earlier local product gaps are reconciled.
- Full tests pass.
- Stable debug APK builds.
- Required real-device checks pass.
- Documentation is current.
- Changes are committed and pushed.
- Final working tree is clean.

## 11.4 Stage 10 stop condition

After Stage 10 is complete:

1. Update documentation.
2. Record validation and device results.
3. Commit and push.
4. Produce the full handoff.
5. Stop.
6. Wait for explicit approval before any Stage 11 work.

---

# 12. Stage 11 — Cloud, synchronization, and real AI later

Stage 11 must not begin automatically.

Potential scope:

- Authentication
- Supabase
- PowerSync
- Cross-device synchronization
- Conflict resolution
- Secure server-side AI
- Remote AI provider
- Google Calendar integration
- Advanced WhatsApp Business integration
- Multi-device notification coordination

Before Stage 11:

1. Local product must be stable.
2. Repository and sync boundaries must be reviewed.
3. Threat model must be documented.
4. Data migration and conflict strategy must be approved.
5. Backend secret handling must be approved.
6. New architecture decisions must be recorded.
7. User must explicitly authorize the stage.

---

# 13. Stage execution protocol

## 13.1 Beginning a numbered stage

Before implementation:

```powershell
Set-Location "C:\Mahmoud\Coding\My Planner"

git branch --show-current
git status --short
git log --oneline --decorate -10
```

Then:

1. Read all required documents.
2. Inspect relevant source and tests.
3. Reconcile `PROJECT_STATUS.md` and `NEXT_TASK.md`.
4. Confirm the stage scope internally.
5. Break the stage into bounded internal tasks.
6. Define acceptance criteria and stop conditions.
7. Do not implement a later numbered stage.

## 13.2 During a numbered stage

The agent may:

- Work through internal subtasks without asking for routine approval
- Use focused commits
- Run focused tests repeatedly
- Update documentation as verified work changes

The agent must:

- Preserve unrelated work
- Avoid destructive Git commands
- Read full failures
- Fix root causes
- Keep architecture boundaries
- Use available relevant skills carefully
- Never claim commands ran when they did not
- Never claim tests passed without output

## 13.3 End of a numbered stage

Required:

1. All stage acceptance criteria pass.
2. Documentation is reconciled.
3. Focused tests pass.
4. Full tests pass.
5. Analyzer reports no issues.
6. Generated files are current.
7. Required APK build passes.
8. Required device checks are recorded.
9. `git diff --check` passes.
10. Intended changes are committed.
11. Push succeeds.
12. Final working tree is clean.
13. Full handoff is produced.
14. Agent stops and waits for user approval.

The agent must not begin the next stage in the same unattended run.

---

# 14. Validation standards

## 14.1 Normal code changes

Run:

```powershell
dart format .
flutter analyze
flutter test
git diff --check
```

## 14.2 Drift or generated-model changes

Run:

```powershell
dart run build_runner build
dart run drift_dev make-migrations
dart format .
flutter analyze
flutter test
git diff --check
```

Never manually edit generated Drift files.

Do not delete old schema snapshots.

## 14.3 Android or platform changes

Run:

```powershell
dart format .
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

## 14.4 Required testing layers

Use as relevant:

- Pure domain unit tests
- Repository tests
- Provider override tests
- Migration tests
- Service and adapter tests
- Controller tests
- Widget tests
- Integration tests
- Real-device verification

Tests must be deterministic and independent of current personal data.

---

# 15. Documentation standards

At the end of every meaningful task or stage, update as relevant:

- `PROJECT_STATUS.md`
- `NEXT_TASK.md`
- `docs/FEATURE_MATRIX.md`
- `docs/DECISIONS.md`
- `docs/TEST_PLAN.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA_MODEL.md`
- `docs/NAVIGATION.md`
- `docs/DESIGN_SYSTEM.md`
- `docs/PRODUCT_SPEC.md`
- `CHANGELOG.md`
- This master specification when the consolidated plan changes

Documentation must describe verified behavior, not aspirations disguised as completion.

`NEXT_TASK.md` must contain exactly one bounded next task after a stage handoff.

---

# 16. Git standards

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

Stage explicit files.

Do not use `git add -A` when unrelated changes may exist.

Inspect:

```powershell
git diff --cached --check
git diff --cached --stat
git status --short
```

Do not:

- Force-push
- Rewrite history
- Reset hard
- Clean untracked work
- Restore unrelated files
- Commit failing work to `main`

`main` must represent verified work, including real-device verification where required.

---

# 17. Required stage handoff

Every numbered stage handoff must include:

```text
Stage:
Completed:
User-facing behavior completed:
Architecture completed:
Persistence and migrations:
Files changed:
Commands run:
Focused tests:
Full test count:
Analyzer:
APK build:
Device verification:
Documentation updated:
Known issues:
Decisions made:
Commits:
Push:
Next proposed stage:
Files required in the next chat:
Exact final git status --short:
```

The agent must then stop.

---

# 18. Immediate next action

Do not start Stage 8.

First complete the remaining Stage 7 work.

The immediate bounded task must be taken from the verified local `NEXT_TASK.md`. The last known task is the Drift-backed notification repository and Riverpod provider completion.

After that task, continue through the remaining Stage 7 sections in this specification.

When all Stage 7 requirements are complete, validate, document, commit, push, produce the Stage 7 handoff, and wait for explicit user approval.
