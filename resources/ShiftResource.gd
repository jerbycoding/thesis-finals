# ShiftResource.gd
# Data structure for a narrative shift arc
extends Resource
class_name ShiftResource

@export var shift_name: String = "New Shift"
@export var shift_id: String = "shift_001"

@export_group("Documentation")
@export_multiline var shift_summary: String = "" # Brief mission brief
@export_multiline var cyber_context: String = "" # Educational "Why"

## The dialogue ID to trigger during the pre-shift briefing.
@export var briefing_dialogue_id: String = "default"

## The sequence of events. 
## Format: [{"time": 10, "type": "spawn_ticket", "ticket_id": "ID", ...}]
@export var event_sequence: Array[Dictionary] = []

## Optional pool for procedural/random events during this shift
@export var random_event_pool: Array[Dictionary] = []

## The ID of the next shift to load after this one is completed.
@export var next_shift_id: String = ""

@export_group("Threat Intelligence")
@export var threat_title: String = "" # e.g. "PHISHING"
@export_multiline var threat_description: String = ""
@export_multiline var threat_impact: String = ""
@export_multiline var threat_indicators: Array[String] = []

@export_group("Minigame Configuration")
@export_enum("NONE", "AUDIT", "RECOVERY") var minigame_type: String = "NONE"
@export var required_floor: int = 1 # 1=SOC, 2=Exec, -1=Vault, -2=Hub

func _to_string() -> String:
	return "[Shift: %s (%d events)]" % [shift_name, event_sequence.size()]

func validate() -> bool:
	if shift_id.is_empty():
		return false
	if event_sequence.is_empty():
		return false
	return true
