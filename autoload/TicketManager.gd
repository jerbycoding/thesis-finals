# TicketManager.gd
# Autoload singleton that manages all tickets in the game
extends Node

var active_tickets: Array[TicketResource] = []
var completed_tickets: Array[TicketResource] = []
var active_timers: Dictionary = {} # ticket_id: Timer

const TICKET_DIR = "res://resources/tickets/"

# --- Ambient Noise Configuration ---
var noise_library: Array[TicketResource] = []
var ticket_library: Array[TicketResource] = [] # Unique list of all discovered tickets
var ambient_spawn_timer: Timer
var ambient_spawn_interval: float = 45.0 # Seconds between noise tickets
var max_active_tickets: int = 5
var is_ambient_spawning_enabled: bool = false
# ----------------------------------

var ticket_id_map: Dictionary = {} # Narrative ID -> Resource

func _ready():
	print("========================================")
	print("TicketManager initialized")
	print("========================================")
	
	# Setup Ambient Spawner
	ambient_spawn_timer = Timer.new()
	ambient_spawn_timer.wait_time = ambient_spawn_interval
	ambient_spawn_timer.timeout.connect(_on_ambient_spawn_timeout)
	add_child(ambient_spawn_timer)
	
	# Discover all tickets (Internal logic is safe)
	_prepare_library()
	
	# Connect to other systems safely after they've had a chance to initialize
	call_deferred("_setup_system_connections")

func _setup_system_connections():
	# Use EventBus for decoupled communication
	EventBus.terminal_command_run.connect(_on_terminal_command_run)
	EventBus.narrative_spawn_ticket.connect(spawn_ticket_by_id)
	EventBus.shift_started.connect(func(_id): start_ambient_spawning())
	EventBus.shift_ended.connect(func(_r): stop_ambient_spawning())
	EventBus.email_decision_processed.connect(_on_email_decision_processed)
	EventBus.app_opened.connect(_on_app_opened)
	
	# Listen for followup requests (from ConsequenceEngine)
	EventBus.followup_ticket_creation_requested.connect(add_ticket)

func _on_app_opened(app_name: String, _window_id: String):
	print("TicketManager: App %s opened. Refreshing evidence visibility." % app_name)
	# Re-reveal data for ALL active tickets to ensure the newly opened app has them
	for ticket in active_tickets:
		if app_name == "siem" and LogSystem:
			LogSystem.reveal_logs_for_ticket(ticket.ticket_id)
		elif app_name == "email" and EmailSystem:
			EmailSystem.reveal_emails_for_ticket(ticket.ticket_id)

func start_ambient_spawning():
	print("TicketManager: Ambient noise spawning STARTED.")
	is_ambient_spawning_enabled = true
	if is_instance_valid(ambient_spawn_timer):
		ambient_spawn_timer.start()

func stop_ambient_spawning():
	print("TicketManager: Ambient noise spawning STOPPED.")
	is_ambient_spawning_enabled = false
	if is_instance_valid(ambient_spawn_timer):
		ambient_spawn_timer.stop()

func pause_ambient_spawning(duration: float):
	print("TicketManager: Ambient noise spawning PAUSED for ", duration, "s")
	if is_instance_valid(ambient_spawn_timer):
		ambient_spawn_timer.stop()
	get_tree().create_timer(duration).timeout.connect(
		func(): 
			if is_ambient_spawning_enabled and is_instance_valid(ambient_spawn_timer): 
				ambient_spawn_timer.start()
	)

func _on_ambient_spawn_timeout():
	if active_tickets.size() < max_active_tickets:
		_spawn_noise_ticket()

func _spawn_noise_ticket():
	if noise_library.is_empty(): return
	
	var ticket_res = noise_library.pick_random().duplicate()
	# Randomize ID to avoid collision
	ticket_res.ticket_id += "-" + str(randi() % 999)
	
	print("TicketManager: Spawning noise ticket: ", ticket_res.ticket_id)
	add_ticket(ticket_res)

