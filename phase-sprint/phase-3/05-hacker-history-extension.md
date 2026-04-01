# TASK 5: HACKER HISTORY EXTENSION

## Description
[SOLO DEV SCOPE] Record isolation events in HackerHistory. Prepares for Mirror Mode.

## Implementation Details

### A. Signal Listener
```gdscript
func _ready():
    EventBus.rival_ai_isolation_complete.connect(_on_isolation)

func _on_isolation(hostname: String):
    history.append({
        action_type = "isolation",
        target = hostname,
        timestamp = ShiftClock.elapsed_seconds,
        result = "CAUGHT",
        trace_cost = 0.0
    })
    _write_to_disk()
```

## Success Criteria
- [ ] **[BLOCKER]** Isolation appends to history
- [ ] Isolation writes to disk

## OUT OF SCOPE
- ❌ Shift day filtering
- ❌ Tick collapsing
