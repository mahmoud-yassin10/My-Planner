# Momentum OS Data Model

## 1. Data-model goals

The data model must:

- Represent stable core planning concepts relationally
- Support configurable Spaces without creating one table per template
- Preserve data through migrations
- Use synchronization-ready identifiers and metadata
- Permit archive, restore, export, and controlled deletion
- Support reliable analytics and search
- Avoid hard-coded personal domains

## 2. Common persistent fields

Most persistent tables should include:

- `id`: UUID v4 string
- `createdAt`: UTC timestamp
- `updatedAt`: UTC timestamp
- `archivedAt`: nullable UTC timestamp where archive is supported
- `deletedAt`: nullable UTC timestamp only where soft deletion is justified
- `syncStatus`: optional/reserved synchronization state
- `version`: optional integer for future conflict handling

Rules:

- IDs are generated before insertion.
- `createdAt` is immutable after insert.
- `updatedAt` changes on meaningful mutations.
- Archive is reversible.
- Delete semantics are documented per entity.
- Foreign-key behavior is explicit.
- Local timestamps are converted to UTC for storage.

Phase 2 establishes these conventions before productivity tables are added. Phase 3+ tables must use UUID v4 string identifiers generated before insert, UTC timestamps, immutable `createdAt`, meaningful `updatedAt` changes, documented archive/delete semantics, and repository-level failure translation.

Phase 3A implements Areas, Goals, Projects, and Milestones in schema version 2. Archive is represented by nullable `archivedAt` and is reversible. Delete is a permanent repository operation; SQLite foreign keys reject deletion while dependent hierarchy records still reference the row. Repository methods translate raw persistence failures into safe `PersistenceFailure` types.

Phase 4A implements Planner events and time blocks in schema version 4. Archive is represented by nullable `archivedAt` and is reversible. Delete is a permanent repository operation; SQLite foreign keys reject deletion when linked tasks require protection. Recurrence and reminder fields are inert contracts only until Phase 4B and Phase 7 add the relevant behavior.

Phase 4B implements focus sessions in schema version 5. Recurrence expansion is local and deterministic for supported event rules. Reminder policies are validated contracts only; platform notification scheduling remains deferred to Phase 7.

Phase 5A implements the initial configurable Spaces foundation in schema version 6. Space definitions, record types, field definitions, status definitions, records, record links, saved filters, and saved views are persisted behind `SpacesRepository`. Record field values are stored as a JSON object in `space_records.fieldsJson` for this foundation slice; repository validation enforces supported field types before writes. Templates, search indexing, analytics, backup files, restore flows, and cloud synchronization remain deferred.

Phase 5B keeps schema version 6 and adds repository lifecycle behavior plus saved-view rendering contracts. Space definitions, record types, fields, statuses, and records use reversible `archivedAt`; all Phase 5A entities have explicit permanent delete operations with foreign-key protection. Saved view `configJson` is validated as a JSON object with supported keys `recordTypeId`, `visibleFieldKeys`, `groupByStatus`, and `sortFieldKey`.

Phase 6A implements template installation metadata in schema version 7. Template definitions are injectable descriptors; installing a template stores metadata only and does not create Areas, Goals, Projects, Tasks, Notes, Events, Spaces, or Space records.

Phase 6B adds bundled descriptor definitions for the planned template categories without a schema change. Template descriptors remain metadata and configuration contracts only; installing one still stores template-installation metadata without creating user records or example data.

Phase 7A adds notification intent and permission contracts without a schema change. Notification inbox rows, reminder rules, platform notification identifiers, snooze state, quiet hours, and automation runs remain planned model sections until later Phase 7 tasks.

## 3. Core productivity tables

### `areas`

- `id`
- `name`
- `description`
- `iconKey`
- `colorValue`
- `status`
- `sortOrder`
- common timestamps

### `goals`

- `id`
- `title`
- `description`
- `areaId`
- `parentGoalId`
- `goalType`
- `timeHorizon`
- `measurementType`
- `targetValue`
- `currentValue`
- `unit`
- `startAt`
- `deadlineAt`
- `priority`
- `status`
- `motivation`
- `reviewFrequency`
- `lastReviewAt`
- `nextReviewAt`
- `notes`
- `customFieldsJson` only for limited goal extensions
- common timestamps

### `projects`

- `id`
- `title`
- `description`
- `areaId`
- `goalId`
- `status`
- `startAt`
- `deadlineAt`
- `progress`
- `notes`
- `customFieldsJson`
- common timestamps

### `milestones`

- `id`
- `title`
- `description`
- `goalId`
- `projectId`
- `dueAt`
- `status`
- `completedAt`
- `sortOrder`
- `notes`
- common timestamps

### `tasks`