func _prepare_library():
	print("🎫 TICKET_DEBUG: Discovering tickets in %s..." % TICKET_DIR)
	ticket_id_map.clear()
	noise_library.clear()
	ticket_library.clear()
	
	var paths = FileUtil.get_resource_paths(TICKET_DIR)
	for path in paths:
		var res = load(path)
		if res and res is TicketResource:
			# Safety check: Skip if resource fails internal validation
			if not res.validate():
				print("  - ❌ TICKET_DEBUG: Skipping malformed resource: %s" % path)
				continue

			# Add to master library
			
			# 1. Map by Ticket ID (e.g. PHISH-001)
			var tid = res.ticket_id.to_lower()
			ticket_id_map[tid] = res
			# Also map with underscores replaced (fuzzy match for ransom_001)
			ticket_id_map[tid.replace("-", "_")] = res
			
			# 2. Map by File Name (narrative ID fallback, e.g. phishing_intro)
			var file_id = path.get_file().get_basename().replace("Ticket", "").to_lower()
			ticket_id_map[file_id] = res
			# Also fuzzy match file name
			ticket_id_map[file_id.replace("_", "-")] = res
			ticket_id_map[file_id.replace("-", "_")] = res
			
			# 3. Add to noise pool if generic
			if "GENERIC" in res.ticket_id:
				noise_library.append(res)
				print("  - Added to Noise Pool: %s" % res.ticket_id)
			
			print("  - Registered Ticket: %s" % res.ticket_id)
			
	print("🎫 TICKET_DEBUG: Registered %d map entries and %d noise tickets." % [ticket_id_map.size(), noise_library.size()])

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
	
	var base_time = max(0.1, ticket.base_time)
	var final_time = base_time
	
	# HEAT SCALING: Reduce time allowed based on week
	if HeatManager:
		final_time = HeatManager.get_scaled_time(base_time)
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = final_time
	timer.timeout.connect(_on_ticket_timeout_timer.bind(ticket.ticket_id))
	add_child(timer)
	timer.start()
	
	active_timers[ticket.ticket_id] = timer

func _get_ticket_path_by_id(ticket_id: String) -> String:
	# First, check the map (case-insensitive)
	var lookup = ticket_id.to_lower()
	if ticket_id_map.has(lookup):
		return ticket_id_map[lookup].resource_path
			
	# If not in the map, search the full library explicitly
	for ticket_res in ticket_library:
		if ticket_res and ticket_res.ticket_id == ticket_id:
			return ticket_res.resource_path
			
	print("ERROR: Could not find ticket path for ID: ", ticket_id)
	return ""

func spawn_ticket_by_id(ticket_id: String):
	var lookup_id = ticket_id.to_lower()
	if not ticket_id_map.has(lookup_id):
		push_error("TicketManager: Ticket ID '%s' not found. Spawning emergency fallback." % ticket_id)
		_spawn_fallback_error_ticket(ticket_id)
		return

	var ticket_res = ticket_id_map[lookup_id]
	if ticket_res:
		var ticket = ticket_res.duplicate()
		add_ticket(ticket)
	else:
		_spawn_fallback_error_ticket(ticket_id)

