# ContractResource.gd
# Data structure for a hacker campaign contract (Broker-issued mission)
# Inherits from TicketResource to reuse validation and formatting logic.
extends TicketResource
class_name ContractResource

enum PayloadType { RANSOMWARE, EXFILTRATION, BOTH, WIPER }

# === PHASE 5: 12-FIELD SCHEMA ===
@export_group("Contract Metadata")
@export var narrative_text: String = "" # Raw text with {VAR:...} tokens
@export var tactical_hint: String = "" # Educational/Tactical hint for the player
@export var target_hostname: String = ""
@export var is_optional: bool = false
@export var difficulty_rating: int = 1 # 1-3 scale

@export_group("Requirements")
@export var required_payload: PayloadType = PayloadType.RANSOMWARE
@export var required_data_type: String = "" # Only used if payload is EXFILTRATION or BOTH

@export_group("Timeline & Rewards")
@export var time_limit_shifts: int = 1 # Number of shifts before expiry
@export var expiry_consequence: String = "minor_rep_loss"
@export var bounty_reward: int = 100
@export var completion_dialogue_id: String = "" # Triggered on submission

# Runtime State
var is_accepted: bool = false
var is_completed: bool = false

func _to_string() -> String:
	return "[Contract: %s (%s) - $%d]" % [ticket_id, target_hostname, bounty_reward]

func validate() -> bool:
	if ticket_id.is_empty() or title.is_empty():
		return false
	if bounty_reward <= 0:
		return false
	return true

func get_formatted_narrative() -> String:
	"""Resolves tokens in narrative_text using VariableRegistry."""
	var text = narrative_text if not narrative_text.is_empty() else description
	
	if VariableRegistry:
		return VariableRegistry.resolve_tokens(text)
		
	return text

func clear_state():
	"""Resets runtime flags for a new session/shift."""
	is_accepted = false
	is_completed = false
