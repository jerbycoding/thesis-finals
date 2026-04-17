# TicketManager.gd
# Autoload singleton that manages all tickets in the game
extends Node

# === SOLO DEV PHASE 2: ROLE GUARD ===
# ROLE GUARD: This manager must not attach hacker actions to Analyst tickets.
# Hacker campaign has its own systems (HackerHistory, TraceLevelManager).
# Do not connect to 'offensive_action_performed' signal here.
# ================================

var active_tickets: Array[TicketResource] = []
var completed_tickets: Array[TicketResource] = []
var active_timers: Dictionary = {} # ticket_id: Timer

const TICKET_DIR = "res://resources/tickets/"

# --- Ambient Noise Configuration ---
var noise_library: Array[TicketResource] = []
var ticket_library: Array[TicketResource] = [] # Unique list of all discovered tickets
var ambient_spawn_timer: Timer
var ambient_spawn_interval: float = 120.0 # Seconds between noise tickets
var max_active_tickets: int = 5
var is_ambient_spawning_enabled: bool = false
# ----------------------------------

var ticket_id_map: Dictionary = {} # Standardized ID -> Resource

func _ready():
	print("========================================")
	print("TicketManager initialized")
	print("========================================")
	
	# Setup Ambient Spawner
	ambient_spawn_timer = Timer.new()
	ambient_spawn_timer.wait_time = ambient_spawn_interval
	ambient_spawn_timer.timeout.connect(_on_ambient_spawn_timeout)
	add_child(ambient_spawn_timer)
	
	# Discover all tickets
	_prepare_library()
	
	# Connect to other systems safely after they've had a chance to initialize
	call_deferred("_setup_system_connections")

func _setup_system_connections():
	# Use EventBus for decoupled communication
	EventBus.terminal_command_run.connect(_on_terminal_command_run)
	EventBus.narrative_spawn_ticket.connect(spawn_ticket_by_id)
	EventBus.shift_started.connect(func(_id): 
		if GameState and GameState.is_guided_mode:
			stop_ambient_spawning()
			return
			
		if NarrativeDirector and NarrativeDirector.current_shift_resource:
			if NarrativeDirector.current_shift_resource.minigame_type == "NONE":
				start_ambient_spawning()
			else:
				stop_ambient_spawning()
	)
	EventBus.shift_ended.connect(_on_shift_ended)
	EventBus.campaign_ended.connect(func(_type): 
		stop_ambient_spawning()
		clear_active_data()
	)
	EventBus.email_decision_processed.connect(_on_email_decision_processed)
	EventBus.app_opened.connect(_on_app_opened)
	
	# Listen for followup requests (from ConsequenceEngine)
	EventBus.followup_ticket_creation_requested.connect(add_ticket)

func _on_shift_ended(_results: Dictionary):
	stop_ambient_spawning()
	clear_active_data()
	print("TicketManager: Shift cleanup complete. Queue reset.")

func _on_app_opened(app_name: String, _window_id: String):
	print("TicketManager: App %s opened. Refreshing evidence visibility." % app_name)
	# Re-reveal data for ALL active tickets to ensure the newly opened app has them
	for ticket in active_tickets:
		if app_name == "siem" and LogSystem:
			LogSystem.reveal_logs_for_ticket(ticket.ticket_id)
		elif app_name == "email" and EmailSystem:
			EmailSystem.reveal_emails_for_ticket(ticket.ticket_id)

func start_ambient_spawning():
	if GameState and GameState.is_guided_mode:
		return
		
	var multiplier = 1.0
	if ConfigManager and GlobalConstants:
		var tier = ConfigManager.settings.gameplay.difficulty_level
		var data = GlobalConstants.DIFFICULTY_DATA.get(tier, GlobalConstants.DIFFICULTY_DATA[GlobalConstants.DIFFICULTY.ANALYST])
		multiplier = data.time_mult
		
	var final_interval = ambient_spawn_interval * multiplier
	print("TicketManager: Ambient noise spawning STARTED. Interval: %.1fs" % final_interval)
	
	is_ambient_spawning_enabled = true
	if is_instance_valid(ambient_spawn_timer):
		ambient_spawn_timer.start(final_interval)

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
	
	var loaded_tickets = FileUtil.load_and_validate_resources(TICKET_DIR, "TicketResource")
	
	for res in loaded_tickets:
		# 1. Map by Ticket ID (Primary key)
		var tid = res.ticket_id.to_lower()
		ticket_id_map[tid] = res
		
		# 2. Map by Clean Filename (Secondary key for narrative convenience)
		var file_id = res.resource_path.get_file().get_basename().replace("Ticket", "").to_lower().trim_prefix("_")
		ticket_id_map[file_id] = res
		
		ticket_library.append(res)
		
		# 3. Add to noise pool if flag is set
		if res.is_ambient_noise:
			noise_library.append(res)
		
		print("  - Registered Ticket: %s (Map keys: %s, %s)" % [res.ticket_id, tid, file_id])
			
	print("🎫 TICKET_DEBUG: Library ready. %d tickets registered." % ticket_id_map.size())

