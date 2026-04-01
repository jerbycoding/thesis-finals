# TASK 1: RANSOMWARE APP (WIN CONDITION)

## Description
[SOLO DEV SCOPE] Create App_Ransomware. This is your PRIMARY win condition. Reuse CalibrationMinigame.

## Implementation Details

### A. Scene Creation
*   **File:** `scenes/2d/apps/App_Ransomware.tscn`
*   **Inheritance:** Inherits from `MinigameBase.gd`
*   **Mechanic:** Reuse `CalibrationMinigame.gd` (signal matching)

### B. App Logic
```gdscript
var target_hostname := ""

func _ready():
    super._ready()
    # Get current foothold from GameState
    target_hostname = GameState.current_foothold

func on_minigame_success():
    # Set host to RANSOMED in NetworkState
    NetworkState.update_host_state(target_hostname, {"status": "RANSOMED"})
    
    # Emit offensive action
    EventBus.offensive_action_performed.emit({
        action_type = "ransomware",
        target = target_hostname,
        timestamp = ShiftClock.elapsed_seconds,
        result = "SUCCESS",
        trace_cost = GlobalConstants.TRACE_COST_RANSOMWARE  # 40.0
    })
    
    # Add bounty
    if BountyLedger:
        BountyLedger.add_bounty(100)
    
    # Close app
    close_app()

func on_minigame_fail():
    # Emit failure with half trace cost
    EventBus.offensive_action_performed.emit({
        action_type = "ransomware",
        target = target_hostname,
        timestamp = ShiftClock.elapsed_seconds,
        result = "FAILED",
        trace_cost = GlobalConstants.TRACE_COST_RANSOMWARE * 0.5  # 20.0
    })
    
    close_app()
```

### C. Eligibility Guard
```gdscript
func can_launch() -> bool:
    # Must be on a host
    if GameState.current_foothold == "":
        return false
    
    # Cannot launch during LOCKDOWN
    if RivalAI and RivalAI.is_isolation_in_progress():
        return false
    
    # Host must not already be RANSOMED
    var host = NetworkState.get_host_state(target_hostname)
    if host.get("status") == "RANSOMED":
        return false
    
    return true
```

### D. GlobalConstants Addition
```gdscript
const TRACE_COST_RANSOMWARE = 40.0
```

## Success Criteria
- [ ] **[BLOCKER]** App opens from desktop (requires app registration)
- [ ] **[BLOCKER]** Minigame success sets host to RANSOMED
- [ ] **[BLOCKER]** Bounty increases by 100 on success
- [ ] Failed ransomware emits signal with 20.0 trace cost
- [ ] Cannot launch during LOCKDOWN

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Custom ransomware animation (CalibrationMinigame ok)
- ❌ Multiple host targeting (one host at a time)
- ❌ Ransom note generation
