# TASK 1: HACKER SHIFT SYSTEM

## Description
[SOLO DEV SCOPE] Create `HackerShiftResource` and 3 shift files (Day 1, 2, 3). Skip Days 4-7.

## Implementation Details

### A. HackerShiftResource.gd
Create `scripts/resources/HackerShiftResource.gd`:
```gdscript
extends Resource
class_name HackerShiftResource

@export var day_number: int = 1
@export var available_contracts: Array[ContractResource] = []
@export var honeypot_hosts: Array[String] = []  # Hosts to mark as honeypot this day
@export var broker_dialogue_id: String = ""  # e.g. "day1_intro"
```

### B. Shift Files Creation
Create `resources/hacker_shifts/` directory:
- `day_1.tres` — Tutorial, 1 contract (ransom_any), no honeypots, broker: "Prove yourself."
- `day_2.tres` — First honeypot (FINANCE-SRV-01), 1 contract, broker: "Don't get complacent."
- `day_3.tres` — Broker reveal setup, 1 contract, broker: "There's more to this job."

### C. NarrativeDirector Extension
```gdscript
# Add hacker shift support
const HACKER_SHIFT_DIR = "res://resources/hacker_shifts/"
var hacker_shift_library: Dictionary = {}

func _ready():
    _discover_shifts()  # existing Analyst shifts
    _discover_hacker_shifts()  # NEW

func _discover_hacker_shifts():
    var loaded = FileUtil.load_and_validate_resources(HACKER_SHIFT_DIR, "HackerShiftResource")
    for res in loaded:
        hacker_shift_library[res.day_number] = res
```

### D. ContractManager Integration
```gdscript
func load_shift_contracts(shift: HackerShiftResource):
    available_contracts.clear()
    for contract in shift.available_contracts:
        available_contracts.append(contract)
    active_contract = null
```

## Success Criteria
- [ ] **[BLOCKER]** `HackerShiftResource.gd` exists
- [ ] **[BLOCKER]** `day_1.tres`, `day_2.tres`, `day_3.tres` exist in `resources/hacker_shifts/`
- [ ] **[BLOCKER]** NarrativeDirector loads hacker shifts
- [ ] ContractManager loads contracts from shift resource

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Days 4-7 (3-day demo is enough)
- ❌ Scripted events array (honeypots handled manually)
- ❌ `shift_unlock_conditions` (linear progression ok)
- ❌ `available_hosts` (all hosts always available)
