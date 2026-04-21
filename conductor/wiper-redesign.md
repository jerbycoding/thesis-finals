# Evidence Wiper Redesign: Sector Zero-Fill

## Objective
To redesign the `App_Wiper` from a buggy slider minigame into an immersive, technical "Hex Grid" editor. This reinforces the Hacker role's low-level access and turns the abstract concept of "deleting logs" into a tangible, physical scrubbing action.

## Key Files & Context
*   **Target Scene:** `res://scenes/2d/apps/App_Wiper.tscn`
*   **Target Script:** `res://scripts/2d/apps/App_Wiper.gd`
*   **Dependencies:** Requires `HackerTheme.tres` for styling. Preserves the existing `TraceLevelManager` rewards and "Log Gap" 20% penalty mechanic.

## Proposed Solution (The Aesthetic Shift)

The new interface will focus on low-level memory aesthetics:
1.  **Header:** Rename to "SECTOR_ZERO_FILL // FORENSIC_CLEANUP".
2.  **The Memory Dump (Grid):** A large 2D grid (`GridContainer`) populated with random Hexadecimal values (e.g., `A4`, `FF`, `00`).
3.  **The Targets (Evidence):** Periodically, random blocks in the grid will turn **Signal Red**. These represent forensic evidence logs.
4.  **The Mechanic (Scrubbing):** 
    *   The player controls a "Scrubber Head" (their mouse cursor when hovering over the grid).
    *   Dragging the mouse over a red block "zeros it out", turning it to a bright green `00` and increasing the Wipe Integrity progress bar.
    *   **Noise Penalty:** Dragging over a normal gray block accidentally corrupts generic system data, causing a minor trace penalty (or decreasing progress).
5.  **Reactive Telemetry:** A side panel showing `SECTORS_CLEARED`, `CORRUPTION_ERRORS`, and the `INTEGRITY_RATING`.

## Implementation Steps

### Phase 1: Scene Reconstruction (`App_Wiper.tscn`)
1.  **Layout Refactor:** Use an `HBoxContainer`. Left side: The massive Hex Grid (`GridContainer`). Right side: The telemetry panel and the "INITIALIZE_WIPE" button.
2.  **Hex Cells:** Create a small, reusable component (or just instantiate `Label`s/`ColorRect`s dynamically in code) for the grid cells.
3.  **Styling:** Apply the `HackerTheme`. Ensure the grid background is pitch black and standard hex values are dim gray.

### Phase 2: Script Enhancements (`App_Wiper.gd`)
1.  **Grid Initialization:** In `_ready()`, generate a grid of ~100-200 cells filled with random hex strings.
2.  **Evidence Spawning:** During `_process`, use a timer to randomly pick gray cells and turn them red (setting a meta tag `is_evidence = true`).
3.  **Mouse Input Handling:** Connect to the `gui_input` or `mouse_entered` signals of the cells. If the left mouse button is held down (scrubbing) while entering a cell:
    *   If red: Turn to green `00`, add `10.0` to progress. Play a success beep.
    *   If gray: Flash orange, subtract `2.0` from progress (Noise). Play an error beep.
4.  **Win Condition:** Once `overwrite_integrity` hits 100%, trigger the existing `_complete_wipe()` logic (including the 20% log gap risk).

## Verification & Testing
1.  Establish a foothold.
2.  Launch "Sector Zero-Fill".
3.  Click "INITIALIZE_WIPE".
4.  Verify the grid populates and random cells turn red.
5.  Click and drag across the red cells. Verify they turn to `00` and progress increases.
6.  Click and drag across gray cells. Verify progress decreases.
7.  Reach 100% progress and verify the `_complete_wipe` trace reduction and potential "Log Gap" alert trigger.