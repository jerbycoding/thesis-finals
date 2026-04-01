# TASK 3: HACKER HISTORY (FORENSIC LOG)

## Description
[SOLO DEV SCOPE] Create HackerHistory singleton. This records every action for Mirror Mode (Phase 6).

## Implementation Details

### A. Singleton Creation
*   **File:** `autoload/HackerHistory.gd`
*   **Autoload Order:** After `EventBus`

### B. Signal Listener
```gdscript
var history: Array[Dictionary] = []

func _ready():
    EventBus.offensive_action_performed.connect(_on_offensive_action)

func _on_offensive_action(data: Dictionary):
    history.append(data)
    # Write to disk immediately (crash safety)
    _write_to_disk()
```

### C. Disk Persistence
```gdscript
func _write_to_disk():
    var save_path = "user://saves/hacker_history.json"
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(history))
```

### D. Phase 6 Stub
```gdscript
func get_entries_for_day(day: int) -> Array:
    return history  # Full history for now, filter by day in Phase 6
```

## Success Criteria
- [ ] **[BLOCKER]** Every exploit appends to `history` array
- [ ] **[BLOCKER]** History writes to disk after each action
- [ ] `get_entries_for_day()` stub exists

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Shift day filtering (add in Phase 5)
- ❌ Tick collapsing for exfiltration (Exfiltrator cut)
- ❌ Isolation event recording (add in Phase 3)
