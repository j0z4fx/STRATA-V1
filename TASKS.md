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

## Task 14 — Fix layout ordering bug

Description:
UI controls render out of insertion order. Separators added before toggles appear after them. Same issue on Settings tab. Root cause is likely LayoutOrder not assigned at creation time.

Requirements:
- Controls must render in the order they are added via column API
- SectionHeader / separators must appear before the controls that follow them
- Fix applies to all columns and all tabs
- Settings tab column ordering must also be correct

Constraints:
- Do not change any control visuals
- Do not change the column API signatures

Acceptance Criteria:
- Left column: separator appears before first toggle group
- Settings tab: controls appear in the order they are created in DevLoader
- No regressions in other columns

## Task 15 — Checkbox control

Description:
Add a checkbox control. Simpler than toggle — no switch, just a tick box.

Requirements:
- Label on left, checkbox on right
- Checked state shows tick mark or fill
- Hover and press states
- API: `Checked`, `OnChanged(value)`, `Set(bool)`
- Demo in DevLoader

Constraints:
- Do not reuse toggle internals — separate control
- No subtext required (but should not break if added)

Acceptance Criteria:
- Checkbox toggles on click
- State is readable via API
- Visually distinct from toggle

## Task 16 — Radio button control

Description:
Add radio button control supporting both horizontal and vertical orientation.

Requirements:
- Takes a list of options
- Only one selectable at a time
- Orientation: `Horizontal` or `Vertical` (default Vertical)
- Selected option highlighted
- API: `Set(value)`, `GetValue()`, `OnChanged(value)`
- Demo both orientations in DevLoader

Constraints:
- Do not use dropdown internals
- Horizontal layout must not overflow column width

Acceptance Criteria:
- Single selection enforced
- Both orientations render cleanly
- Selection updates via API

## Task 17 — Secure input control

Description:
Password-style text input. Characters masked as bullets (••••••••).

Requirements:
- Identical layout to existing Input control
- Characters display as • (U+2022) while typing
- Actual value stored and returned unmasked
- Focus state same as Input
- Optional validator support
- Demo in DevLoader

Constraints:
- Reuse Input layout code where possible
- Do not expose raw value in TextBox.Text

Acceptance Criteria:
- Typing shows bullets not characters
- Callback receives real value
- Visually indistinguishable from Input except masked text

## Task 18 — Curve editor control

Description:
Bezier curve editor control for things like easing or falloff curves.

Requirements:
- Fixed-size canvas (full column width, square-ish)
- Displays a curve from (0,0) to (1,1)
- Two control point handles, draggable
- Renders curve using line segments
- Output: table of sampled values or raw control point positions
- API: `GetPoints()`, `OnChanged(points)`
- Demo in DevLoader

Constraints:
- Canvas is fixed size — no resize
- No axes labels needed
- Keep visuals minimal and consistent with UI style

Acceptance Criteria:
- Handles draggable
- Curve updates live
- API returns correct point data

## Task 19 — Modal launcher search bar

Description:
Add a search icon to the right side of the titlebar. Clicking it opens a full modal launcher overlay centered on screen (not inside the window).

Requirements:
- Search icon button on titlebar right side (before close/hide buttons if any, or trailing)
- Modal opens centered on screen via Veil overlay surface
- Modal has: search icon, placeholder text "Start typing…", text input
- Live filtering of results as user types (results are hardcoded stubs for now: tab names, control names)
- Top matches shown in a scrollable list below input
- Clicking a result closes the modal (no navigation yet — just closes)
- Press Escape closes modal
- Click outside modal closes modal
- Modal uses Axis visual style (colors, fonts, radius)

Constraints:
- Modal must not be inside the Axis window
- Must go through Veil for the overlay surface
- Do not implement actual navigation yet — that is a future task

Acceptance Criteria:
- Modal opens from titlebar icon
- Typing filters visible entries
- Escape and outside-click both close it
- Visual style matches rest of UI

## Task 20 — Keybinds overlay

Description:
Standalone overlay panel showing a keybind reference table. NOT linked to main menu show/hide. Independent visibility.

Requirements:
- Small panel, dark background, rounded corners
- Two columns: action name (left), key (right)
- Key column shows key name styled differently (muted or badge-like)
- Panel positioned bottom-right of screen (or configurable)
- Toggle visibility via a keybind (e.g. RightAlt or configurable)
- Keybind list is defined programmatically by the script author (not end-user editable in this task)
- Uses Veil for the overlay surface
- Demo in DevLoader with 5–6 example binds

