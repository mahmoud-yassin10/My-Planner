# Momentum OS Feature Matrix

Status values:

- `Not started`
- `Planned`
- `In progress`
- `Blocked`
- `Complete`
- `Deferred`

## Foundation

| Feature | Phase | Status | Notes |
|---|---:|---|---|
| Clean Flutter Android project | 0 | Complete | Starter project created |
| Repository documentation | 0 | Complete | Initial specification package |
| Git/GitHub setup | 0 | Complete | Initial repository published |
| Riverpod foundation | 1 | Complete | Root `ProviderScope` added |
| GoRouter shell | 1 | Complete | Five primary destinations with adaptive shell |
| Theme system | 1 | Complete | Centralized light and dark Material 3 themes |
| Reusable UI states | 1 | Complete | Loading, empty, and error foundation widgets |
| Logging and error boundary | 1 | Complete | Structured logger, route errors, and startup recovery |

## Persistence

| Feature | Phase | Status | Notes |
|---|---:|---|---|
| Drift database | 2 | Complete | Schema version 7 with settings metadata, productivity-core, planner, Spaces, and template metadata tables |
| Migration strategy implementation | 2 | Complete | Schema snapshots and migration harness through version 7 |
| UUID service | 2 | Complete | Replaceable UUID v4 service |
| Typed settings | 2 | Complete | Drift-backed typed settings repository |
| Repository contracts | 2 | Complete | Settings repository and persistence failure boundary |
| Backup-ready serialization | 2 | Complete | Backup envelope contract for Phase 2 settings payload |
| Database tests | 2 | Complete | Database, repository, provider, startup, and contract tests |

## Productivity core

| Feature | Phase | Status |
|---|---:|---|
| Areas | 3 | Complete |
| Goals and hierarchy | 3 | Complete |
| Projects | 3 | Complete |
| Milestones | 3 | Complete |
| Tasks and subtasks | 3 | Complete |
| Tags and relationships | 3 | Complete |
| Notes | 3 | Complete |
| Productivity-core edit, restore, and relationship polish | 3 | Complete |

## Planner

| Feature | Phase | Status |
|---|---:|---|
| Day view | 4 | Complete |
| Week view | 4 | Complete |
| Month view | 4 | Complete |
| Agenda | 4 | Complete |
| Events and meetings | 4 | Complete |
| Time blocks | 4 | Complete |
| Recurrence | 4 | Complete |
| Reminders | 4 | Complete |
| Focus sessions | 4 | Complete |
| Free-time detection | 4 | Complete |
| Planned vs actual time | 4 | Complete |

## Spaces engine

| Feature | Phase | Status |
|---|---:|---|
| Space definitions | 5 | Complete |
| Record types | 5 | Complete |
| Custom fields | 5 | Complete |
| Editable statuses | 5 | Complete |
| Custom records | 5 | Complete |
| Relationships | 5 | Complete |
| Saved filters | 5 | Complete |
| Saved views contract | 5 | Complete |
| List view | 5 | Complete |
| Table view | 5 | Complete |
| Board view | 5 | Complete |
| Calendar view | 5 | Not started |
| Card view | 5 | Complete |
| Template installer/uninstaller | 6 | Complete |

## Templates

| Template | Phase | Status |
|---|---:|---|
| Template infrastructure | 6 | Complete |
| Freelancing CRM | 6 | Complete |
| Finance | 6 | Complete |
| Opportunities | 6 | Complete |
| Learning | 6 | Complete |
| Competitive programming | 6 | Complete |
| Machine learning | 6 | Complete |
| University | 6 | Complete |
| Fitness | 6 | Complete |
| Reading | 6 | Complete |
| Content creation | 6 | Complete |

## Notifications and automations

| Feature | Phase | Status |
|---|---:|---|
| Local notifications | 7 | Planned |
| Reminder scheduling | 7 | Not started |
| Background jobs | 7 | Not started |
| Notification inbox | 7 | Not started |
| Snooze | 7 | Not started |
| Quiet hours | 7 | Not started |
| Trigger-condition-action foundation | 7 | Not started |

## Analytics

| Feature | Phase | Status |
|---|---:|---|
| Generic metric definitions | 8 | Not started |
| Date/Area/Space filters | 8 | Not started |
| Configurable dashboards | 8 | Not started |
| Charts | 8 | Not started |
| Insight cards | 8 | Not started |

## AI

| Feature | Phase | Status |
|---|---:|---|
| AI service abstraction | 9 | Not started |
| Mock AI | 9 | Not started |
| Tool registry | 9 | Not started |
| Structured action preview | 9 | Not started |
| Validation and confirmation | 9 | Not started |
| Action history | 9 | Not started |
| Undo | 9 | Not started |
| Real AI provider | 11 | Deferred |

## Backup, security, and polish

| Feature | Phase | Status |
|---|---:|---|
| JSON backup/restore | 10 | Not started |
| CSV export | 10 | Not started |
| Biometric lock | 10 | Not started |
| Diagnostics | 10 | Not started |
| Accessibility audit | 10 | Not started |
| Performance audit | 10 | Not started |
| Stable debug APK | 10 | Not started |
| Cloud synchronization | 11 | Deferred |