func _on_email_decision_processed(email: EmailResource, decision: String, _state: Dictionary):
	if email.is_malicious and decision == GlobalConstants.EMAIL_DECISION.QUARANTINE:
		if not email.related_ticket.is_empty():
			print("TicketManager: Task for ticket %s completed via Email Quarantine." % email.related_ticket)

func load_state(active_ids: Array, completed_ids: Array):
	active_tickets.clear()
	for timer in active_timers.values():
		if is_instance_valid(timer): timer.queue_free()
	active_timers.clear()
	completed_tickets.clear()
	
	# Standardize IDs to ensure they match our internal map
	var standardized_active = []
	for id in active_ids: standardized_active.append(id.to_lower())
	
	var standardized_completed = []
	for id in completed_ids: standardized_completed.append(id.to_lower())
	
	for tid in standardized_active:
		var res = ticket_id_map.get(tid)
		if res:
			var instance = res.duplicate()
			
			# Sprint 13 Fix: Initialize timestamps on load
			# Since we don't store exact remaining time in the save yet, 
			# we reset them to "Freshly Spawned" but difficulty-scaled.
			var base_time = max(0.1, instance.base_time)
			var final_time = HeatManager.get_scaled_time(base_time) if HeatManager else base_time
			
			instance.spawn_timestamp = ShiftClock.elapsed_seconds
			instance.expiry_timestamp = instance.spawn_timestamp + final_time
			
			active_tickets.append(instance)
			_create_ticket_timer(instance)
			
			# RE-SEED EVIDENCE VISIBILITY (Fixes Ghost Queue bug)
			_reveal_evidence_for_ticket(instance)
			_apply_procedural_network_state(instance)
	
	for tid in standardized_completed:
		var res = ticket_id_map.get(tid)
		if res:
			completed_tickets.append(res.duplicate())
	
	print("TicketManager state loaded. Active: %d, Completed: %d" % [active_tickets.size(), completed_tickets.size()])

func _create_ticket_timer(ticket: TicketResource):
	if active_timers.has(ticket.ticket_id):
		var old = active_timers[ticket.ticket_id]
		if is_instance_valid(old): old.queue_free()
	
	var base_time = max(0.1, ticket.base_time)
	var final_time = HeatManager.get_scaled_time(base_time) if HeatManager else base_time
	
	if GameState and GameState.is_guided_mode:
		final_time = 99999.0 # Effectively infinite for tutorial
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = final_time
	timer.timeout.connect(_on_ticket_timeout_timer.bind(ticket.ticket_id))
	add_child(timer)
	timer.start()
	
	active_timers[ticket.ticket_id] = timer

func _get_ticket_path_by_id(ticket_id: String) -> String:
	var res = ticket_id_map.get(ticket_id.to_lower())
	return res.resource_path if res else ""

func spawn_ticket_by_id(ticket_id: String):
	var lookup_id = ticket_id.to_lower()
	if not ticket_id_map.has(lookup_id):
		push_error("TicketManager: Ticket ID '%s' not found. Spawning emergency fallback." % ticket_id)
		_spawn_fallback_error_ticket(ticket_id)
		return

	var ticket_res = ticket_id_map[lookup_id]
	add_ticket(ticket_res.duplicate())

func _spawn_fallback_error_ticket(original_id: String):
	var fallback = TicketResource.new()
	fallback.ticket_id = "SYS-ERR-" + str(randi() % 999)
	fallback.title = "CRITICAL: Narrative Sequence Error"
	fallback.description = "URGENT: Ticket [" + original_id + "] not found. Please resolve via Emergency protocol."
	fallback.severity = "Critical"
	fallback.category = "System"
	fallback.base_time = 60.0
	fallback.steps = ["Acknowledge Narrative Failure", "Perform Emergency Override"]
	fallback.required_tool = "none"
	add_ticket(fallback)

