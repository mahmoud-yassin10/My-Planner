# Momentum OS Navigation

## 1. Navigation principles

Navigation must be:

- Predictable
- Deep-link compatible
- State-restoring where practical
- Adaptive across screen sizes
- Independent of optional templates
- Centralized through GoRouter

## 2. Primary destinations

The compact layout uses five bottom-navigation destinations:

1. Home
2. Planner
3. Spaces
4. Goals
5. Insights

Wider layouts may replace bottom navigation with a navigation rail while preserving the same destinations.

## 3. Global actions

Available from the application shell where context permits:

- Quick Add
- AI Copilot
- Global Search
- Notification Inbox
- Profile and Settings

Quick Add should be the fastest route to capturing a task, event, note, goal, project, or supported record without forcing the user through a long hierarchy.

## 4. Planned routes

```text
/
 /home
 /planner
 /planner/day
 /planner/week
 /planner/month
 /planner/agenda
 /spaces
 /spaces/:spaceId
 /spaces/:spaceId/records/:recordId
 /goals
 /goals/:goalId
 /projects/:projectId
 /tasks/:taskId
 /events/:eventId
 /notes/:noteId
 /insights
 /search
 /notifications
 /settings
 /ai
```

Actual route constants and typed parameters will be centralized during Phase 1.

## 5. Root behavior

The root route `/` should redirect deterministically after app initialization.

Initial expected behavior:

- Successful initialization → `/home`
- Initialization failure → recoverable application error route/screen
- First-run onboarding may be added later through a documented decision

Avoid asynchronous side effects inside route builders.

## 6. Shell navigation

Use a GoRouter shell route for primary destinations.

Requirements:

- Preserve the selected primary destination.
- Retain useful nested navigation state where practical.
- Selecting an already active destination returns to its root or scrolls to top only through deliberate behavior.
- Optional Space configuration never changes the core shell structure.

## 7. Detail navigation

Entity details are addressable routes.

Examples:

- Task detail from Home, Planner, Search, Goal, or Project
- Goal detail from Home, Goals, Insights, or Search
- Space record detail from a Space view, Search, or linked entity

A detail screen must not assume which entry point opened it.

## 8. Back behavior

- Android system back follows the visible navigation stack.
- Modal sheets close before leaving the underlying screen.
- Unsaved forms request confirmation.
- Deep-linked detail screens return to an appropriate app location when no internal history exists.
- Back behavior must not silently discard edits.

## 9. Quick Add navigation

Quick Add is expected to open as a modal sheet or dialog with:

- Recent/default creation types
- Task
- Event
- Note
- Goal
- Project
- Space record when a relevant Space is selected

Creation flows may expand to full-screen forms for complex records.

## 10. Search navigation

Global Search results group supported entity types and navigate to canonical detail routes.

Search must remain functional even when optional templates are removed.

## 11. Notification navigation

A notification stores enough context to route to its owner entity or relevant filtered screen.

Invalid or deleted targets show a safe explanation rather than crashing.

## 12. Deep links

Planned deep links may target:

- Core entity details
- Space records
- Notification destinations
- AI action previews where safe

External deep links must validate identifiers and permissions before navigation.

## 13. Route guards and readiness

Initial local-only app has no authentication guard.

Possible guards:

- Database/bootstrap readiness
- Biometric lock in Phase 10
- Import/restore safety state
- Future authentication

Route guard logic must be testable and should not contain persistence logic.

## 14. Navigation testing

Test:

- Root redirect
- Primary destination selection
- Detail routes with valid and invalid IDs
- Back behavior
- Modal dismissal
- Deep links
- Initialization error route
- Navigation after deletion
- Adaptive shell selection
