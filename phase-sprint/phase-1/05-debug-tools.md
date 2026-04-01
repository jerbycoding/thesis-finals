# TASK 5: DEBUG TOOLS FOR SOLO DEV

## Description
[SOLO DEV SCOPE] Add F1 debug jump to Hacker campaign. Essential for rapid iteration.

## Implementation Details

### A. DebugManager Extension
*   Add F1 handler: Jump to Hacker campaign
*   Load `HackerRoom.tscn` directly (skip title screen)
*   Set `GameState.current_role = Role.HACKER`

### B. Debug HUD Addition
*   Show current role on HUD (F12 toggle)
*   Show Trace Level (will be 0 until Phase 2)

## Success Criteria
- [ ] **[BLOCKER]** F1 loads Hacker campaign directly
- [ ] Role displays correctly on debug HUD
- [ ] Can iterate without going through title screen

## OUT OF SCOPE
- ❌ F3/F4 contract debug (add in Phase 5)
- ❌ Role guards on F9 (Analyst chaos only)
