# TASK 2: BROKER DIALOGUE (3-DAY ARC)

## Description
[SOLO DEV SCOPE] Create 3 Broker dialogue files (Day 1 intro, Day 2 check-in, Day 3 reveal setup).

## Implementation Details

### A. Broker Dialogue Files
Create `resources/dialogues/broker/`:
- `broker_day1_intro.tres` — "Prove yourself. First contract awaits."
- `broker_day2_checkin.tres` — "Good work. But don't get complacent."
- `broker_day3_reveal.tres` — "There's more to this job. Meet me after Day 3."

### B. DialogueDataResource Structure (Already Exists)
```gdscript
# resources/dialogue/DialogueDataResource.gd
class_name DialogueDataResource
extends Resource

@export var npc_name: String = "NPC"
@export var portrait: String = "👤"
@export var is_randomized: bool = false
@export var lines: Array[Dictionary] = []
```

Each line is: `{"text": "Dialogue line here"}`

### C. DialogueManager Integration
```gdscript
# In NarrativeDirector, when starting hacker shift:
func start_broker_dialogue(dialogue_id: String):
    var path = "res://resources/dialogues/broker/broker_%s.tres" % dialogue_id
    if ResourceLoader.exists(path):
        var res = load(path)
        DialogueManager.start_dialogue(null, res)  # null = no NPC node
```

## Success Criteria
- [ ] **[BLOCKER]** 3 Broker dialogue files exist
- [ ] **[BLOCKER]** Dialogue plays on shift start
- [ ] Broker uses terminal overlay (not 3D NPC)

## OUT OF SCOPE
- ❌ Full 7-day Broker arc (Days 4-7 cut)
- ❌ Branching dialogue (linear only)
- ❌ Player response options
