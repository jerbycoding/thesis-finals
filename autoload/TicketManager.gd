# TicketManager.gd
# Autoload singleton that manages all tickets in the game
extends Node

signal ticket_added(ticket: TicketResource)
signal ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float)
signal ticket_timeout(ticket_id: String)
signal log_attached(ticket_id: String, log_id: String)

var active_tickets: Array[TicketResource] = []
var completed_tickets: Array[TicketResource] = []

# Ticket library - paths to ticket scripts
var ticket_library: Array[String] = [
	"res://resources/tickets/ticket_phishing_01.gd",
	"res://resources/tickets/ticket_spear_phish.gd",
	"res://resources/tickets/ticket_malware_containment.gd",
	"res://resources/tickets/ticket_data_exfiltration.gd",
	"res://resources/tickets/ticket_ransomware_01.gd",
	"res://resources/tickets/ticket_insider_threat_01.gd",
	"res://resources/tickets/ticket_social_eng_01.gd",
]

# A mapping from simple narrative IDs to full resource paths
var ticket_id_map: Dictionary = {
	"phishing_intro": "res://resources/tickets/ticket_spear_phish.gd",
	"spear_phishing": "res://resources/tickets/ticket_spear_phish.gd",
	"malware_response": "res://resources/tickets/ticket_malware_containment.gd",
	"data_exfil": "res://resources/tickets/ticket_data_exfiltration.gd",
	"ransom_001": "res://resources/tickets/ticket_ransomware_01.gd",
	"insider_001": "res://resources/tickets/ticket_insider_threat_01.gd",
	"social_001": "res://resources/tickets/ticket_social_eng_01.gd",
}

func _ready():
	print("========================================")
	print("TicketManager initialized")
	print("========================================")
	
	# Wait a moment for other systems to initialize
	await get_tree().create_timer(0.1).timeout
	
	# Connect to signals from other systems
	if TerminalSystem:
		TerminalSystem.command_run.connect(_on_terminal_command_run)
		print("TicketManager connected to TerminalSystem")

	# Connect to the NarrativeDirector for scripted ticket spawning
	if NarrativeDirector:
		NarrativeDirector.spawn_ticket_requested.connect(spawn_ticket_by_id)
		print("TicketManager connected to NarrativeDirector")
	
	# Load initial tickets for testing - DISABLED in favor of narrative control
	# _load_initial_tickets()

func load_state(active_ids: Array, completed_ids: Array):
	active_tickets.clear()
	completed_tickets.clear()
	
	for ticket_id in active_ids:
		var ticket_path = _get_ticket_path_by_id(ticket_id)
		if not ticket_path.is_empty():
			var ticket_script = load(ticket_path)
			if ticket_script:
				var ticket_instance = ticket_script.new()
				# Use a quiet add, since we don't want to trigger "new ticket" notifications
				active_tickets.append(ticket_instance)
	
	for ticket_id in completed_ids:
		var ticket_path = _get_ticket_path_by_id(ticket_id)
		if not ticket_path.is_empty():
			var ticket_script = load(ticket_path)
			if ticket_script:
				var ticket_instance = ticket_script.new()
				completed_tickets.append(ticket_instance)
	
	print("TicketManager state loaded. Active: ", active_tickets.size(), ", Completed: ", completed_tickets.size())

func _get_ticket_path_by_id(ticket_id: String) -> String:
	# First, check the narrative map
	for key in ticket_id_map:
		var ticket_script = load(ticket_id_map[key])
		if ticket_script and ticket_script.new().ticket_id == ticket_id:
			return ticket_id_map[key]
			
	# If not in the map, search the full library
	for path in ticket_library:
		var ticket_script = load(path)
		if ticket_script and ticket_script.new().ticket_id == ticket_id:
			return path
			
	print("ERROR: Could not find ticket path for ID: ", ticket_id)
	return ""

func spawn_ticket_by_id(ticket_id: String):
	if not ticket_id_map.has(ticket_id):
		print(CorporateVoice.get_formatted_phrase("ticket_id_not_found_map", {"ticket_id": ticket_id}))
		return

	var ticket_path = ticket_id_map[ticket_id]
	if ResourceLoader.exists(ticket_path):
		var TicketScript = load(ticket_path)
		if TicketScript:
			var ticket = TicketScript.new()
			add_ticket(ticket)
		else:
			print(CorporateVoice.get_formatted_phrase("ticket_script_load_failed", {"path": ticket_path}))
	else:
		print(CorporateVoice.get_formatted_phrase("ticket_script_not_found", {"path": ticket_path}))

func _load_initial_tickets():
	print("📋 Loading initial tickets...")
	
	# Load all tickets from the library
	for ticket_path in ticket_library:
		if ResourceLoader.exists(ticket_path):
			print("  ✓ Found ticket script at: ", ticket_path)
			var TicketScript = load(ticket_path)
			if TicketScript:
				var ticket = TicketScript.new()
				
				print("  - Ticket ID: ", ticket.ticket_id)
				print("  - Title: ", ticket.title)
				print("  - Severity: ", ticket.severity)
				print("  - Required Tool: ", ticket.required_tool)
				
				add_ticket(ticket)
			else:
				print("  ❌ ERROR: Failed to load ticket script: ", ticket_path)
		else:
			print("  ❌ ERROR: Ticket script not found at: ", ticket_path)
	
	print("📋 Total tickets loaded: ", active_tickets.size())


