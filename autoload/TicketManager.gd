# TicketManager.gd
# Autoload singleton that manages all tickets in the game
extends Node

signal ticket_added(ticket: TicketResource)
signal ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float)
signal ticket_timeout(ticket_id: String)
signal ticket_ignored(ticket: TicketResource)
signal log_attached(ticket_id: String, log_id: String)

var active_tickets: Array[TicketResource] = []
var completed_tickets: Array[TicketResource] = []
var active_timers: Dictionary = {} # ticket_id: Timer

# Ticket library - preloaded .tres resources
var ticket_library: Array[TicketResource] = [
	preload("res://resources/tickets/TicketPhishing01.tres"),
	preload("res://resources/tickets/TicketSpearPhish.tres"),
	preload("res://resources/tickets/TicketMalwareContainment.tres"),
	preload("res://resources/tickets/TicketDataExfiltration.tres"),
	preload("res://resources/tickets/TicketRansomware01.tres"),
	preload("res://resources/tickets/TicketInsiderThreat01.tres"),
	preload("res://resources/tickets/TicketSocialEng01.tres"),
]

# A mapping from simple narrative IDs to full resources
var ticket_id_map: Dictionary = {
	"phishing_intro": preload("res://resources/tickets/TicketSpearPhish.tres"),
	"spear_phishing": preload("res://resources/tickets/TicketSpearPhish.tres"),
	"malware_response": preload("res://resources/tickets/TicketMalwareContainment.tres"),
	"data_exfil": preload("res://resources/tickets/TicketDataExfiltration.tres"),
	"phishing_campaign": preload("res://resources/tickets/TicketPhishing01.tres"),
	"insider_001": preload("res://resources/tickets/TicketInsiderThreat01.tres"),
	"social_001": preload("res://resources/tickets/TicketSocialEng01.tres"),
	"ransom_001": preload("res://resources/tickets/TicketRansomware01.tres"),
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

	if EmailSystem:
		EmailSystem.email_decision_processed.connect(_on_email_decision_processed)
		print("TicketManager connected to EmailSystem")

	if ConsequenceEngine:
		ConsequenceEngine.followup_ticket_creation_requested.connect(add_ticket)
		print("TicketManager connected to ConsequenceEngine")
	
	# Load initial tickets for testing - DISABLED in favor of narrative control
	# _load_initial_tickets()

func _on_email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary):
	# Handles logging or updating state when an email is processed.
	if email.is_malicious and decision == "quarantine":
		if not email.related_ticket.is_empty():
			print("TicketManager: Task for ticket %s completed (Email Quarantined). Manual resolution required." % email.related_ticket)
			# We no longer auto-complete here to allow player strategy choice.


func load_state(active_ids: Array, completed_ids: Array):
	active_tickets.clear()
	# Clean up any existing timers before loading
	for timer in active_timers.values():
		timer.queue_free()
	active_timers.clear()
	
	completed_tickets.clear()
	
	for ticket_id in active_ids:
		var ticket_path = _get_ticket_path_by_id(ticket_id)
		if not ticket_path.is_empty():
			var ticket_res = load(ticket_path)
			if ticket_res and ticket_res is TicketResource:
				var ticket_instance = ticket_res.duplicate()
				if ticket_instance.validate():
					# Use a quiet add, since we don't want to trigger "new ticket" notifications
					active_tickets.append(ticket_instance)
					_create_ticket_timer(ticket_instance)
	
	for ticket_id in completed_ids:
		var ticket_path = _get_ticket_path_by_id(ticket_id)
		if not ticket_path.is_empty():
			var ticket_res = load(ticket_path)
			if ticket_res and ticket_res is TicketResource:
				var ticket_instance = ticket_res.duplicate()
				if ticket_instance.validate():
					completed_tickets.append(ticket_instance)
	
	print("TicketManager state loaded. Active: ", active_tickets.size(), ", Completed: ", completed_tickets.size())

func _create_ticket_timer(ticket: TicketResource):
	# Cleanup existing timer for this ID if it somehow exists
	if active_timers.has(ticket.ticket_id):
		var old_timer = active_timers[ticket.ticket_id]
		if is_instance_valid(old_timer):
			old_timer.queue_free()
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = max(0.1, ticket.base_time)
	timer.timeout.connect(_on_ticket_timeout_timer.bind(ticket.ticket_id))
	add_child(timer)
	timer.start()
	
	active_timers[ticket.ticket_id] = timer

func _get_ticket_path_by_id(ticket_id: String) -> String:
	# First, check the narrative map
	for key in ticket_id_map:
		var ticket_res = ticket_id_map[key]
		if ticket_res and ticket_res.ticket_id == ticket_id:
			return ticket_res.resource_path
			
	# If not in the map, search the full library
	for ticket_res in ticket_library:
		if ticket_res and ticket_res.ticket_id == ticket_id:
			return ticket_res.resource_path
			
	print("ERROR: Could not find ticket path for ID: ", ticket_id)
	return ""

