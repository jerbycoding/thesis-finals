# TASK 4: BROKER DIALOGUE (3-DAY ARC)

## Description
[SOLO DEV SCOPE] Create 3 Broker dialogue files (Day 1 intro, Day 2 check-in, Day 3 reveal setup).

## Implementation Details

### A. Dialogue Files
Create `resources/dialogues/broker/`:
- `broker_day1_intro.tres` — "Prove yourself. First contract awaits."
- `broker_day2_checkin.tres` — "Good work. But don't get complacent."
- `broker_day3_reveal.tres` — "There's more to this job. Meet me after Day 3."

### B. DialogueDataResource Structure
```gdscript
extends Resource
class_name DialogueDataResource

@export var speaker_name: String = "Broker"
@export var lines: Array[String] = []
@export var next_dialogue_id: String = ""
```

### C. DialogueManager Integration
```gdscript
func start_remote_dialogue(npc_id: String, dialogue_id: String):
    var path = "res://resources/dialogue/%s_%s.tres" % [npc_id, dialogue_id]
    if ResourceLoader.exists(path):
        var res = load(path)
        start_dialogue(null, res)  # null = no NPC node (overlay)
```

## Success Criteria
- [ ] **[BLOCKER]** 3 Broker dialogue files exist
- [ ] Dialogue plays on shift start
- [ ] Broker uses terminal overlay (not 3D NPC)

## OUT OF SCOPE
- ❌ Full 7-day Broker arc (Days 4-7 cut)
- ❌ Branching dialogue (linear only)
- ❌ Player response options
