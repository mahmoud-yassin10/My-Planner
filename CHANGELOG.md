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
- Drift schema version 3 snapshot and migration verification tests
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
