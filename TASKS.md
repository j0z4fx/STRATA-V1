# Strata Task System

Protocol:
- When the user says `Proceed with the next task`, read this file and select only the first task.
- Implement only that task.
- Stop immediately after completing that task.
- Do not skip tasks.
- Do not combine tasks.
- Do not refactor unrelated systems.
- Do not pre-build future systems.
- After implementation, wait for feedback.
- When the user says `Task complete`, remove that task from this file and append it to `COMPLETED_TASKS.md`.

Architecture Rules:
- Toolkit = infrastructure only
- Veil = protection authority (UI + runtime)
- Axis = UI construction only
- Strata = loader/orchestration only
- No module bypasses Veil for protected behavior
- Runtime uses `loadstring` only
- Runtime uses GitHub raw only
- No `require(...)`
- Axis must not parent directly to `CoreGui`, `PlayerGui`, or `gethui`
- Axis must not call executor APIs directly
- All floating and overlay UI must go through Veil

Dev Loader Rules:
- Every new control must be demoed
- Do not remove existing examples
- Keep layout clean

## Task 1 — Finalize corner radius ownership system

Description:
Fix and lock the corner radius system so no future UI elements can break it.

Requirements:
- Window owns full 14px radius
- Titlebar owns only top-left and top-right
- Sidebar owns only bottom-left
- Bottom-right must always remain visible
- No child should mask parent radius

Constraints:
- Do not change layout
- Do not change colors

Acceptance Criteria:
- All 4 corners render correctly
- No regressions after resizing, tabs, or content updates

## Task 2 — Global spacing system

Description:
Establish a consistent vertical spacing system to replace groupboxes.

Requirements:
- Define:
  - element spacing
  - section spacing
  - header spacing
- Apply to:
  - labels
  - toggles
  - sliders
  - section headers
- Section headers must create clear visual grouping

Constraints:
- Do not add containers/groupboxes
- Do not change control sizes

Acceptance Criteria:
- UI reads clearly without groupboxes
- Spacing is consistent across all columns

## Task 3 — Selection system foundation (Dropdown base)

Description:
Build a reusable selection system starting with single-select dropdown.

Requirements:
- Label-based control (not full width)
- Selected value on right
- Opens floating panel
- Panel must not cover the control
- Uses Veil for panel
- Click outside closes
- Supports:
  - `Set(value)`
  - `GetValue()`
  - `OnChanged()`

Constraints:
- No multi-select yet
- No search yet

Acceptance Criteria:
- Dropdown opens cleanly
- Control remains visible
- Selection updates correctly
- No clipping issues

## Task 4 — Dropdown positioning engine

Description:
Make dropdown placement intelligent and robust.

Requirements:
- Prefer opening downward
- If insufficient space, open upward
- Clamp to screen edges
- Maintain gap from control
- Prevent offscreen rendering

Constraints:
- Do not change dropdown visuals

Acceptance Criteria:
- Dropdown never renders offscreen
- Works near top and bottom edges

## Task 5 — Multi-select dropdown

Description:
Extend selection system to support multiple selections.

Requirements:
- Multiple values selectable
- Visual check indicators
- Maintain list of selected values
- Callback returns table of values

Constraints:
- Reuse dropdown base
- Do not duplicate logic

Acceptance Criteria:
- Multiple items selectable
- State persists correctly

## Task 6 — Searchable dropdown

Description:
Add search capability to dropdown.

Requirements:
- Input field at top
- Filters options live
- Case-insensitive
- Smooth update

Constraints:
- Must integrate with existing dropdown system

Acceptance Criteria:
- Filtering works correctly
- No lag or visual breaking

## Task 7 — Slider refinement pass

Description:
Improve sliders to feel premium.

Requirements:
- Better smoothing and lerp
- Improved thumb behavior
- Subtle hover and drag states
- Better value readability

Constraints:
- Do not change API
- Do not break existing sliders

Acceptance Criteria:
- Drag feels smooth and controlled
- Visuals feel consistent with UI

## Task 8 — Toggle refinement pass

Description:
Polish toggles for premium feel.

Requirements:
- Hover states
- Press states
- Micro animations
- Better tooltip timing consistency

Constraints:
- Do not change toggle layout

Acceptance Criteria:
- Toggle interaction feels responsive and smooth

## Task 9 — Input field control

Description:
Add text input control.

Requirements:
- Label-based layout
- Focus state
- Input validation safety
- Clean styling

Acceptance Criteria:
- Text input works reliably
- Matches UI style

## Task 10 — Button control

Description:
Add button system.

Requirements:
- Primary button
- Secondary button
- Hover and press states

Acceptance Criteria:
- Buttons feel responsive and consistent

## Task 11 — Notification/toast polish

Description:
Refine notification system.

Requirements:
- Better stacking
- Better spacing
- Improved animation timing

Acceptance Criteria:
- Notifications feel smooth and non-intrusive

## Task 12 — State persistence system

Description:
Persist UI state.

Requirements:
- Save:
  - toggles
  - sliders
  - pickers
- Load on startup

Constraints:
- Must not break loader

Acceptance Criteria:
- Values persist correctly

## Task 13 — Settings integration

Description:
Connect UI to actual system behavior.

Requirements:
- Hook controls into real state
- Ensure clean update flow

Acceptance Criteria:
- Changes reflect immediately and persist
