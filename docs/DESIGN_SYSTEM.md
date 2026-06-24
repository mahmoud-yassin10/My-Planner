# Momentum OS Design System

## 1. Design direction

Momentum OS should feel calm, precise, modern, and information-dense without becoming visually noisy.

The interface should prioritize:

- Clear hierarchy
- Fast capture
- Predictable interaction
- Legible planning views
- Configurability
- Accessible feedback
- Consistent states

Use Material 3 as the foundation, customized through centralized theme tokens.

## 2. Theme architecture

The theme layer will provide:

- Light theme
- Dark theme
- System theme mode
- Configurable accent seed
- Semantic colors
- Typography scale
- Spacing and radius tokens
- Component themes
- Chart palette
- Elevation and surface hierarchy

Feature widgets must consume theme tokens rather than hard-coded colors or text styles.

## 3. Color roles

Use semantic roles rather than feature-specific hard-coded colors:

- Primary
- Secondary
- Tertiary
- Surface
- Surface container levels
- Outline
- Success
- Warning
- Error
- Info
- Disabled

User-selected Area, Goal, Space, tag, and status colors are data. Components must preserve contrast when rendering them.

## 4. Typography

Base typography should use Material 3 roles:

- Display
- Headline
- Title
- Body
- Label

Guidelines:

- Titles describe location or entity.
- Body text carries content.
- Labels identify controls and metadata.
- Numeric planning data uses aligned, readable formatting.
- Respect system text scaling.
- Avoid truncating critical dates, times, amounts, or status labels without an accessible alternative.

## 5. Spacing

Use a centralized spacing scale based primarily on 4 logical pixels:

```text
4, 8, 12, 16, 20, 24, 32, 40, 48
```

Default screen horizontal padding should usually be 16 on phones, with adaptive expansion on larger layouts.

## 6. Shape and elevation

Use a small centralized radius set, for example:

- Small: 8
- Medium: 12
- Large: 16
- Extra large: 24

Use elevation sparingly. Surface tint, borders, and spacing should establish hierarchy before shadows.

## 7. Core components

Planned reusable components:

- App scaffold and adaptive shell
- Primary and secondary buttons
- Icon buttons
- Input fields
- Search field
- Filter chips
- Status chips
- Priority indicator
- Entity cards
- Dashboard cards
- Empty-state panel
- Error-state panel
- Loading skeleton/progress
- Confirmation dialog
- Undo snackbar
- Date/time selector
- Entity picker
- Quick Add sheet
- Section header
- Metric card
- Timeline item
- Calendar/time-block item

## 8. Required interface states

Every data-driven screen should consider:

- Initial loading
- Refreshing
- Empty
- Content
- Partial content
- Validation error
- Recoverable error
- Blocking error
- Offline/local-only status where relevant
- Disabled action
- Destructive confirmation
- Undo success/failure

Do not communicate state through color alone.

## 9. Form behavior

- Labels remain visible when useful.
- Required fields are clearly identified.
- Validation appears near the affected field.
- Forms preserve entered data after recoverable failures.
- Destructive navigation with unsaved edits requests confirmation.
- Date and time behavior respects locale and user preferences.
- Defaults remain configurable and never encode personal assumptions.

## 10. Accessibility

Minimum requirements:

- Semantic labels for icon-only controls
- Logical focus order
- Keyboard navigation where platform support applies
- Sufficient color contrast
- Touch targets near or above 48 logical pixels
- Support for text scaling
- Clear selected/focused/error states
- Screen-reader-friendly status and progress descriptions
- Reduced motion consideration for non-essential animation

## 11. Motion

Motion should communicate spatial or state change.

- Keep durations brief and consistent.
- Avoid ornamental animation in dense planning workflows.
- Respect reduced-motion settings where available.
- Never delay critical actions for animation.

## 12. Responsive behavior

Initial target is Android phone, but layout decisions should not prevent later tablets, desktop, or web.

Planned adaptive behavior:

- Bottom navigation on compact width
- Navigation rail on wider layouts
- Single-pane detail navigation on phones
- Optional list-detail layouts on larger screens
- Constrained content width for forms and reading views

## 13. Planner-specific visuals

- Scheduled blocks show time and duration clearly.
- Conflicts use semantic warning treatment plus text/icon indication.
- Completed tasks remain readable but visually de-emphasized.
- Overdue state is distinct from critical priority.
- Free-time windows must not be confused with scheduled events.
- Drag targets and selected dates have visible focus/selection states.

## 14. Data visualization

Charts must:

- Use semantic labels and legends
- Support accessible summaries
- Avoid misleading truncated axes
- Handle empty and insufficient data
- Use user filters visibly
- Avoid permanent mapping to one personal activity or template