func clear_active_data():
	print("📋 TicketManager: Purging all active tickets and timers.")
	for tid in active_timers:
		var timer = active_timers[tid]
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
	active_timers.clear()
	active_tickets.clear()
	completed_tickets.clear()
	
	if TerminalSystem:
		TerminalSystem.clear_all_connections()

func add_ticket(ticket: TicketResource):
	if not ticket or not ticket.validate():
		push_error("TicketManager: Rejected invalid ticket resource.")
		return
	
	# 1. GENERATE TRUTH PACKET IMMEDIATELY
	if VariableRegistry and ticket.truth_packet.is_empty():
		var context = HeatManager.pop_vulnerability() if HeatManager else {}
		if not context.is_empty() and ticket.category in ["Malware", "Data Breach", "Ransomware"]:
			ticket.truth_packet = VariableRegistry.generate_truth_packet(ticket.ticket_id)
			ticket.truth_packet["attacker_ip"] = context.attacker_ip
			ticket.truth_packet["ip"] = context.attacker_ip # Sync Alias
			ticket.truth_packet["victim_host"] = context.victim_host
			ticket.truth_packet["host"] = context.victim_host # Sync Alias
			ticket.truth_packet["inherited_from"] = context.original_id
		else:
			ticket.truth_packet = VariableRegistry.generate_truth_packet(ticket.ticket_id)

	# 2. CHECK FOR DUPLICATES
	for t in active_tickets:
		if t.ticket_id == ticket.ticket_id: return
	
	# 3. SET TIMESTAMPS (Sprint 13 Fix: Use Scaled Time)
	var base_time = max(0.1, ticket.base_time)
	var final_time = HeatManager.get_scaled_time(base_time) if HeatManager else base_time
	
	ticket.spawn_timestamp = ShiftClock.elapsed_seconds
	ticket.expiry_timestamp = ticket.spawn_timestamp + final_time
	
	active_tickets.append(ticket)
	_create_ticket_timer(ticket)
	EventBus.ticket_added.emit(ticket)
	
	_reveal_evidence_for_ticket(ticket)
	_apply_procedural_network_state(ticket)

func _reveal_evidence_for_ticket(ticket: TicketResource):
	if EmailSystem:
		EmailSystem.reveal_emails_for_ticket(ticket.ticket_id)
		for email in EmailSystem.get_emails_for_ticket(ticket.ticket_id):
			email.truth_packet = ticket.truth_packet
	
	if LogSystem:
		LogSystem.reveal_logs_for_ticket(ticket.ticket_id)
		for log in LogSystem.get_logs_for_ticket(ticket.ticket_id):
			log.truth_packet = ticket.truth_packet

func _apply_procedural_network_state(ticket: TicketResource):
	if NetworkState and not ticket.truth_packet.is_empty():
		var victim = ticket.truth_packet.get("victim_host", "")
		var attacker = ticket.truth_packet.get("attacker_ip", "")
		
		# Validation Authority: Only bridge if host exists in corporate inventory
		if not victim.is_empty() and victim != "WS-UNKNOWN":
			if ticket.category in ["Malware", "Ransomware"]:
				NetworkState.update_host_state(victim, {"status": "INFECTED"})
			
			if TerminalSystem and not attacker.is_empty():
				TerminalSystem.register_connection(victim, attacker)

func _on_ticket_timeout_timer(ticket_id: String):
	var active_ticket = get_ticket_by_id(ticket_id)
	if active_ticket:
		print(CorporateVoice.get_formatted_phrase("ticket_timeout", {"ticket_id": ticket_id}))
		EventBus.ticket_timeout.emit(ticket_id)
		EventBus.ticket_ignored.emit(active_ticket)
		complete_ticket(ticket_id, GlobalConstants.COMPLETION_TYPE.TIMEOUT)

