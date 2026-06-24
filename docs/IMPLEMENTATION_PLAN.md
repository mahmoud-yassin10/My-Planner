# Momentum OS Implementation Plan

## Working model

Work one bounded task at a time. Every task must define goal, scope, files, commands, acceptance criteria, and stop condition.

No later phase begins before the current phase is validated and documented.

## Phase 0 — Documentation and clean project creation

### Deliverables

- Clean Flutter Android project
- Git repository and GitHub remote
- Product specification
- Architecture
- Data model
- Design system
- Navigation
- Feature matrix
- Decision log
- Test plan
- Implementation plan
- Agent rules
- Status and next-task tracking

### Acceptance

- Starter analysis and tests pass.
- Required documents are populated.
- Initial commit is pushed.
- No product features are implemented.

## Phase 1 — Application foundation

### Scope

- Add Riverpod and GoRouter
- Replace default counter starter
- Application bootstrap
- Material 3 theme system
- Five-destination responsive shell
- Placeholder destination screens
- Global Quick Add, AI, Search, and Notification entry points
- Reusable loading, empty, and error states
- Error boundary
- Structured logging foundation
- Foundation widget/navigation tests

### Exclusions

- Drift/database
- Real feature CRUD
- Templates
- Notifications scheduling
- Analytics computation
- AI writes

### Acceptance

- App launches to Home without startup errors.
- All five destinations navigate correctly.
- Global actions are reachable.
- Theme mode works.
- Foundation states are reusable and tested.
- Analyzer and tests pass.
- Debug APK builds when requested.

## Phase 2 — Drift foundation

### Scope

- Drift packages and generator
- Database class
- Schema versioning
- UUID service
- Common timestamp conventions
- Repository contracts
- Initial local implementations
- Typed settings
- Seed/template mechanism contract
- Backup-ready serialization contract
- Database tests

### Acceptance

- Database opens reliably.
- Migrations have tests.
- Widgets cannot access Drift directly.
- Repository contract tests pass.
- Generated code is current.

## Phase 3 — Productivity core

### Scope

- Areas
- Goals and hierarchy
- Projects
- Milestones
- Tasks/subtasks
- Tags
- Relationships
- Notes

Implement vertical slices with domain, repository, controller, UI, validation, and tests.

### Acceptance

- Core hierarchy can be created and edited.
- Archive/restore works.
- Empty/error/loading states exist.
- Relationships remain valid.
- Tests cover main domain rules.

## Phase 4 — Planner

### Scope

- Day, week, month, and agenda
- Events/meetings
- Time blocks
- Recurrence
- Reminders contract
- Focus sessions
- Free-time detection
- Estimated vs actual time
- Conflict detection

### Acceptance

- Tasks and events appear consistently across views.
- Scheduling and rescheduling preserve data.
- Conflicts and free windows are accurate.
- Focus time updates actual effort.

## Phase 5 — Spaces engine

### Scope

- Space definitions
- Record types
- Custom fields
- Editable statuses
- Records and relationships
- Saved filters
- List/table/board/calendar/card views
- Template installer/uninstaller foundation

### Acceptance

- A user can build a useful Space without code changes.
- Field validation is type-safe.
- Views use saved configuration.
- Removing a Space does not break the app shell.

## Phase 6 — Templates

### Scope

Removable configurations for:

- Freelancing CRM
- Finance
- Opportunities
- Learning
- Competitive programming
- Machine learning
- University
- Fitness
- Reading
- Content creation

### Acceptance

- Templates are editable.
- Example data is optional.
- Uninstall offers preservation/archive/export/delete.
- Zero installed templates remains a supported state.

## Phase 7 — Notifications and automations

### Scope

- Local notifications
- Reminder scheduling
- Background jobs
- Notification inbox
- Snooze
- Quiet hours
- Trigger-condition-action foundation

### Acceptance

- Scheduling survives restart where platform permits.
- Duplicate notification jobs are prevented.
- Permission denial is handled.
- Automation runs are logged and idempotent.

## Phase 8 — Analytics

### Scope

- Generic metrics
- Date, Area, Space, Goal, Project, tag, and status filters
- Configurable dashboards
- Charts
- Insight cards

### Acceptance

- Metrics derive from stored data.
- Empty/insufficient states are clear.
- No chart is permanently tied to a personal template.

## Phase 9 — AI contracts and mock AI

### Scope

- `AiService`
- `MockAiService`
- Tool registry
- Structured proposal schemas
- Preview/edit/approval
- Validation
- Action history
- Undo

### Acceptance

- AI never writes directly to Drift.
- Every write is previewed and approved.
- Invalid proposals are rejected.
- Safe undo works.
- No external provider or embedded secret exists.

## Phase 10 — Backup, export, security, and polish

### Scope

- JSON backup/restore
- CSV export
- Biometric lock
- Diagnostics and logs
- Accessibility audit
- Performance audit
- Full test suite
- Stable debug APK

### Acceptance

- Backup round-trip preserves data.
- Restore failures are safe.
- Security settings work on device.
- Required accessibility and performance issues are addressed.
- Real-device verification passes.

## Phase 11 — Cloud and real AI later

Potential scope:

- Supabase
- PowerSync
- Authentication
- Cross-device synchronization
- Secure AI backend
- Google Calendar
- Advanced WhatsApp Business integration

This phase requires new decisions and must not begin automatically.
