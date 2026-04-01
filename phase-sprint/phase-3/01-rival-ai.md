# TASK 1: RIVAL AI STATE MACHINE

## Description
[SOLO DEV SCOPE] Create RivalAI with 3 states. AI reads TraceLevel and transitions automatically.

## Implementation Details

### A. Singleton Creation
*   **File:** `autoload/RivalAI.gd`
*   **Autoload Order:** After `TraceLevelManager`

### B. State Enum
```gdscript
enum State { IDLE, SEARCHING, LOCKDOWN }
var current_state := State.IDLE
```

### C. State Transitions (Read-Only)
```gdscript
func _process(_delta):
    if GameState.current_role != Role.HACKER:
        return
    
    var trace = TraceLevelManager.get_trace_level()
    
    if trace >= 70.0:
        _transition_to(State.LOCKDOWN)
    elif trace >= 30.0:
        _transition_to(State.SEARCHING)
    else:
        _transition_to(State.IDLE)
```

### D. _transition_to(new_state)
```gdscript
func _transition_to(new_state: State):
    if current_state == new_state:
        return
    
    current_state = new_state
    EventBus.rival_ai_state_changed.emit(current_state)
    
    match current_state:
        State.SEARCHING:
            _on_enter_searching()
        State.LOCKDOWN:
            _on_enter_lockdown()

func _on_enter_searching():
    TerminalSystem.inject_system_message("ANOMALY DETECTED: Correlating network telemetry...")
    NotificationManager.show_notification("Suspicious activity detected")

func _on_enter_lockdown():
    TerminalSystem.inject_system_message("COMPROMISE DETECTED: Initiating host isolation protocol...")
    _start_isolation_countdown()
```

## Success Criteria
- [ ] **[BLOCKER]** AI transitions IDLE → SEARCHING at Trace 30
- [ ] **[BLOCKER]** AI transitions SEARCHING → LOCKDOWN at Trace 70
- [ ] Terminal message displays on state change
- [ ] `rival_ai_state_changed` signal emits

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Signal connect/disconnect hygiene (add if needed)
- ❌ Speed scaling by HeatManager
- ❌ `force_state()` method (add in Phase 5 for scripted events)
