# TicketResource.gd
extends Resource
class_name TicketResource

@export var ticket_id: String
@export var title: String
@export_multiline var description: String
@export var severity: String # "Low", "Medium", "High", "Critical"
@export var category: String # "Phishing", "Malware", "Unauthorized Access"
@export var steps: Array[String] = [] # Max 3 steps
@export var required_tool: String # "siem", "email", "terminal", "none"
@export var base_time: float = 180.0 # seconds
@export var hidden_risks: Array[String] = []
@export var required_log_ids: Array[String] = [] # Log IDs that should be attached for compliant completion
var attached_log_ids: Array[String] = [] # Log IDs that player has attached
var spawn_timestamp: float = 0.0

func _to_string() -> String:
	return "[Ticket: %s - %s]" % [ticket_id, title]

func attach_log(log_id: String) -> bool:
	# Returns true if log was successfully attached (not already attached)
	if log_id in attached_log_ids:
		return false
	attached_log_ids.append(log_id)
	return true

func get_evidence_count() -> Dictionary:
	# Returns {attached: X, required: Y}
	return {
		"attached": attached_log_ids.size(),
		"required": required_log_ids.size()
	}

func has_sufficient_evidence() -> bool:
	# Check if all required logs are attached
	if required_log_ids.is_empty():
		return true  # No requirements
	
	for required_id in required_log_ids:
		if required_id not in attached_log_ids:
			return false
	return true
