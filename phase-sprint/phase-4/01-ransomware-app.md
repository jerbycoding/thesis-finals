# TASK 1: RANSOMWARE APP (WIN CONDITION) — ✅ COMPLETE!

**Status:** ✅ **COMPLETE** (April 4, 2026)

## Description
[SOLO DEV SCOPE] Create App_Ransomware. This is your PRIMARY win condition. Uses custom RansomCalibration minigame.

## Implementation Details

### A. Scene Creation ✅ **CREATED**
*   **File:** `scenes/2d/apps/App_Ransomware.tscn`
*   **Mechanic:** Embedded `RansomCalibration.tscn` (standalone, no external config)
*   **Pattern:** `unique_name_in_owner` on all interactive nodes, `%NodeName` refs in script

### B. App Logic ✅ **CREATED**
*   **File:** `scripts/2d/apps/App_Ransomware.gd`
*   Gets target from `GameState.current_foothold` (set by `TerminalSystem` on exploit success)
*   Checks if host already RANSOMED (shows "ALREADY ENCRYPTED" message)
*   On minigame success: sets host to RANSOMED, emits `offensive_action_performed`, adds bounty, auto-closes
*   On minigame fail: emits failure with half trace cost, re-enables button for retry

### C. RansomCalibration Minigame ✅ **CREATED**
*   **Files:** `scenes/ui/RansomCalibration.tscn` + `scripts/ui/RansomCalibration.gd`
*   **Mechanic:** Oscillating needle, click HIT when in green zone, 3 hits to win
*   **Self-contained:** No `CalibrationMinigameConfig` needed — randomizes target zone each run

### D. Eligibility Guard ✅ **IMPLEMENTED**
```gdscript
func _can_launch() -> bool:
    # Must be on a host
    if GameState.current_foothold == "": return false
    # Cannot launch during AI isolation
    if RivalAI and RivalAI.is_isolation_active: return false
    return true
```

## Success Criteria
- [x] **[BLOCKER]** App opens from desktop (via DesktopWindowManager)
- [x] **[BLOCKER]** Minigame success sets host to RANSOMED
- [x] **[BLOCKER]** Bounty increases by 100 on success
- [x] **[BLOCKER]** Failed ransomware emits signal with 20.0 trace cost
- [x] Cannot launch during LOCKDOWN
- [x] Re-opening app on already-RANSOMED host shows "ALREADY ENCRYPTED"
- [x] Auto-closes after 2s on success

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Custom ransomware animation (calibration minigame ok)
- ❌ Multiple host targeting (one host at a time)
- ❌ Ransom note generation
