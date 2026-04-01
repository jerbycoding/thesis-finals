# TASK 1: MIRROR MODE (THESIS CENTERPIECE)

## Description
[SOLO DEV SCOPE] Create side-by-side forensic report. Hacker actions (left) vs. SIEM logs (right).

## Implementation Details

### A. Scene Creation
*   **File:** `scenes/ui/MirrorMode.tscn`
*   **Structure:** Two RichTextLabel panels side-by-side

### B. Trigger Points
```gdscript
# In NarrativeDirector._handle_shift_end():
if GameState.current_role == Role.HACKER and GameState.is_campaign_session:
    if NarrativeDirector.current_day > 1:  # Skip Day 1
        show_mirror_mode()

func show_mirror_mode():
    var scene = load("res://scenes/ui/MirrorMode.tscn").instantiate()
    get_tree().root.add_child(scene)
    scene.setup(NarrativeDirector.current_day - 1)
```

### C. Data Sources
```gdscript
# In MirrorMode.gd:
func setup(day: int):
    # Left panel: HackerHistory
    var actions = HackerHistory.get_entries_for_day(day)
    for action in actions:
        left_panel.add_entry("%s → %s (%s)" % [
            action.action_type,
            action.target,
            action.result
        ])
    
    # Right panel: LogSystem
    var logs = LogSystem.get_logs_for_shift(day)
    for log in logs:
        right_panel.add_entry("[%s] %s: %s" % [
            log.severity,
            log.source,
            log.message
        ])
```

### D. Summary Panel
```gdscript
summary.text = """
Bounty: %d
Hosts Compromised: %d
Times Detected: %d
""" % [
    BountyLedger.get_shift_bounty(),
    HackerHistory.get_entries_for_day(day).size(),
    HackerHistory.get_caught_count(day)
]
```

## Success Criteria
- [ ] **[BLOCKER]** Mirror Mode opens after Day 2+ shifts
- [ ] **[BLOCKER]** Left panel shows HackerHistory entries
- [ ] **[BLOCKER]** Right panel shows SIEM logs
- [ ] Summary panel displays bounty and stats
- [ ] Closing returns to HackerRoom

## OUT OF SCOPE (Cut for Solo Dev)
- ❌ Correlation lines between panels (side-by-side only)
- ❌ Confidence tiers (HIGH/MEDIUM/LOW)
- ❌ Wiper gap detection
- ❌ Poison log badges
- ❌ Export to PDF (screenshot ok)
