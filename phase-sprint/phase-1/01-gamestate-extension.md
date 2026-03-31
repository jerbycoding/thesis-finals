# TASK 1: GAMESTATE EXTENSION (ROLE AUTHORITY)

## Description
[REVISED] Add a permanent `Role` axis to `GameState.gd`, declare all future role-specific variables, and define the master `switch_role()` function with the correct 11-step sequence.

## Implementation Details

### A. Variable Declarations in `autoload/GameState.gd`
*   **Role Enum:** Add `enum Role { ANALYST, HACKER }`.
*   **Core State:** Add `var current_role = Role.ANALYST`.
*   **Crash Guard:** Add `var role_transition_in_progress := false`. This **must** be part of the save file.
*   **Session Type:** Add `var is_campaign_session := false`.
*   **Phase 2 Reserved Variables:** 
    *   `var current_foothold := ""`
    *   `var hacker_footholds := {}`
    *   `var active_spoof_identity := {}`

### B. The `switch_role(new_role)` Function
Execute these 11 steps in **exact order**:
1.  **[BLOCKER]** Check Minigame Guard: `if MinigameBase.is_active: return`.
2.  **[BLOCKER]** Set Dirty Flag: `role_transition_in_progress = true`.
3.  **[BLOCKER]** Clear All Timers: `TimeManager.clear_all_timers()`.
4.  Flush UI Pools: `UIObjectPool.flush()`.
5.  **[BLOCKER]** Switch Network Context: `NetworkState.switch_context(new_role)`. (Must happen BEFORE heat cache).
6.  **[BLOCKER]** Cache/Reset Heat: `HeatManager.cache_and_reset(new_role)`.
7.  Swap Ambient Audio: `AudioManager.swap_ambient_loop(new_role)`.
8.  Set Final Role: `current_role = new_role`.
9.  **Variable Reset:** If `new_role == Role.ANALYST`, reset `current_foothold = ""`, `hacker_footholds = {}`, and `active_spoof_identity = {}`.
10. Load UI Theme & Permissions: `DesktopWindowManager.set_theme(new_role)`.
11. Clear Dirty Flag: `role_transition_in_progress = false`.

## Success Criteria
- [ ] **[BLOCKER]** `switch_role()` implements the 11-step sequence in the specified order.
- [ ] **[BLOCKER]** Network Context (Step 5) is switched before Heat Cache (Step 6).
- [ ] **[BLOCKER]** Hacker variables are explicitly reset when switching back to Analyst.
- [ ] `role_transition_in_progress` is declared and used as a transition guard.
- [ ] All Phase 2 reserved variables are declared.
