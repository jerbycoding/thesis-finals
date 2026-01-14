# ShiftResource.gd
# Data structure for a narrative shift arc
extends Resource
class_name ShiftResource

@export var shift_name: String = "New Shift"
@export var shift_id: String = "shift_001"

## The sequence of events. 
## Format: [{"time": 10, "type": "spawn_ticket", "ticket_id": "ID", ...}]
@export var event_sequence: Array[Dictionary] = []

## Optional pool for procedural/random events during this shift
@export var random_event_pool: Array[Dictionary] = []

func _to_string() -> String:
	return "[Shift: %s (%d events)]" % [shift_name, event_sequence.size()]

func validate() -> bool:
	if shift_id.is_empty():
		return false
	if event_sequence.is_empty():
		return false
	return true