- `id`
- `title`
- `description`
- `areaId`
- `goalId`
- `projectId`
- `milestoneId`
- `parentTaskId`
- `status`
- `priority`
- `energyRequirement`
- `estimatedDurationMinutes`
- `actualDurationMinutes`
- `dueAt`
- `scheduledStartAt`
- `scheduledEndAt`
- `preferredTimeOfDay`
- `recurrenceRuleId`
- `autoRescheduleEligible`
- `completedAt`
- `notes`
- common timestamps

Subtasks initially use the same `tasks` table through `parentTaskId` unless later evidence requires a separate table.

### `task_dependencies`

- `taskId`
- `dependsOnTaskId`
- `dependencyType`

Composite uniqueness prevents duplicate edges. Cycles must be rejected at the domain layer.

### `planner_events`

- `id`
- `title`
- `description`
- `kind`
- `startsAt`
- `endsAt`
- `isAllDay`
- `location`
- `meetingUrl`
- `linkedTaskId`
- `recurrenceRule`
- `reminderPolicy`
- common timestamps

Event participants, preparation notes, meeting outcomes, and follow-up tasks remain planned fields for later Planner work.

### `time_blocks`

- `id`
- `title`
- `kind`
- `startsAt`
- `endsAt`
- `linkedTaskId`
- `notes`
- common timestamps

### `focus_sessions`

- `id`
- `taskId`
- `plannedDurationMinutes`
- `actualDurationMinutes`
- `startedAt`
- `endedAt`
- `sessionType`
- `status`
- `notes`
- `reflection`
- `interruptionCount`
- common timestamps

## 4. Notes, tags, and relationships

### `notes`

- `id`
- `title`
- `content`
- `contentFormat`
- `isPinned`
- common timestamps

### `tags`

- `id`
- `name`
- `colorValue`
- common timestamps

### `entity_tags`

- `id`
- `entityType`
- `entityId`
- `tagId`

### `entity_links`

Generic links between supported entities:

- `id`
- `sourceType`
- `sourceId`
- `targetType`
- `targetId`
- `relationshipType`
- common timestamps

Generic entity references require domain validation and cleanup tests because SQLite cannot enforce polymorphic foreign keys directly.

## 5. Spaces engine

### `spaces`

- `id`
- `name`
- `description`
- `iconKey`
- `colorValue`
- `sortOrder`
- common timestamps

### `space_record_types`

- `id`
- `spaceId`
- `name`
- `description`
- `sortOrder`
- common timestamps

### `space_fields`

- `id`
- `recordTypeId`
- `name`
- `fieldKey`
- `fieldType`
- `isRequired`
- `sortOrder`
- `optionsJson`
- common timestamps

### `space_statuses`

- `id`
- `recordTypeId`
- `name`
- `colorValue`
- `sortOrder`
- `isDefault`
- common timestamps

### `space_records`

- `id`
- `recordTypeId`
- `title`
- `statusId`
- `fieldsJson`
- common timestamps

`fieldsJson` must be a JSON object. Supported Phase 5A field types are text, number, checkbox, date, URL, and select. Repository validation enforces type consistency before insert.

### `space_record_links`

- `id`
- `sourceRecordId`
- `targetType`
- `targetId`
- `relationshipType`
- `createdAt`

### `space_saved_views`

- `id`
- `spaceId`
- `name`
- `viewType`
- `configJson`
- `createdAt`
- `updatedAt`

### `space_saved_filters`

- `id`
- `name`
- `spaceId`
- `filterJson`
- `createdAt`
- `updatedAt`

## 6. Templates

### `template_installations`

- `id`
- `templateKey`
- `templateVersion`
- `installedAt`
- `updatedAt`
- `configurationSnapshotJson`
- `status`
- `uninstallChoice`
- `uninstalledAt`

Template definitions may be bundled application assets. Installed configuration becomes user-editable data.

Uninstallation must explicitly choose:

- Preserve records and detach template metadata
- Archive records
- Export then delete
- Delete records after confirmation

## 7. Finance and stable extension tables

Stable concepts that require robust relational querying may use dedicated tables when implementation reaches the relevant phase:

- `accounts`
- `transactions`
- `budgets`
- `financial_goals`
- `invoices`

Currency is always stored as data and user configuration. No default currency assumption belongs in the schema.

## 8. Reminders and automations

### `reminder_rules`

- `id`
- `ownerType`
- `ownerId`
- `triggerAt`
- `relativeOffsetMinutes`
- `recurrenceRule`
- `channel`
- `isEnabled`
- common timestamps

### `notifications`

- `id`
- `type`
- `title`
- `body`
- `scheduledAt`
- `deliveredAt`
- `readAt`
- `ownerType`
- `ownerId`
- `platformNotificationId`
- common timestamps

### `automation_rules`

