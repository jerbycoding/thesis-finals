# ShiftResource.gd
# Data structure for a narrative shift arc
extends Resource
class_name ShiftResource

@export var shift_name: String = "New Shift"
@export var shift_id: String = "shift_001"

## The dialogue ID to trigger during the pre-shift briefing.
@export var briefing_dialogue_id: String = "default"

## The sequence of events. 
## Format: [{"time": 10, "type": "spawn_ticket", "ticket_id": "ID", ...}]
@export var event_sequence: Array[Dictionary] = []

## Optional pool for procedural/random events during this shift
@export var random_event_pool: Array[Dictionary] = []

## The ID of the next shift to load after this one is completed.
@export var next_shift_id: String = ""

func _to_string() -> String:
	return "[Shift: %s (%d events)]" % [shift_name, event_sequence.size()]

func validate() -> bool:
	if shift_id.is_empty():
		return false
	if event_sequence.is_empty():
		return false
	return true