Constraints:
- Not inside Axis window
- Must not interfere with main menu visibility
- No dragging required yet

Acceptance Criteria:
- Panel appears/disappears independently from main menu
- Keybind rows render cleanly with name + key
- No clipping or overflow

## Task 21 — Character viewer panel

Description:
A viewport panel that sits to the right of the Axis window showing a spinning R6 character rig wearing the local player's current appearance. Panel visibility is tab-controlled — it only shows when a specific tab is active (configured per tab).

Research required before implementation:
- Read sUNC docs for: `gethui`, viewport instance access, character cloning behavior
- Read Roblox docs for: `ViewportFrame`, `WorldModel`, `Model:LoadCharacter` equivalent, humanoid description

Requirements:
- Viewport panel appears to the right of the Axis window, vertically aligned with it
- Uses a real R6 rig (Roblox-provided, not custom mesh) with HumanoidDescription applied from local player
- Character spins very slowly on Y-axis (continuous, Heartbeat-driven)
- Panel visibility toggled by tab selection — each tab has a `ShowCharacterViewer = true/false` option
- Panel background matches window background color
- Rounded corners consistent with window
- Must use Veil for the overlay surface
- Panel must reposition if window moves (or use absolute positioning relative to window's AbsolutePosition each frame)

Constraints:
- Do not use a custom mesh rig — use standard R6 humanoid
- Axis must not call executor APIs directly — route through Veil
- Do not show when no tab with `ShowCharacterViewer = true` is active

Acceptance Criteria:
- Viewport shows R6 character with local player appearance
- Character spins slowly and smoothly
- Panel appears/disappears correctly on tab switch
- No performance issues (single Heartbeat connection, not per-frame new objects)

## Task 22 — Custom crosshair system

Description:
A centered screen crosshair with a full customization tab. Crosshair renders independently from the Axis window.

Requirements:
- Crosshair rendered via Veil overlay surface, always centered on screen
- Crosshair shape built from line segments (not a single image)
- Customizable properties (all with live preview):
  - Color (colorpicker)
  - Width (line thickness)
  - Length (arm length)
  - Gap (center gap size)
  - Opacity
  - Dot (center dot toggle + size)
  - Outline (toggle + color)
  - Animation: None / Spin / Pulse (slow idle animations)
- New tab "Crosshair" in Axis window with these controls
- Toggle to show/hide crosshair
- State persists via existing persistence system

Constraints:
- Crosshair must be outside the Axis window
- Must go through Veil for the overlay
- No image assets — geometry only

Acceptance Criteria:
- Crosshair renders centered regardless of window position
- All customization controls update crosshair live
- Spin and Pulse animations work correctly
- Crosshair survives tab switches and window hide/show

## Task 23 — Veil security hardening

Description:
Research and harden Veil's protection mechanisms without hurting usability or user experience.

Research required before implementation:
- Review sUNC executor API surface for detection vectors
- Review common Roblox anti-cheat patterns (script scanning, closure inspection, metamethod hooks)
- Review existing Veil code for gaps

Requirements:
- Audit all Veil public surfaces for potential detection or hook points
- Harden instance creation to prevent external inspection
- Protect Veil's internal state tables from external reads
- Prevent `getgc`-based discovery of Veil closures where possible
- Add metamethod protection to Veil's internal tables (read-lock)
- All hardening must be transparent to Axis — no API changes

Constraints:
- Do not break any existing Axis functionality
- Do not add latency to hot paths (control creation, rendering)
- Hardening must not cause errors in standard Roblox Studio test mode

Acceptance Criteria:
- External scripts cannot read Veil's internal state via `getgc` or `getupvalues`
- Axis API unchanged
- No performance regressions

## Task 24 — Port Security Scanner into Veil

Description:
Integrate the Cobalt security scanner (provided by user) into Veil as a protected internal tool. Scanner detects anti-cheat, obfuscated scripts, and metamethod hooks via GC scanning.

Source code provided: the Cobalt PluginData security scanner (scans `getgc`, checks upvalues, constants, environment, metamethods, suspicious names).

Requirements:
- Port scanner logic into Veil as `Veil.Scanner` or similar internal namespace
- Replace all raw `Instance.new` calls with `Veil.Instance:Create`
- Replace all raw service access with `Veil.Services:Get`
- Remove Cobalt-specific references (`Cobalt.Sonner`, `Cobalt.UI`, etc.) — use Axis notification system instead
- Expose via Axis as a tab or button: "Scan" triggers scan, results appear in a scrollable list inside the window
- "Copy Path" copies script path to clipboard via Veil (route `setclipboard` through Veil)
- "Kill" terminates script threads via `getreg` + `task.cancel` (route through Veil)
- Scanner only runs when explicitly triggered — no passive scanning
- All debug APIs (`getgc`, `getupvalues`, `getconstants`, `getscripts`, `islclosure`, `getrawmetatable`, `getrenv`, `getreg`) accessed via Veil

Constraints:
- Scanner logic must be inside Veil — not directly in Axis
- Axis only calls Veil.Scanner:Run() and receives results
- Do not run scanner on startup
- If debug APIs unavailable, show error notification and abort gracefully

Acceptance Criteria:
- Scan button triggers full GC scan
- Results list shows script name, path, detection reason
- Copy and Kill buttons work
- No raw executor API calls in Axis code

## Task 25 — Insight module (MSESP base)

Description:
Build the Insight module at `C:\Users\vvs\Documents\STRATA-V1\Insight` using the MSESP repository as a reference base. Insight provides ESP/object detection features. Protection is the top priority — everything must route through Veil.

Research required before implementation:
- Read MSESP repo: https://github.com/mstudio45/MSESP
- Understand its ESP rendering, object detection, and configuration architecture

Requirements:
- Insight module exposes: `Insight:Enable()`, `Insight:Disable()`, `Insight:Configure(options)`
- ESP rendering goes through Veil overlay surface
- No raw `Instance.new` in Insight — all via `Veil.Instance:Create`
- All service access via `Veil.Services:Get`
- Object detection uses Veil-proxied workspace/player access
- Veil may need new capabilities added to support Insight — expand Veil if needed
- Insight must be loadable via `loadstring(game:HttpGet(url))()(Toolkit, Veil)`
- Basic features from MSESP: player boxes, name tags, distance labels
- Do not expose Insight internals — protect with Veil metamethod locks

Constraints:
- Insight cannot call executor APIs directly — all through Veil
- Insight cannot parent to CoreGui/PlayerGui/gethui directly
- Do not port MSESP verbatim — use it as architecture reference only

Acceptance Criteria:
- Insight loads and enables without errors
- Basic ESP renders on players
- All rendering goes through Veil surface
- Internal tables are metamethod-protected

## Task 26 — Anti-AFK toggle in settings

Description:
Add anti-AFK functionality as a toggle in the Settings tab.

Research required:
- Check MSESP or referenced repos for existing anti-AFK implementation
- Review sUNC docs for VirtualInputManager or other AFK-prevention APIs

Requirements:
- Toggle labeled "Anti-AFK" in Settings tab
- When enabled: prevents Roblox's idle disconnect (fires virtual input or equivalent on interval)
- When disabled: stops the interval
- Implementation routes through Veil (interval management, input API access)
- State persists via existing persistence system

Constraints:
- Do not use busy loops — use `task.delay` or `task.spawn` with proper cancellation
- Must be cleanable on `Axis:DestroyAll()`

Acceptance Criteria:
- Toggle enables/disables anti-AFK
- No disconnect while enabled during extended idle
- Cleans up properly when UI is destroyed

## Task 27 — Full module documentation

Description:
Write complete inline documentation for all modules that contain actual code: Toolkit, Veil, Axis, Insight (when built).

Requirements:
- Each module file gets a header block: purpose, dependencies, public API summary
- Each public function gets a one-line doc comment: what it does, parameters, return value
- Each major internal section gets a section comment
- Document all constants that affect behavior (not obvious ones)
- Toolkit: document all utility namespaces (Util, Color, etc.)
- Veil: document all protection APIs, surface management, service proxy
- Axis: document all control constructors and their option tables
- Insight: document ESP API when complete

Constraints:
- Comments must be concise — no multi-paragraph blocks
- Do not document what the code obviously does — only document WHY or non-obvious constraints
- Do not change any code logic

Acceptance Criteria:
- Any developer can read a function signature + its one-line doc and understand how to call it
- All public APIs documented
- No missing or placeholder doc entries