func complete_ticket(ticket_id: String, completion_type: String = "compliant"):
	if completion_type not in [GlobalConstants.COMPLETION_TYPE.COMPLIANT, GlobalConstants.COMPLETION_TYPE.EFFICIENT, GlobalConstants.COMPLETION_TYPE.EMERGENCY, GlobalConstants.COMPLETION_TYPE.TIMEOUT]:
		completion_type = GlobalConstants.COMPLETION_TYPE.COMPLIANT
	
	if active_timers.has(ticket_id):
		var timer = active_timers[ticket_id]
		if is_instance_valid(timer): timer.queue_free()
		active_timers.erase(ticket_id)

	for i in range(active_tickets.size()):
		var ticket = active_tickets[i]
		if ticket.ticket_id == ticket_id:
			# Cleanup Forensic Bridge before removal
			if TerminalSystem and not ticket.truth_packet.is_empty():
				var victim = ticket.truth_packet.get("victim_host", "")
				var attacker = ticket.truth_packet.get("attacker_ip", "")
				TerminalSystem.unregister_connection(victim, attacker)

			if completion_type == GlobalConstants.COMPLETION_TYPE.COMPLIANT and not ValidationManager.can_complete_compliant(ticket):
				completion_type = GlobalConstants.COMPLETION_TYPE.EFFICIENT

			var time_taken = ShiftClock.elapsed_seconds - ticket.spawn_timestamp
			active_tickets.remove_at(i)
			completed_tickets.append(ticket)
			
			print("✓ Ticket Completed: %s (%s) in %.1fs" % [ticket_id, completion_type, time_taken])
			EventBus.ticket_completed.emit(ticket, completion_type, time_taken)
			
			# Broadcast reward event for external systems (e.g. ConsequenceEngine)
			if completion_type in [GlobalConstants.COMPLETION_TYPE.EFFICIENT, GlobalConstants.COMPLETION_TYPE.EMERGENCY]:
				var reward_duration = 60.0 if completion_type == GlobalConstants.COMPLETION_TYPE.EFFICIENT else 120.0
				pause_ambient_spawning(reward_duration)
			return

func get_active_tickets() -> Array[TicketResource]:
	return active_tickets

func get_ticket_by_id(ticket_id: String) -> TicketResource:
	for t in active_tickets:
		if t.ticket_id == ticket_id: return t
	return null

func has_active_tickets() -> bool:
	return active_tickets.size() > 0

func attach_log_to_ticket(ticket_id: String, log_id: String) -> bool:
	var ticket = get_ticket_by_id(ticket_id)
	if ticket and ticket.attach_log(log_id):
		if NotificationManager:
			NotificationManager.show_notification("Log evidence attached to " + ticket_id, "success")
		EventBus.log_attached_to_ticket.emit(ticket_id, log_id)
		return true
	return false

func detach_log_from_ticket(ticket_id: String, log_id: String) -> bool:
	var ticket = get_ticket_by_id(ticket_id)
	if ticket and ticket.detach_log(log_id):
		EventBus.log_detached_from_ticket.emit(ticket_id, log_id)
		return true
	return false

func submit_root_cause(ticket_id: String, value: String):
	var ticket = get_ticket_by_id(ticket_id)
	if ticket:
		ticket.input_root_cause = value
		print("TicketManager: Root Cause submitted for %s: %s" % [ticket_id, value])
		# Signal that the ticket state has changed (UI will refresh the 'Close' button)
		EventBus.ticket_state_updated.emit(ticket)

func _on_terminal_command_run(command_name: String, args: Array):
	if args.is_empty(): return
	var target_host = args[0].to_upper()
	
	for ticket in active_tickets:
		var req_iso = ticket.required_host_isolation
		var req_res = ticket.required_host_restoration
		
		# Resolve placeholders in requirements
		if req_iso.begins_with("{") and not ticket.truth_packet.is_empty(): req_iso = req_iso.format(ticket.truth_packet)
		if req_res.begins_with("{") and not ticket.truth_packet.is_empty(): req_res = req_res.format(ticket.truth_packet)
		
		if command_name == "isolate" and req_iso != "" and target_host == req_iso.to_upper():
			ticket.is_technically_fulfilled = true
			print("TicketManager: Technical requirement met for %s (Host Isolated)." % ticket.ticket_id)
			
		elif command_name == "restore" and req_res != "" and target_host == req_res.to_upper():
			ticket.is_technically_fulfilled = true
			print("TicketManager: Technical requirement met for %s (Host Restored)." % ticket.ticket_id)