- `id`
- `name`
- `triggerType`
- `triggerConfigJson`
- `conditionsJson`
- `actionsJson`
- `isEnabled`
- common timestamps

### `automation_runs`

- `id`
- `automationRuleId`
- `startedAt`
- `completedAt`
- `status`
- `resultJson`
- `errorSummary`

Automation runs must be idempotent where a retry could occur.

## 9. AI data

### `ai_conversations`

- `id`
- `title`
- common timestamps

### `ai_messages`

- `id`
- `conversationId`
- `role`
- `content`
- `structuredContentJson`
- common timestamps

### `ai_actions`

- `id`
- `conversationId`
- `toolKey`
- `proposalJson`
- `approvedPayloadJson`
- `status`
- `validationResultJson`
- `appliedAt`
- `undoneAt`
- common timestamps

AI action records support audit and safe undo. They must not contain provider secrets.

## 10. Application configuration

### `app_settings`

Use a typed repository rather than arbitrary key-value access throughout features.

Potential keys:

- locale
- date/time formats
- first day of week
- theme
- accent
- base currency
- quiet hours
- notification defaults
- dashboard configuration
- AI privacy settings

Phase 2 implements a small typed subset:

- `themeMode`
- `accentColorValue`
- `localeTag`
- `firstDayOfWeek`
- `timeFormat`

The storage table is internally flexible, but callers use `SettingsRepository` and `AppSettingsPreferences`.

### `schema_metadata`

Tracks:

- database version
- application migration markers
- optional seed/template versions

Phase 2 stores schema metadata for database readiness and future migration checks. It does not install templates or seed records.

## 11. Indexing plan

Add indexes based on actual query paths, including likely:

- Tasks by status and due/scheduled time
- Tasks by Area, Goal, Project, or Milestone
- Events by start/end time
- Goals by status and review date
- Records by type/status
- Reminder rules by next trigger
- Notifications by read state and schedule
- Notes and records for search indexing

Index definitions are finalized with query implementation and tested against realistic data.

## 12. Migration strategy

- Increment the Drift schema version for every persistent schema change.
- Implement explicit forward migrations.
- Test creation from empty and upgrade from every supported prior version.
- Back up critical user data before destructive migration operations.
- Do not edit released migration history silently.
- Record migration-impacting decisions in `docs/DECISIONS.md`.
- Generate and inspect schema snapshots when Drift support is added.

Phase 2 procedure for future schema version 2:

1. Update Drift tables in `lib/core/database/app_database.dart`.
2. Increment `schemaVersion`.
3. Add explicit migration logic from version 1 to version 2.
4. Run `dart run build_runner build --delete-conflicting-outputs`.
5. Run `dart run drift_dev make-migrations`.
6. Add migration tests using the schema snapshot harness.
7. Run formatting, analysis, tests, debug APK build, and `git diff --check`.

Schema version 2 is now checked in with `drift_schemas/app_database/drift_schema_v2.json`, generated `app_database.steps.dart`, and generated migration verification tests.

Schema version 3 adds Tasks/subtasks, Tags, entity-tag relationships, Notes, and note links. Subtasks use `tasks.parentTaskId`; note and tag links use generic entity references validated at the repository boundary where SQLite cannot enforce polymorphic targets directly.

Schema version 4 adds Planner events and time blocks. `planner_events.linkedTaskId` and `time_blocks.linkedTaskId` reference `tasks.id`. Recurrence and reminder text fields are contract placeholders and do not schedule platform notifications.

Schema version 5 adds focus sessions. `focus_sessions.taskId` references `tasks.id`; focus sessions store planned and actual duration for Phase 4 Planner behavior without adding analytics dashboards.

Schema version 6 adds the Phase 5A Spaces foundation tables. `space_record_types.spaceId`, `space_saved_filters.spaceId`, and `space_saved_views.spaceId` reference `spaces.id`; field, status, and record rows reference `space_record_types.id`; record links reference `space_records.id` for their source record and store generic target references for supported core entities. Repository validation handles dynamic field-value typing where SQLite cannot model configurable fields directly in Phase 5A.

Schema version 7 adds `template_installations` for removable template metadata. The table records installed template key/version, a configuration snapshot, status, optional uninstall choice, and uninstall timestamp. It intentionally does not store template-created records in Phase 6A.

## 13. Backup and export

JSON backup must include:

- Schema/app version
- Export timestamp
- Stable IDs
- Core entities
- Space definitions and records
- Settings appropriate for backup
- Template installation metadata
- Relationship integrity information

Secrets and secure-storage values are excluded unless a separately designed encrypted flow is approved.

CSV export is feature-specific and must retain field names and stable references where practical.

Phase 2 adds only a backup envelope serialization contract for settings payloads. It does not add file backup, file restore, CSV export, encryption, or filesystem workflows.
