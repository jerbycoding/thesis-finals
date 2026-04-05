# HackerShiftResource.gd
# Data structure for a single day in the hacker campaign
extends Resource
class_name HackerShiftResource

@export var day_number: int = 1

@export_group("Contracts")
@export var contract_ids: Array[String] = ["ransom_any"]  # IDs to load from ContractManager pool

@export_group("Hazards")
@export var honeypot_hosts: Array[String] = []  # Hosts to mark as honeypot this day

@export_group("Narrative")
@export var broker_dialogue_id: String = ""  # e.g. "day1_intro" → loads broker_day1_intro.tres

func _to_string() -> String:
	return "[HackerShift: Day %d (%d contracts)]" % [day_number, contract_ids.size()]

func validate() -> bool:
	if day_number < 1:
		return false
	if contract_ids.is_empty():
		return false
	return true

func clear_shift_state():
	"""Called when loading this shift — resets contract acceptance state."""
	pass  # Contracts reset when loaded from pool