func add_ticket(ticket: TicketResource):
	if not ticket:
		print(CorporateVoice.get_phrase("adding_null_ticket_error"))
		return
	
	# Check if already in queue
	for existing_ticket in active_tickets:
		if existing_ticket.ticket_id == ticket.ticket_id:
			print(CorporateVoice.get_formatted_phrase("ticket_already_in_queue_warning", {"ticket_id": ticket.ticket_id}))
			return
	
	# Set spawn time for metrics
	ticket.spawn_timestamp = Time.get_ticks_msec()
	
	# Add to active tickets
	active_tickets.append(ticket)
	
	print("========================================")
	print("📋 " + CorporateVoice.get_phrase("new_ticket_added_header"))
	print("  ID: ", ticket.ticket_id)
	print("  Title: ", ticket.title)
	print("  Severity: ", ticket.severity)
	print("  Category: ", ticket.category)
	print("  Time: ", ticket.base_time, " seconds")
	print("  Steps: ", ticket.steps.size())
	print("========================================")
	
	# Emit signal for UI to update
	ticket_added.emit(ticket)

func complete_ticket(ticket_id: String, completion_type: String = "compliant"):
	# Valid completion types: "compliant", "efficient", "emergency"
	if completion_type not in ["compliant", "efficient", "emergency"]:
		print(CorporateVoice.get_phrase("invalid_completion_type_warning"))
		completion_type = "compliant"
	
	for i in range(active_tickets.size()):
		var ticket = active_tickets[i]
		if ticket.ticket_id == ticket_id:
			# Calculate time taken
			var time_taken = (Time.get_ticks_msec() - ticket.spawn_timestamp) / 1000.0
			
			# Move to completed
			active_tickets.remove_at(i)
			completed_tickets.append(ticket)
			
			print("========================================")
			print("✓ " + CorporateVoice.get_phrase("ticket_completed_header"))
			print("  ID: ", ticket_id)
			print("  Type: ", completion_type)
			print("  Time Taken: %.1fs" % time_taken)
			print("========================================")
			
			# Emit signal with completion type and time
			ticket_completed.emit(ticket, completion_type, time_taken)
			
			# Trigger consequence engine if it exists
			if ConsequenceEngine:
				# This log is more for emergent consequences, not the archetype
				# We pass the ticket so it can check for hidden risks
				ConsequenceEngine.log_ticket_completion(ticket_id, completion_type, ticket, 0.0) # time_remaining is deprecated
			
			return
	
	print(CorporateVoice.get_formatted_phrase("ticket_not_found_for_completion_warning", {"ticket_id": ticket_id}))

func get_active_tickets() -> Array[TicketResource]:
	print(CorporateVoice.get_formatted_phrase("getting_active_tickets_count", {"count": active_tickets.size()}))
	return active_tickets


func get_ticket_by_id(ticket_id: String) -> TicketResource:
	for ticket in active_tickets:
		if ticket.ticket_id == ticket_id:
			return ticket
	
	print(CorporateVoice.get_formatted_phrase("ticket_not_found_by_id", {"ticket_id": ticket_id}))
	return null

func has_active_tickets() -> bool:
	return active_tickets.size() > 0

func get_ticket_count() -> int:
	return active_tickets.size()

# Optional: Add a new random ticket from the library
func spawn_random_ticket():
	if ticket_library.is_empty():
		print(CorporateVoice.get_phrase("no_tickets_in_library_warning"))
		return
	
	var random_path = ticket_library.pick_random()
	
	if ResourceLoader.exists(random_path):
		var TicketScript = load(random_path)
		var ticket = TicketScript.new()
		add_ticket(ticket)
	else:
		print(CorporateVoice.get_formatted_phrase("ticket_script_not_found", {"path": random_path}))

func attach_log_to_ticket(ticket_id: String, log_id: String) -> bool:
	# Attach a log to a ticket as evidence
	var ticket = get_ticket_by_id(ticket_id)
	if not ticket:
		print(CorporateVoice.get_formatted_phrase("cannot_attach_log_ticket_not_found", {"ticket_id": ticket_id}))
		return false
	
	if ticket.attach_log(log_id):
		print(CorporateVoice.get_formatted_phrase("log_attached_success", {"log_id": log_id, "ticket_id": ticket_id}))
		log_attached.emit(ticket_id, log_id)
		return true
	else:
		print(CorporateVoice.get_formatted_phrase("log_already_attached_warning", {"log_id": log_id, "ticket_id": ticket_id}))
		return false

func get_ticket_evidence(ticket_id: String) -> Dictionary:
	# Get evidence count for a ticket
	var ticket = get_ticket_by_id(ticket_id)
	if not ticket:
		return {"attached": 0, "required": 0}
	return ticket.get_evidence_count()

# Process ticket timers
func _process(delta):
	for ticket in active_tickets:
		if ticket.base_time > 0:
			ticket.base_time -= delta
			
			if ticket.base_time <= 0:
				print(CorporateVoice.get_formatted_phrase("ticket_timeout", {"ticket_id": ticket.ticket_id}))
				ticket_timeout.emit(ticket.ticket_id)
				complete_ticket(ticket.ticket_id, "timeout")
				break  # Exit loop since we modified the array

func _on_terminal_command_run(command_name: String, args: Array):
	if command_name == "isolate" and not args.is_empty():
		var isolated_host = args[0].to_upper()
		
		# Specifically check for the malware containment ticket solution
		var ticket_to_complete = null
		for ticket in active_tickets:
			if ticket.ticket_id == "MALWARE-CONTAIN-001":
				# This ticket is solved by isolating WORKSTATION-45
				if isolated_host == "WORKSTATION-45":
					ticket_to_complete = ticket
					break
		
		if ticket_to_complete:
			print(CorporateVoice.get_phrase("ticket_update_host_isolated"))
			# Complete the ticket as compliant for now. 
			# A more advanced system could check if other steps were completed.
			complete_ticket(ticket_to_complete.ticket_id, "compliant")
