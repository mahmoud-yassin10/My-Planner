# Momentum OS Product Specification

## 1. Product identity

**Name:** Momentum OS  
**Initial platform:** Flutter application targeting Android  
**Operating model:** Local-first personal planner and operating system  
**Future compatibility:** iOS, web, desktop, cloud synchronization, and multiple users

Momentum OS coordinates planning and execution across:

- Areas of life
- Goals
- Projects and milestones
- Tasks and subtasks
- Calendar events and meetings
- Focus sessions
- Notes and linked knowledge
- Configurable Spaces
- Finances
- Opportunities
- Clients and sales pipelines
- Learning
- Reminders and automations
- Analytics
- AI-assisted planning and actions

## 2. Product vision

Momentum OS should help a user convert long-term direction into concrete, scheduled, measurable action while preserving context across work, learning, finances, relationships, and personal responsibilities.

The product is not a fixed collection of modules built around one user's current life. It is a configurable system composed of stable core concepts and optional templates.

## 3. Product principles

### 3.1 Generic and configurable

Current activities, employers, universities, currencies, schedules, CRM stages, courses, and targets must not be permanently encoded in the app.

They may exist as:

- User-created data
- Optional example data
- Editable templates
- Configurable statuses
- Custom fields
- User-controlled dashboard widgets

### 3.2 Local-first

Core workflows must remain available without internet access. The local database is authoritative in initial releases.

### 3.3 Modular

Features should be independently testable and replaceable without weakening core boundaries.

### 3.4 Safe automation

Automations and AI actions must be transparent, previewable where appropriate, validated, logged, and undoable when safe.

### 3.5 Future synchronization readiness

Identifiers, timestamps, deletion behavior, version metadata, and repository boundaries must permit later cloud synchronization without forcing a rewrite of domain features.

## 4. Primary user outcomes

A user should be able to:

1. Define ongoing Areas.
2. Create measurable goals with time horizons and reviews.
3. Organize finite projects and milestones under goals.
4. Capture, plan, schedule, complete, and review tasks.
5. Manage events and meetings beside tasks.
6. Start focus sessions and compare planned versus actual effort.
7. Build custom Spaces for domain-specific records.
8. Install, edit, and remove optional templates.
9. Link notes to relevant work and records.
10. Receive reminders and run controlled automations.
11. Understand progress through configurable analytics.
12. Ask an AI copilot for plans and structured proposed actions.
13. Back up, restore, export, and secure local data.

## 5. Core productivity hierarchy

```text
Area → Goal → Project → Milestone → Task → Focus Session → Result
```

Relationships may be optional where real workflows require flexibility. For example, an inbox task may exist before it is assigned to an Area or Project.

## 6. Core entities

### 6.1 Area

An ongoing part of life or responsibility.

Required capabilities:

- Create, edit, archive, restore, reorder
- Assign icon and color
- Show linked goals, projects, tasks, events, notes, and metrics

### 6.2 Goal

A desired measurable outcome that may contain child goals.

Supported time horizons:

- Life direction
- Five-year
- Yearly
- Quarterly
- Monthly
- Weekly
- Daily
- Custom

Supported measurement types:

- Manual percentage
- Numeric
- Currency
- Time
- Task completion
- Milestones
- Habit consistency
- Custom

Supported statuses:

- Draft
- Active
- Paused
- Completed
- Archived

### 6.3 Project

A finite body of work linked optionally to an Area and Goal.

Supported lifecycle:

- Planned
- Active
- On hold
- Completed
- Cancelled
- Archived

### 6.4 Milestone

A dated or ordered checkpoint belonging to a Goal or Project.

### 6.5 Task

A schedulable action with optional hierarchy and context.

Supported statuses:

- Inbox
- Planned
- In progress
- Waiting
- Completed
- Postponed
- Cancelled

Priority:

- Low
- Medium
- High
- Critical

Energy requirement:

- Low energy
- Normal
- Deep work

Tasks support:

- Parent-child relationships
- Dependencies
- Estimates and actual duration
- Due and scheduled times
- Recurrence
- Reminders
- Tags
- Linked entities
- Auto-reschedule eligibility
- Completion metadata
- Archive and safe deletion

### 6.6 Event or meeting

A calendar item with time, participants, location/link, preparation, notes, outcome, and follow-up.

### 6.7 Focus session

A measured work session connected optionally to a Task and Area.

## 7. Primary navigation

Five persistent destinations:

1. Home
2. Planner
3. Spaces
4. Goals
5. Insights

Global actions:

- Quick Add
- AI Copilot
- Global Search
- Notification Inbox
- Profile and Settings

