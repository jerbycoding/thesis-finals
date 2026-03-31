# TASK 4c: SUPPORTING SYSTEMS SETUP

## Description
[REVISED] Create and configure miscellaneous hacker campaign resources, audio loop switching, and role-aware debug tools.

## Implementation Details

### A. Narrative & Shifts
*   **[BLOCKER]** Create a minimal `day_1.tres` placeholder `HackerShiftResource` in `res://resources/hacker_shifts/`. This is required for `NarrativeDirector` to load the first day.
*   **Hacker Shift Load:** Modify `NarrativeDirector` to load shifts from `res://resources/hacker_shifts/` when `current_role == Role.HACKER`.

### B. Audio Loop
*   **Graceful Failure:** `AudioManager.swap_ambient_loop()` must handle missing audio files gracefully by logging a warning and continuing, rather than crashing.
*   **Audio Swap:** Implement the actual cross-role audio swapping logic.

### C. Debug Tools
*   **[BLOCKER]** **F1/F2 Shift-Jump Guard:** These hotkeys must load from the correct shift directory based on `current_role`. If Hacker, they must jump to `hacker_shifts/day_{N}.tres`.
*   **F9 Guard:** Role guard the Analyst's F9 "Chaos trigger."

### D. Audit Checks
*   `ResourceAuditManager` must be updated to scan the `hacker_shifts` directory.

## Success Criteria
- [ ] **[BLOCKER]** A placeholder `day_1.tres` shift resource exists.
- [ ] **[BLOCKER]** `DebugManager` shift-jump hotkeys (F1/F2) are role-aware.
- [ ] **[BLOCKER]** `AudioManager` handles missing audio files without crashing.
- [ ] `DesktopWindowManager` loads `HackerAppProfile.tres` for the hacker role.
- [ ] `NarrativeDirector` loads from the correct shift directory based on role.
- [ ] `DebugManager` hotkeys are correctly role-guarded.
