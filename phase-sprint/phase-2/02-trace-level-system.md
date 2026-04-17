# TASK 2: TRACE LEVEL SYSTEM (CONSEQUENCE ENGINE)

## Description
Create TraceLevelManager. This is the Hacker's "anti-Heat" — accumulation + passive decay.

## Implementation Details

### A. Singleton Creation
*   **File:** `autoload/TraceLevelManager.gd` [x]
*   **Autoload Order:** After `EventBus` and `GameState` [x]

### B. Signal Listener
```gdscript
func _ready():
    EventBus.offensive_action_performed.connect(_on_offensive_action)

func _on_offensive_action(data: Dictionary):
    var cost = data.get("trace_cost", 0.0)
    trace_level = min(100.0, trace_level + cost)
```
[x] Implemented

### C. Passive Decay
```gdscript
var decay_timer: Timer

func _ready():
    decay_timer = Timer.new()
    decay_timer.wait_time = 1.0
    decay_timer.timeout.connect(_on_decay_tick)
    add_child(decay_timer)
    decay_timer.start()

func _on_decay_tick():
    if trace_level > 0.0 and can_decay():
        trace_level = max(0.0, trace_level - GlobalConstants.TRACE_DECAY_RATE)

func can_decay() -> bool:
    return GameState.current_role == Role.HACKER and \
           not MinigameBase.is_active
```
[x] Implemented

### D. Public API
```gdscript
func get_trace_level() -> float: return trace_level
func get_trace_normalized() -> float: return trace_level / 100.0
```
[x] Implemented

## Implementation Details (Continued)
*   **Decay Guard (LOCKDOWN):** [ ] Decay must pause during `LOCKDOWN` state.
*   **Shift Reset:** [ ] Trace level must reset to 0.0 on `hacker_shift_started` signal.
*   **Trace Reduction:** [ ] Implement `reduce_trace(amount)` for the Wiper app.

## Success Criteria
- [x] **[BLOCKER]** Exploit command increases Trace by 15.0
- [x] **[BLOCKER]** Trace decays by 1.0 per second when idle
- [x] Decay pauses during minigames
- [x] `get_trace_level()` returns correct value
- [ ] Decay pauses during LOCKDOWN.
- [ ] Trace resets on new shift.
- [ ] `reduce_trace()` method exists and works.
