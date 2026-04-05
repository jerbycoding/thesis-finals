# TASK 5: ROLE SWITCH FLOW

## Description
[SOLO DEV SCOPE] Wire up the full flow: Title → New Game → Hacker → Day 1 starts automatically.

## Implementation Details

### A. Title Screen Extension
Add "Start Hacker Campaign" button to title screen (or reuse existing "New Game" with role selection).

### B. NarrativeDirector Hacker Shift Start
```gdscript
var current_hacker_day: int = 0

func start_hacker_campaign():
    current_hacker_day = 1
    GameState.current_role = GameState.Role.HACKER
    _load_hacker_shift(1)

func _load_hacker_shift(day: int):
    if not hacker_shift_library.has(day):
        push_error("NarrativeDirector: No hacker shift for day %d" % day)
        return

    var shift = hacker_shift_library[day]
    current_hacker_day = day

    # Load contracts for this shift
    if ContractManager:
        ContractManager.load_shift_contracts(shift)

    # Play broker dialogue
    if shift.broker_dialogue_id != "":
        start_broker_dialogue(shift.broker_dialogue_id)

    # Emit shift started signal
    EventBus.hacker_shift_started.emit(day)
```

### C. GameState Hacker Day Tracking
```gdscript
# In GameState.gd — add:
var hacker_campaign_day: int = 0

# In switch_role() — when switching to HACKER:
if new_role == Role.HACKER:
    # Reset hacker-specific state
    current_foothold = ""
    hacker_footholds.clear()
    # Don't clear bounty/history (persistent across days)
```

### D. Day Progression
After completing a contract (or manually requesting shift end):
```gdscript
func advance_hacker_day():
    current_hacker_day += 1
    if current_hacker_day > 3:
        # Campaign complete (Days 4-7 deferred)
        _end_hacker_campaign()
    else:
        _load_hacker_shift(current_hacker_day)
```

## Success Criteria
- [ ] **[BLOCKER]** Clicking "New Game" → Hacker → Day 1 loads
- [ ] **[BLOCKER]** Broker dialogue plays on Day 1 start
- [ ] Contracts available for Day 1
- [ ] Day advancement works (Day 1 → Day 2 → Day 3)

## OUT OF SCOPE
- ❌ Days 4-7 (campaign ends after Day 3 for MVHR)
- ❌ Day unlock conditions (linear progression)
- ❌ Save/continue from specific day
