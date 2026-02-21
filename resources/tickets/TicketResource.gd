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

## If set, this ticket is considered 'ambient noise' and can be spawned randomly during shifts.
@export var is_ambient_noise: bool = false

## If set, isolating this host will trigger a 'technical verification' for this ticket.
@export var required_host_isolation: String = ""

## If set, restoring this host will trigger a 'technical verification' for this ticket.
@export var required_host_restoration: String = ""

## The event ID to trigger in NarrativeDirector when this ticket is completed
@export var on_complete_event: String = ""

# --- Kill Chain Properties ---
@export_group("Kill Chain")
@export var kill_chain_path: String = "" # e.g., "Malware Outbreak"
@export var kill_chain_stage: int = 0 # 1, 2, or 3
@export var escalation_ticket: Resource = null # The TicketResource for the next stage
# ----------------------------

var attached_log_ids: Array[String] = [] # Log IDs that player has attached
var truth_packet: Dictionary = {} # Procedural data generated at spawn
var is_technically_fulfilled: bool = false # NEW: Track terminal actions
var spawn_timestamp: float = 0.0
var expiry_timestamp: float = 0.0

func _to_string() -> String:
	return "[Ticket: %s - %s]" % [ticket_id, title]

func attach_log(log_id: String) -> bool:
	# Returns true if log was successfully attached (not already attached)
	if log_id in attached_log_ids:
		return false
	attached_log_ids.append(log_id)
	return true

func detach_log(log_id: String) -> bool:
	if log_id in attached_log_ids:
		attached_log_ids.erase(log_id)
		return true
	return false

func get_evidence_count() -> Dictionary:
	# Returns {attached: X, required: Y}
	return {
		"attached": attached_log_ids.size(),
		"required": required_log_ids.size()
	}

func has_sufficient_evidence() -> bool:
	# Check for technical requirements first
	if required_host_isolation != "" or required_host_restoration != "":
		if not is_technically_fulfilled:
			return false

	# Check if all required logs are attached
	if required_log_ids.is_empty():
		return true  # No log requirements
	
	for required_id in required_log_ids:
		if required_id not in attached_log_ids:
			return false
	return true

func validate() -> bool:
	if ticket_id.is_empty():
		return false
	if steps.size() > 3:
		return false
	if base_time <= 0:
		return false
	return true

# --- Procedural Formatting ---

func get_formatted_description() -> String:
	var text = description
	if not truth_packet.is_empty():
		text = description.format(truth_packet)
	
	# Global Color Replacement: Swap 'cyan' for professional 'INFO_BLUE'
	return text.replace("[color=cyan]", "[color=#006CFF]")

func get_formatted_title() -> String:
	var text = title
	if not truth_packet.is_empty():
		text = title.format(truth_packet)
	
	return text.replace("[color=cyan]", "[color=#006CFF]")
