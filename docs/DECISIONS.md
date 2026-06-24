# Momentum OS Decision Log

This document records architecture and product decisions that must survive across conversations and coding agents.

## DEC-001 — Rebuild with Flutter

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Build Momentum OS from a clean Flutter project rather than migrating the previous native Android Jetpack Compose implementation.

### Rationale

The previous version became overcomplicated, included hard-coded assumptions, and experienced startup failures. The conceptual product can be retained without inheriting its implementation risks.

### Consequences

- No native architecture migration.
- Previous code is reference-only.
- Android is the initial target while Flutter preserves future platform options.

---

## DEC-002 — Local-first initial architecture

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Use a local SQLite database through Drift as the initial source of truth. Do not connect Supabase or PowerSync until the local product is stable.

### Rationale

Core planner workflows must work offline and remain simple to develop, test, and debug before adding distributed-state complexity.

### Consequences

- Repository boundaries must support future remote implementations.
- IDs and timestamps must be synchronization-ready.
- Cloud authentication and multi-user concerns are deferred.

---

## DEC-003 — Feature-first architecture

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Organize the application by feature with data, domain, and presentation boundaries where useful.

### Rationale

Feature ownership and bounded changes are easier to maintain than a repository-wide layer-first structure.

### Consequences

- Widgets do not access Drift directly.
- Repository contracts separate domain behavior from persistence.
- Empty ceremonial layers are not required.

---

## DEC-004 — Approved core stack

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Use Flutter, Riverpod, GoRouter, Drift/SQLite, Freezed where useful, and `json_serializable`, with the additional packages listed in `docs/ARCHITECTURE.md`.

### Rationale

The stack supports reactive local data, testable dependency injection, structured routing, code generation, notifications, background work, and future expansion.

### Consequences

Alternative core packages require a documented decision before introduction.

---

## DEC-005 — Generic core with optional templates

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Personal activities and domain-specific workflows must be represented through optional templates, configurable Spaces, settings, or user-created data rather than permanent core assumptions.

### Rationale

Momentum OS should remain usable beyond one person's current circumstances.

### Consequences

- No core tables named for current activities, employers, universities, or courses.
- Templates are editable and removable.
- The shell must work with zero templates installed.

---

## DEC-006 — UUID v4 identifiers

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Use UUID v4 identifiers for persistent entities from the first database schema.

### Rationale

Client-generated globally unique identifiers simplify offline creation and future synchronization.

### Consequences

- IDs are strings in domain/database contracts unless a later documented decision changes representation.
- Repository tests verify identifier creation.

---

## DEC-007 — Provider-independent and approval-gated AI

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

AI providers sit behind `AiService`. Initial AI is `MockAiService`. Any data-changing proposal requires preview, validation, approval, logging, and safe undo.

### Rationale

AI must not become an unsafe or tightly coupled persistence pathway.

### Consequences

- No direct database access from AI integrations.
- No API key embedded in the client.
- Real provider integration is deferred to a secure backend phase.

---

## DEC-008 — Repository documentation is project memory

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Repository documents, especially `PROJECT_STATUS.md` and `NEXT_TASK.md`, are authoritative project memory across chats and agents.

### Rationale

Long conversations become unreliable and slow. Durable repository state prevents scope drift.

### Consequences

- Each meaningful task updates status, next task, feature matrix, decisions, and changelog as relevant.
- New agents read documentation before modifying code.

---

## DEC-009 — Five primary destinations

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Use Home, Planner, Spaces, Goals, and Insights as the five primary navigation destinations.

### Rationale

This balances frequent access to execution, configuration, direction, and review without exposing every module as a top-level tab.

### Consequences

Global actions handle Quick Add, AI, Search, Notifications, and Settings.

---

## DEC-010 — Terminal-first Windows workflow

**Status:** Accepted  
**Date:** 2026-06-24

### Decision

Prefer copy-paste-ready PowerShell, Flutter CLI, Dart CLI, Git, and ADB commands over manual file creation and editor clicking.

### Rationale

The project is developed on Windows and benefits from reproducible, fast automation.

### Consequences

- Commands state their required working directory.
- Destructive commands require warnings.
- Repeated workflows should become scripts.
