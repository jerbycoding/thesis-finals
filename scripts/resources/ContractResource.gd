# ContractResource.gd
# Data structure for a hacker campaign contract
extends Resource
class_name ContractResource

@export var contract_id: String = ""
@export var title: String = ""
@export var description: String = ""

@export_group("Requirements")
@export var required_payload: String = "RANSOMWARE"  # "RANSOMWARE"
@export var bounty_reward: int = 100
@export var difficulty: int = 1  # 1-3 scale

# Runtime state (not serialized)
var is_accepted := false
var is_completed := false

func _to_string() -> String:
	return "[Contract: %s - %d bounty]" % [title, bounty_reward]

func validate() -> bool:
	if contract_id.is_empty() or title.is_empty():
		return false
	if bounty_reward <= 0:
		return false
	return true

func clear_state():
	"""Called when a new shift starts."""
	is_accepted = false
	is_completed = false
