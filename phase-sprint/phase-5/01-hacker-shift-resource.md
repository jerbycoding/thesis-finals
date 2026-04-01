# TASK 1: HACKER SHIFT RESOURCE (DAYS 1-3)

## Description
[SOLO DEV SCOPE] Create HackerShiftResource and 3 shift files (Day 1, 2, 3). Skip Days 4-7 for now.

## Implementation Details

### A. HackerShiftResource.gd
Create `scripts/resources/HackerShiftResource.gd`:
```gdscript
extends Resource
class_name HackerShiftResource

@export var day_number: int = 1
@export var contracts: Array[ContractResource] = []
@export var available_hosts: Array[String] = []
@export var honeypot_hosts: Array[String] = []
@export var broker_intro_dialogue_id: String = ""
```

### B. Shift Files Creation
Create `resources/hacker_shifts/`:
- `day_1.tres` — Tutorial, 1 contract, no honeypots
- `day_2.tres` — First honeypot, 1 contract
- `day_3.tres` — Broker reveal setup, 1 contract

### C. NarrativeDirector Extension
```gdscript
# In _ready(), add hacker shift discovery:
const HACKER_SHIFT_DIR = "res://resources/hacker_shifts/"
var hacker_shift_library: Dictionary = {}

func _discover_hacker_shifts():
    var loaded = FileUtil.load_and_validate_resources(HACKER_SHIFT_DIR, "HackerShiftResource")
    for res in loaded:
        hacker_shift_library[res.day_number] = res
```

## Success Criteria
- [ ] **[BLOCKER]** HackerShiftResource class exists
- [ ] **[BLOCKER]** day_1.tres, day_2.tres, day_3.tres exist
- [ ] NarrativeDirector can load hacker shifts

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Days 4-7 (3-day demo is enough)
- ❌ Scripted events array (add honeypots manually)
- ❌ shift_unlock_condition (linear progression ok)
