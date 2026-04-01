# TASK 1: ROLE SWITCHING (FOUNDATION)

## Description
[SOLO DEV SCOPE] Add Role enum to GameState and implement basic role switching. Focus on ONE working flow: Analyst → Hacker switch.

## Implementation Details

### A. GameState.gd Extensions
*   **Role Enum:** Add `enum Role { ANALYST, HACKER }`
*   **Current Role:** Add `var current_role = Role.ANALYST`
*   **Session Flag:** Add `var is_campaign_session := false`

### B. switch_role(new_role) Function — MINIMUM VIABLE
Execute these 6 steps (simplified from 11-step full sequence):
1.  Check Minigame Guard: `if MinigameBase.is_active: return`
2.  Flush UI Pools: `UIObjectPool.flush()`
3.  Swap Network Context: `NetworkState.switch_context(new_role)`
4.  Set Final Role: `current_role = new_role`
5.  Load UI Theme: `DesktopWindowManager.set_theme(new_role)`
6.  Reset Hacker Variables: If `new_role == Role.ANALYST`, reset foothold variables

### C. Title Screen Update
*   Add "Hacker Campaign" button
*   Button calls `GameState.switch_role(Role.HACKER)` then starts new game

## Success Criteria
- [ ] **[BLOCKER]** "Hacker Campaign" button on title screen works
- [ ] **[BLOCKER]** Role switches from Analyst to Hacker without crash
- [ ] `current_role` persists after switch
- [ ] UI theme changes (green for Hacker, blue for Analyst)

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Save system separation (use single save for now)
- ❌ Crash recovery logic
- [ ] Audio swapping
- ❌ 11-step full sequence (use 6-step MVP)
