# TASK 1: GAMESTATE EXTENSION (ROLE AUTHORITY)

## Description
Add a permanent `Role` axis to `GameState.gd`, declare all future role-specific variables, and define the master `switch_role()` function with the correct 11-step sequence.

## Implementation Details

### A. Variable Declarations in `autoload/GameState.gd`
*   **Role Enum:** [x] Add `enum Role { ANALYST, HACKER }`.
*   **Core State:** [x] Add `var current_role = Role.ANALYST`.
*   **Crash Guard:** [x] Add `var role_transition_in_progress := false`. This **must** be part of the save file.
*   **Session Type:** [x] Add `var is_campaign_session := false`.
*   **Phase 2 Reserved Variables:** 
    *   [x] `var current_foothold := ""`
    *   [x] `var hacker_footholds := {}`
    *   [x] `var active_spoof_identity := {}`

### B. The `switch_role(new_role)` Function
Execute these 11 steps in **exact order**:
1.  [x] **[BLOCKER]** Check Minigame Guard: `if MinigameBase.is_active: return`.
2.  [x] **[BLOCKER]** Set Dirty Flag: `role_transition_in_progress = true`.
3.  [x] **[BLOCKER]** Clear All Timers: `TimeManager.clear_all_timers()`.
4.  [x] Flush UI Pools: `UIObjectPool.flush()`.
5.  [x] **[BLOCKER]** Switch Network Context: `NetworkState.switch_context(new_role)`. (Must happen BEFORE heat cache).
6.  [x] **[BLOCKER]** Cache/Reset Heat: `HeatManager.cache_and_reset(new_role)`.
7.  [x] Swap Ambient Audio: `AudioManager.swap_ambient_loop(new_role)`.
8.  [x] **[BLOCKER]** Set Final Role: `current_role = new_role`.
9.  [x] **Variable Reset:** If `new_role == Role.ANALYST`, reset `current_foothold = ""`, `hacker_footholds = {}`, and `active_spoof_identity = {}`.
10. [x] Load UI Theme & Permissions: `DesktopWindowManager.set_theme(new_role)`.
11. [x] Clear Dirty Flag: `role_transition_in_progress = false`.

## Success Criteria
- [x] **[BLOCKER]** `switch_role()` implements the 11-step sequence in the specified order.
- [x] **[BLOCKER]** Network Context (Step 5) is switched before Heat Cache (Step 6).
- [x] **[BLOCKER]** Hacker variables are explicitly reset when switching back to Analyst.
- [x] `role_transition_in_progress` is declared and used as a transition guard.
- [x] All Phase 2 reserved variables are declared.

