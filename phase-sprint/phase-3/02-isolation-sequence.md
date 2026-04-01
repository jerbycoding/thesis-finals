# TASK 2: ISOLATION SEQUENCE (FAILURE STATE)

## Description
[SOLO DEV SCOPE] Implement LOCKDOWN isolation countdown. This is the "Game Over" sequence.

## Implementation Details

### A. Isolation Countdown
```gdscript
var isolation_timer: Timer
var is_isolation_in_progress := false

func _on_enter_lockdown():
    is_isolation_in_progress = true
    isolation_timer = Timer.new()
    isolation_timer.wait_time = GlobalConstants.RIVAL_AI_BASE_ISOLATION_SECONDS
    isolation_timer.one_shot = true
    isolation_timer.timeout.connect(_on_isolation_complete)
    add_child(isolation_timer)
    isolation_timer.start()
```

### B. Isolation Complete Callback
```gdscript
func _on_isolation_complete():
    # Race condition guard
    if not is_isolation_in_progress:
        return
    
    is_isolation_in_progress = false
    
    # Reset footholds
    GameState.current_foothold = ""
    GameState.hacker_footholds.clear()
    
    # Emit signal
    EventBus.rival_ai_isolation_complete.emit("")
    
    # Show Connection Lost
    TransitionManager.play_connection_lost()
```

### C. TransitionManager Extension
```gdscript
func play_connection_lost():
    # Show overlay with "CONNECTION TERMINATED BY AUTHORITIES"
    # Return to 3D HackerRoom
    # Allow player to try again
```

### D. Public API
```gdscript
func is_isolation_in_progress() -> bool:
    return is_isolation_in_progress

func abort_isolation():
    # Called by pivot command
    if isolation_timer:
        isolation_timer.stop()
    is_isolation_in_progress = false
    _transition_to(State.SEARCHING)
```

## Success Criteria
- [ ] **[BLOCKER]** Isolation countdown starts at LOCKDOWN
- [ ] **[BLOCKER]** "Connection Lost" displays after 20 seconds
- [ ] **[BLOCKER]** Footholds reset after isolation
- [ ] `is_isolation_in_progress()` returns correct state
- [ ] Race condition guard prevents double-fire

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Heat multiplier scaling (use base 20 seconds)
- ❌ Host blocking (can re-exploit after isolation)
- ❌ Post-isolation state retention
