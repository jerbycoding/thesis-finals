# TASK 2: BOUNTY LEDGER (REWARD TRACKING) — ✅ COMPLETE!

**Status:** ✅ **COMPLETE** (April 4, 2026)

## Description
[SOLO DEV SCOPE] Create BountyLedger singleton. Tracks accumulated bounty points from contracts.

## Implementation Details

### A. Singleton Creation
*   **File:** `autoload/BountyLedger.gd` ✅ **CREATED**
*   **Autoload Order:** After `RivalAI` ✅ **DONE**

### B. Core Functions
```gdscript
var total_bounty: int = 0
var shift_bounties: Dictionary = {}  # shift_day -> { hostname -> amount }

func add_bounty(hostname: String, amount: int, shift_day: int = 0)
func get_bounty() -> int
func get_bounty_for_day(shift_day: int) -> int
func get_bounty_breakdown() -> Dictionary  # For Mirror Mode
func reset_ledger()
```

**Notes:** Enhanced beyond spec — supports per-day breakdown for Mirror Mode phase 6.

### C. Load on Ready
*   Loads from `user://saves/bounty.json` ✅
*   Writes to disk on every `add_bounty()` call ✅

### D. Debug Commands
*   Ctrl+F4: Add 100 bounty ✅
*   Ctrl+F5: Reset ledger ✅

## Success Criteria
- [x] **[BLOCKER]** `add_bounty("host", 100, 0)` increases total
- [x] **[BLOCKER]** Bounty persists to disk
- [x] `get_bounty()` returns correct value

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Per-day filtering (add in Phase 5) — Partially supported for Mirror Mode
- ❌ Bounty spending mechanics
