# Changelog

All notable changes to Momentum OS are documented in this file.

The project follows a phase-based development process. Version numbers will be introduced when the first distributable application baseline is established.

## [Unreleased]

### Added

- Riverpod app foundation with a root `ProviderScope`
- GoRouter routing with centralized route names and paths
- Deterministic `/` to `/home` redirect
- Adaptive primary shell with compact bottom navigation and wider navigation rail
- Placeholder screens for Home, Planner, Spaces, Goals, and Insights
- Global Quick Add placeholder sheet with generic creation choices
- Placeholder routes for AI Copilot, Global Search, Notification Inbox, and Settings
- Reusable loading, empty, and error foundation widgets
- Structured logging abstraction with Riverpod provider and injectable sink
- Recoverable startup initialization handling with retry screen
- Route-level error screen for unavailable routes
- Centralized light and dark Material 3 themes
- Updated the default Momentum OS palette to a blue accent with refined light and dark surfaces
- Drift and SQLite persistence foundation with schema version 1
- App settings and schema metadata tables only for the Phase 2 schema
- Production and in-memory database openers with foreign keys enabled
- Drift schema snapshot for `app_database` version 1
- Database startup initialization through the recoverable startup host
- Replaceable UUID v4 and UTC clock services
- Typed settings repository with defaults, updates, watch stream, reset, validation, and failure translation
- Minimal seed/template installation contract
- Backup envelope serialization contract for Phase 2 settings payloads
- Persistence convention and failure boundary helpers
- Settings watch-stream persistence failures are translated at the repository boundary
- Removed unused SQLite native bundle and JSON serialization/code-generation dependencies
- Schema version 2 with Areas, Goals hierarchy, Projects, and Milestones
- Drift-backed hierarchy repository with validation, archive/restore/delete behavior, and Riverpod providers
- Goals destination now renders the Phase 3A hierarchy with loading, empty, content, and error states
- Drift schema version 2 snapshot, generated migration helper, and migration verification tests
- Schema version 3 with Tasks, subtasks, Tags, entity-tag relationships, Notes, and note links
- Drift-backed task-core repository with validation, completion, archive/restore/delete behavior, and Riverpod providers
- Planner destination now renders the Phase 3B task core with loading, empty, content, and error states
- Productivity-core edit, restore, task-tagging, note-linking, and relationship-visibility polish for Goals and Planner
- Schema version 4 with Planner events and time blocks
- Drift-backed Planner repository with event, time-block, conflict, free-window, and provider tests
- Planner Day, Week, Month, and Agenda foundation views for events, time blocks, and scheduled tasks
- Schema version 5 with focus sessions
- Planner recurrence expansion, reminder contract validation, task scheduling, actual-duration, and focus-session completion behavior
- Schema version 6 with Space definitions, record types, fields, statuses, records, record links, saved filters, and saved views
- Drift-backed Spaces repository with validation, watch updates, failure translation, and Riverpod providers
- Spaces destination now renders the Phase 5A Spaces foundation with loading, empty, content, and error states
- Spaces archive, restore, and explicit delete operations for implemented Spaces entities
- Saved Spaces list, table, board, and card view rendering with deterministic saved-view configuration validation
- Schema version 7 with template installation metadata
- Template infrastructure with injectable registry, install metadata, uninstall choices, repository/provider boundary, and foundation panel states
- Bundled template descriptors for the planned Phase 6 template categories without example records or created user data
- Drift schema snapshots and migration verification tests through version 7
- Database, repository, provider, startup, service, contract, and migration-snapshot tests
- Widget and unit tests for navigation, global actions, reusable states, logging, startup recovery, and route errors
- Clean Flutter Android project using project name `momentum_os`
- Android namespace `com.mahmoudyassin.momentum_os`
- Git repository and GitHub remote
- Product specification
- Architecture plan
- Data-model plan
- Design-system plan
- Navigation plan
- Feature matrix
- Decision log
- Test plan
- Implementation plan
- Project status and next-task tracking
- Agent and coding workflow rules

### Notes

- Phase 1 foundation intentionally uses placeholders for creation, AI, Search, Notifications, and Settings.
- Productivity CRUD, real AI, real Search, notification scheduling, analytics, real templates, backup files, restore flows, and cloud synchronization remain unimplemented.