func spawn_ticket_by_id(ticket_id: String):
	var lookup_id = ticket_id.to_lower()
	if not ticket_id_map.has(lookup_id):
		print(CorporateVoice.get_formatted_phrase("ticket_id_not_found_map", {"ticket_id": ticket_id}))
		return

	var ticket_res = ticket_id_map[lookup_id]
	if ticket_res:
		var ticket = ticket_res.duplicate()
		add_ticket(ticket)
	else:
		print(CorporateVoice.get_formatted_phrase("ticket_script_load_failed", {"path": "id_map"}))

func _load_initial_tickets():
	print("📋 Loading initial tickets...")
	
	# Load all tickets from the library
	for ticket_res in ticket_library:
		if ticket_res:
			var ticket = ticket_res.duplicate()
			
			print("  - Ticket ID: ", ticket.ticket_id)
			print("  - Title: ", ticket.title)
			print("  - Severity: ", ticket.severity)
			print("  - Required Tool: ", ticket.required_tool)
			
			add_ticket(ticket)
		else:
			print("  ❌ ERROR: Failed to load ticket resource from library")

	print("📋 Total tickets loaded: ", active_tickets.size())


func add_ticket(ticket: TicketResource):
	if not ticket:
		print(CorporateVoice.get_phrase("adding_null_ticket_error"))
		return
	
	if not ticket.validate():
		if ticket.ticket_id.is_empty():
			push_error("TicketManager: Rejected ticket with missing ID.")
		elif ticket.steps.size() > 3:
			push_error("TicketManager: Rejected ticket %s (Too many steps: %d)." % [ticket.ticket_id, ticket.steps.size()])
		elif ticket.base_time <= 0:
			push_error("TicketManager: Rejected ticket %s (Invalid time: %.1f)." % [ticket.ticket_id, ticket.base_time])
		else:
			push_error("TicketManager: Rejected invalid ticket: " + str(ticket.ticket_id))
		return
	
	# Check if already in queue
	for existing_ticket in active_tickets:
		if existing_ticket.ticket_id == ticket.ticket_id:
			print(CorporateVoice.get_formatted_phrase("ticket_already_in_queue_warning", {"ticket_id": ticket.ticket_id}))
			return
	
	# Set spawn time for metrics
	ticket.spawn_timestamp = Time.get_ticks_msec()
	# Set expiry timestamp for UI display
	ticket.expiry_timestamp = ticket.spawn_timestamp + (ticket.base_time * 1000.0)
	
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
	
	# Create and start the node-based timer
	_create_ticket_timer(ticket)
	
	# Emit signal for UI to update
	ticket_added.emit(ticket)
	
	# Automatically reveal related emails and logs
	if EmailSystem and EmailSystem.has_method("reveal_emails_for_ticket"):
		EmailSystem.reveal_emails_for_ticket(ticket.ticket_id)
	
	if LogSystem and LogSystem.has_method("reveal_logs_for_ticket"):
		LogSystem.reveal_logs_for_ticket(ticket.ticket_id)

func _on_ticket_timeout_timer(ticket_id: String):
	var active_ticket = get_ticket_by_id(ticket_id)
	if active_ticket:
		print(CorporateVoice.get_formatted_phrase("ticket_timeout", {"ticket_id": ticket_id}))
		ticket_timeout.emit(ticket_id)
		ticket_ignored.emit(active_ticket)
		complete_ticket(ticket_id, "timeout")

func complete_ticket(ticket_id: String, completion_type: String = "compliant"):
	# Valid completion types: "compliant", "efficient", "emergency"
	if completion_type not in ["compliant", "efficient", "emergency", "timeout"]:
		print(CorporateVoice.get_phrase("invalid_completion_type_warning"))
		completion_type = "compliant"
	
	# Cleanup the timer if it exists
	if active_timers.has(ticket_id):
		var timer = active_timers[ticket_id]
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
		active_timers.erase(ticket_id)

	for i in range(active_tickets.size()):
		var ticket = active_tickets[i]
		if ticket.ticket_id == ticket_id:
			# --- VALIDATION STEP ---
			# Use central ValidationManager
			if completion_type == "compliant" and not ValidationManager.can_complete_compliant(ticket):
				push_warning("TicketManager: %s attempted compliant completion without evidence. Downgrading." % ticket_id)
				completion_type = "efficient"

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
			# ConsequenceEngine will listen for the ticket_completed signal directly.
			# The direct call has been removed to decouple the singletons.
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
	
	var ticket_res = ticket_library.pick_random()
	
	if ticket_res:
		var ticket = ticket_res.duplicate()
		add_ticket(ticket)
	else:
		# This case should not happen if the library is populated correctly
		print(CorporateVoice.get_formatted_phrase("ticket_script_not_found", {"path": "random"}))


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
			print("TicketManager: Task for ticket %s completed (Host Isolated). Manual resolution required." % ticket_to_complete.ticket_id)
			# We no longer auto-complete here to allow player strategy choice.
