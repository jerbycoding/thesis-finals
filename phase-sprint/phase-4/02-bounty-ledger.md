# TASK 2: BOUNTY LEDGER (REWARD TRACKING)

## Description
[SOLO DEV SCOPE] Create BountyLedger singleton. Tracks accumulated bounty points from contracts.

## Implementation Details

### A. Singleton Creation
*   **File:** `autoload/BountyLedger.gd`
*   **Autoload Order:** After `RivalAI`

### B. Core Functions
```gdscript
var total_bounty := 0
var shift_bounty := 0

func add_bounty(amount: int):
    total_bounty += amount
    shift_bounty += amount
    _write_to_disk()

func get_total_bounty() -> int:
    return total_bounty

func get_shift_bounty() -> int:
    return shift_bounty

func reset_shift_bounty():
    shift_bounty = 0

func _write_to_disk():
    var save_path = "user://saves/bounty.json"
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        var data = {"total": total_bounty, "shift": shift_bounty}
        file.store_string(JSON.stringify(data))
```

### C. Load on Ready
```gdscript
func _ready():
    var save_path = "user://saves/bounty.json"
    if FileAccess.file_exists(save_path):
        var file = FileAccess.open(save_path, FileAccess.READ)
        var data = JSON.parse_string(file.get_as_text())
        if data:
            total_bounty = data.get("total", 0)
            shift_bounty = data.get("shift", 0)
```

## Success Criteria
- [ ] **[BLOCKER]** `add_bounty(100)` increases total
- [ ] **[BLOCKER]** Bounty persists to disk
- [ ] `get_total_bounty()` returns correct value

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Per-day filtering (add in Phase 5)
- ❌ Bounty spending mechanics