## 8. Home dashboard

The dashboard is configurable rather than fixed.

Possible widgets:

- Greeting and date
- Next event
- Top priorities
- Due-today tasks
- Overdue tasks
- Follow-ups
- Free-time windows
- Workload
- Active-goal progress
- Focus time
- Finance snapshot
- Space metrics
- AI daily suggestion
- Morning plan
- Evening review

Users can reorder, hide, restore, and configure widgets.

## 9. Planner

Views:

- Day
- Week
- Month
- Agenda
- Upcoming
- Overdue
- Unscheduled
- Recurring
- Waiting
- Completed
- Low-energy
- Deep-work

Core capabilities:

- Create and update tasks and events
- Schedule and reschedule
- Detect conflicts
- Show free-time windows
- Bulk actions
- Search, filter, and sort
- Recurrence and reminders
- Focus sessions
- Estimated versus actual duration
- Links to Areas, Goals, Projects, and records

## 10. Configurable Spaces engine

A Space is a user-configurable database-like workspace composed of:

- Space definition
- Record types
- Custom fields
- Status definitions
- Views
- Relationships
- Saved filters
- Forms
- Analytics
- Automations

Custom field types initially planned:

- Short text
- Long text
- Integer
- Decimal
- Currency
- Date
- Date and time
- Time
- Checkbox
- Percentage
- Dropdown
- Multi-select
- Phone
- Email
- URL
- Rating
- File reference
- Relationship
- Formula
- Progress
- Status
- User-defined JSON when necessary

Views initially planned:

- List
- Table
- Board
- Calendar
- Timeline
- Cards
- Chart

Users can create, rename, duplicate, reorder, archive, and delete Spaces.

## 11. Optional templates

Templates install configurations, not permanent product assumptions.

Initial planned templates:

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

Templates must be editable and removable. Uninstallation must offer record preservation, archive, export, or deletion without affecting unrelated data.

## 12. Notes and knowledge

Notes support:

- Markdown or structured rich text
- Tags
- Pinning
- Search
- Templates
- Attachments
- Backlinks
- Links to core entities and Space records
- AI summary
- AI task and deadline extraction

The objective is a linked knowledge layer, not a complete Notion replacement.

## 13. AI copilot

The AI layer is provider-independent.

Initial contracts:

- `AiService`
- `MockAiService`
- `RemoteAiService`
- `AiToolRegistry`
- `AiActionValidator`
- `AiActionPreview`
- `AiActionRepository`
- `UndoCoordinator`

Every write flow:

1. AI proposes structured changes.
2. User reviews a preview.
3. User edits, rejects, or approves.
4. App validates the proposal.
5. Approved changes are applied through domain/repository boundaries.
6. The action is logged.
7. Undo is available where safe.

No provider secret may be embedded in the client.

## 14. Notifications and automations

Notification categories:

- Task
- Meeting
- Follow-up
- Payment due
- Goal review
- Morning plan
- Evening review
- Weekly review
- Learning revision
- Custom

Automation model:

```text
Trigger → Conditions → Actions
```

The first implementation may expose only a limited rule set, while the data model remains extensible.

## 15. Analytics

Core metrics:

- Tasks created and completed
- Completion and overdue rates
- Planned versus actual time
- Focus time
- Area balance
- Goal and project progress
- Financial trends
- Space funnels
- Learning consistency
- Record status distributions

Filters:

- Date range
- Areas
- Spaces
- Goals
- Projects
- Tags
- Status
- Metric
- Chart type

## 16. Settings

Planned settings include:

- Profile
- Theme and accent
- Locale
- Currency
- Date and time formats
- First day of week
- Notifications and quiet hours
- AI provider and privacy
- Spaces and templates
- Backup, restore, and export
- Security and biometric lock
- Diagnostics and logs
- Database and app version
- Demo-data reset

## 17. Non-functional requirements

- Core workflows function offline.
- UI remains responsive with realistic local datasets.
- Persistent writes are transactional where consistency requires it.
- Errors are visible and actionable.
- Destructive actions request confirmation and offer undo where feasible.
- Accessibility labels and minimum touch targets are used.
- State transitions are deterministic and testable.
- Migrations preserve existing user data.
- No secret is stored in source control.
- Optional modules can be removed without breaking the shell.

## 18. Initial exclusions

Not part of initial local phases:

- Supabase
- PowerSync
- Authentication
- Multi-user collaboration
- Cross-device synchronization
- Real AI provider integration
- Reading private WhatsApp messages
- Full WhatsApp Business Platform integration
- Google Calendar synchronization
- Full Notion-style document editor
