# TASK 4c: SUPPORTING SYSTEMS SETUP

## Description
Create and configure miscellaneous hacker campaign resources, audio loop switching, and role-aware debug tools.

## Implementation Details

### A. Narrative & Shifts
*   **[BLOCKER]** [x] Create a minimal `day_1.tres` placeholder `HackerShiftResource` in `res://resources/hacker_shifts/`. This is required for `NarrativeDirector` to load the first day.
*   **Hacker Shift Load:** [x] Modify `NarrativeDirector` to load shifts from `res://resources/hacker_shifts/` when `current_role == Role.HACKER`.

### B. Audio Loop
*   **Graceful Failure:** [x] `AudioManager.swap_ambient_loop()` must handle missing audio files gracefully by logging a warning and continuing, rather than crashing.
*   **Audio Swap:** [x] Implement the actual cross-role audio swapping logic.

### C. Debug Tools
*   **[BLOCKER]** **F1/F2 Shift-Jump Guard:** [x] These hotkeys must load from the correct shift directory based on `current_role`. If Hacker, they must jump to `hacker_shifts/day_{N}.tres`.
*   **F9 Guard:** [x] Role guard the Analyst's F9 "Chaos trigger."

### D. Audit Checks
*   [x] `ResourceAuditManager` must be updated to scan the `hacker_shifts` directory.

## Success Criteria
- [x] **[BLOCKER]** A placeholder `day_1.tres` shift resource exists.
- [x] **[BLOCKER]** `DebugManager` shift-jump hotkeys (F1/F2) are role-aware.
- [x] **[BLOCKER]** `AudioManager` handles missing audio files without crashing.
- [x] `DesktopWindowManager` loads `HackerAppProfile.tres` for the hacker role.
- [x] `NarrativeDirector` loads from the correct shift directory based on role.
- [x] `DebugManager` hotkeys are correctly role-guarded.