func _spawn_fallback_error_ticket(original_id: String):
	var fallback = TicketResource.new()
	fallback.ticket_id = "SYS-ERR-" + str(randi() % 999)
	fallback.title = "CRITICAL: Narrative Sequence Error"
	fallback.description = "URGENT: The SOC Narrative Director requested a ticket that does not exist: [" + original_id + "].\n\nThis is a system-level anomaly. Resolve this ticket immediately using 'Emergency' protocol to bypass and resume normal operations."
	fallback.severity = "Critical"
	fallback.category = "System"
	fallback.base_time = 60.0
	fallback.steps = ["Acknowledge Narrative Failure", "Perform Emergency Override"]
	fallback.required_tool = "none"
	add_ticket(fallback)

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
	
	# PROCEDURAL TRUTH: Generate packet if empty
	if VariableRegistry and ticket.truth_packet.is_empty():
		# INHERITANCE CHECK: If this is an escalation-type ticket, try to pull from the buffer
		var inherited_context = {}
		if ticket.category in ["Malware", "Data Breach", "Ransomware"] and HeatManager:
			inherited_context = HeatManager.pop_vulnerability()
		
		if not inherited_context.is_empty():
			# Reuse attacker and victim host from previous mistake
			ticket.truth_packet = VariableRegistry.generate_truth_packet(ticket.ticket_id)
			ticket.truth_packet["attacker_ip"] = inherited_context.attacker_ip
			ticket.truth_packet["victim_host"] = inherited_context.victim_host
			ticket.truth_packet["inherited_from"] = inherited_context.original_id
			print("⛓ INHERITANCE: Ticket %s inherited threat data from %s" % [ticket.ticket_id, inherited_context.original_id])
		else:
			ticket.truth_packet = VariableRegistry.generate_truth_packet(ticket.ticket_id)
	
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
	
	# GLOBAL EMIT
	EventBus.ticket_added.emit(ticket)
	
	# Automatically reveal related emails and logs
	if EmailSystem and EmailSystem.has_method("reveal_emails_for_ticket"):
		EmailSystem.reveal_emails_for_ticket(ticket.ticket_id)
		# PROCEDURAL TRUTH: Inject context into the tools' backend resources
		for email in EmailSystem.get_emails_for_ticket(ticket.ticket_id):
			email.truth_packet = ticket.truth_packet
	
	if LogSystem and LogSystem.has_method("reveal_logs_for_ticket"):
		LogSystem.reveal_logs_for_ticket(ticket.ticket_id)
		for log in LogSystem.get_logs_for_ticket(ticket.ticket_id):
			log.truth_packet = ticket.truth_packet

func _on_ticket_timeout_timer(ticket_id: String):
	var active_ticket = get_ticket_by_id(ticket_id)
	if active_ticket:
		print(CorporateVoice.get_formatted_phrase("ticket_timeout", {"ticket_id": ticket_id}))
		EventBus.ticket_timeout.emit(ticket_id)
		EventBus.ticket_ignored.emit(active_ticket)
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
			
			# GLOBAL EMIT
			EventBus.ticket_completed.emit(ticket, completion_type, time_taken)
			
			# --- Response Buffer Rewards ---
			if completion_type == "efficient":
				print("TicketManager: Efficient reward - Pausing noise for 60s.")
				pause_ambient_spawning(60.0)
			elif completion_type == "emergency":
				print("TicketManager: Emergency reward - System Lockdown for 120s.")
				# Lockdown pauses ambient noise AND blocks narrative spawns (if we add a check)
				pause_ambient_spawning(120.0)
				# We could add a 'lockdown' flag here if we want to block NarrativeDirector
			
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
		# Concise notification
		print(CorporateVoice.get_formatted_phrase("log_attached_success", {"log_id": log_id, "ticket_id": ticket_id}))
		if NotificationManager:
			NotificationManager.show_notification(CorporateVoice.get_notification("log_attached") + " to " + ticket_id, "success")
		
		# GLOBAL EMIT
		EventBus.log_attached_to_ticket.emit(ticket_id, log_id)
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
				# This ticket is solved by isolating the defined source host
				if isolated_host == NetworkState.HOSTS.MALWARE_SOURCE:
					ticket_to_complete = ticket
					break
		
		if ticket_to_complete:
			print(CorporateVoice.get_phrase("ticket_update_host_isolated"))
			print("TicketManager: Task for ticket %s completed (Host Isolated). Manual resolution required." % ticket_to_complete.ticket_id)
			# We no longer auto-complete here to allow player strategy choice.
