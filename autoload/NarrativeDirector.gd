# NarrativeDirector.gd
# This autoload singleton manages the scripted story flow,
# coordinating NPC interactions, ticket spawns, and consequences.
extends Node

# Preload custom resource classes for type hints
const HackerShiftResource = preload("res://scripts/resources/HackerShiftResource.gd")

var current_shift_name: String = ""
var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

const ENDING_SCENES = {
	"fired": "res://scenes/ui/endings/Ending_Fired.tscn",
	"bankrupt": "res://scenes/ui/endings/Ending_Bankrupt.tscn",
	"victory": "res://scenes/ui/endings/Ending_Promotion.tscn"
}

var shift_library: Dictionary = {} # shift_id -> Resource
var current_shift_resource: ShiftResource = null
var current_active_arc: Array = []

const SHIFT_DIR = "res://resources/shifts/"

var shift_start_time: float = 0.0
var last_chaos_time: float = 0.0
var current_event_index: int = 0
var _is_shift_active: bool = false
var event_timer: Timer
var chaos_timer: Timer

# Event Handlers Mapping
@onready var _event_handlers = {
	GlobalConstants.NARRATIVE_EVENT_TYPE.NPC_INTERACTION: _handle_npc_interaction,
	GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_TICKET: _handle_spawn_ticket,
	GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_CONSEQUENCE: _handle_spawn_consequence,
	GlobalConstants.NARRATIVE_EVENT_TYPE.SYSTEM_EVENT: _handle_system_event,
	GlobalConstants.NARRATIVE_EVENT_TYPE.SHIFT_END: _handle_shift_end
}

func is_weekend() -> bool:
	if current_shift_resource:
		return current_shift_resource.minigame_type != "NONE"
	return false

func get_current_floor_requirement() -> int:
	if current_shift_resource:
		return current_shift_resource.required_floor
	return 1 # Default to SOC

# === SOLO DEV PHASE 2: HACKER CAMPAIGN ===
const HACKER_SHIFT_DIR = "res://resources/hacker_shifts/"
var hacker_shift_library: Dictionary = {}  # day_number -> HackerShiftResource
var current_hacker_day: int = 0
var hacker_event_timer: Timer
var active_hacker_events: Array = []
# ============================================

func _ready():
	# Discover all shifts in the folder
	_discover_shifts()
	
	# Discover hacker shifts
	_discover_hacker_shifts()

	# Connect to EventBus for critical failures
	EventBus.narrative_spawn_consequence.connect(func(id): _trigger_event({"type": GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_CONSEQUENCE, "consequence_id": id}))
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	EventBus.shift_end_requested.connect(func(): _trigger_event({"type": GlobalConstants.NARRATIVE_EVENT_TYPE.SHIFT_END}))
	
	EventBus.campaign_ended.connect(_on_campaign_ended)
	
	# Initialize event timer
	event_timer = Timer.new()
	add_child(event_timer)
	event_timer.one_shot = true
	event_timer.timeout.connect(_on_event_timer_timeout)
	
	# Initialize hacker event timer (0.5s polling loop)
	hacker_event_timer = Timer.new()
	add_child(hacker_event_timer)
	hacker_event_timer.wait_time = 0.5
	hacker_event_timer.timeout.connect(_on_hacker_event_tick)

	# Initialize chaos timer
	chaos_timer = Timer.new()
	add_child(chaos_timer)
	chaos_timer.timeout.connect(_on_chaos_tick)

func _on_chaos_tick():
	if not _is_shift_active or not current_shift_resource:
		return
		
	if current_shift_resource.random_event_pool.is_empty():
		return
		
	# SAFETY: Global 30s cooldown between any random events
	var time_since_chaos = ShiftClock.elapsed_seconds - last_chaos_time
	if time_since_chaos < 30.0:
		return

	# 35% chance to trigger a random event every tick
	if randf() < 0.35:
		var event = current_shift_resource.random_event_pool.pick_random()
		print("🎲 CHAOS ENGINE: Triggering random event: ", event.get("event", "Unnamed"))
		last_chaos_time = ShiftClock.elapsed_seconds
		_trigger_event(event)

func _discover_shifts():
	print("🎬 NARRATIVE_DEBUG: Discovering shifts in %s..." % SHIFT_DIR)
	shift_library.clear()
	
	var loaded_shifts = FileUtil.load_and_validate_resources(SHIFT_DIR, "ShiftResource")
	
	for res in loaded_shifts:
		if shift_library.has(res.shift_id):
			print("  - ⚠ NARRATIVE_DEBUG: Duplicate Shift ID '%s' found in %s. Skipping." % [res.shift_id, res.resource_path])
			continue
			
		shift_library[res.shift_id] = res
		print("  - Registered Shift: %s" % res.shift_id)
		
	print("🎬 NARRATIVE_DEBUG: Library ready: %d shifts." % shift_library.size())

func _discover_hacker_shifts():
	print("🎬 HACKER: Discovering shifts in %s..." % HACKER_SHIFT_DIR)
	hacker_shift_library.clear()

	var dir = DirAccess.open(HACKER_SHIFT_DIR)
	if not dir:
		print("  ⚠ HACKER: Shift directory not found: %s" % HACKER_SHIFT_DIR)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path = HACKER_SHIFT_DIR + file_name
			var res = load(full_path)
			if res is HackerShiftResource and res.validate():
				hacker_shift_library[res.day_number] = res
				print("  ✓ Loaded Day %d: %d contracts, %d honeypots" % [res.day_number, res.contract_ids.size(), res.honeypot_hosts.size()])
		file_name = dir.get_next()
	dir.list_dir_end()

	print("🎬 HACKER: Library ready: %d days." % hacker_shift_library.size())

func prepare_shift(shift_id: String):
	if not shift_library.has(shift_id):
		push_error("NarrativeDirector: Cannot prepare unknown shift ID: " + shift_id)
		return
		
	var shift_res = shift_library[shift_id]
	current_shift_resource = shift_res # Set resource early for Debug/UI
	print("NarrativeDirector: Preparing shift: ", shift_id)
	
	# DECISION LOGIC: 
	# If the shift has a briefing dialogue, we trigger THAT. 
	# If not, we start the live shift timers immediately.
	if shift_res.briefing_dialogue_id != "" and shift_res.briefing_dialogue_id != "default":
		print("NarrativeDirector: Shift requires briefing. Triggering...")
		trigger_briefing(shift_id)
	else:
		print("NarrativeDirector: No briefing required. Starting live shift.")
		start_shift(shift_id)

func start_shift(shift_id: String):
	print("NarrativeDirector: Attempting to start shift: ", shift_id)
	
	if not shift_library.has(shift_id):
		push_error("NarrativeDirector: Shift ID '%s' not found in library!" % shift_id)
		return
		
	current_shift_resource = shift_library[shift_id]
	current_shift_name = shift_id
	current_active_arc = current_shift_resource.event_sequence.duplicate()

	_is_shift_active = true
	shift_start_time = ShiftClock.elapsed_seconds
	current_event_index = 0
	
	EventBus.shift_started.emit(shift_id)
	
	_schedule_next_event()
	
	# Start chaos engine
	var base_interval = 45.0
	if ConfigManager and GlobalConstants:
		var tier = ConfigManager.settings.gameplay.difficulty_level
		var multipliers = GlobalConstants.DIFFICULTY_DATA.get(tier, GlobalConstants.DIFFICULTY_DATA[GlobalConstants.DIFFICULTY.ANALYST])
		base_interval = multipliers.chaos_interval
		
	chaos_timer.start(base_interval)

func trigger_briefing(shift_id: String):
	if _is_shift_active: 
		print("NarrativeDirector: Briefing blocked - shift already active.")
		return
		
	if not shift_library.has(shift_id):
		push_error("NarrativeDirector: Cannot trigger briefing - Shift ID '%s' unknown." % shift_id)
		return
		
	var shift_res = shift_library[shift_id]
	current_shift_resource = shift_res # Set resource early for Debug/UI
	print("NarrativeDirector: Starting briefing for: ", shift_id)
	
	# Transition to Briefing Room if not already there
	if get_tree().current_scene.name != "BriefingRoom":
		# Use secure login to trigger Dossier phase (Sprint 13 Fix)
		var title = "[ " + shift_res.shift_name.to_upper() + " ]"
		TransitionManager.play_secure_login("res://scenes/3d/BriefingRoom.tscn", shift_id, title)
		await EventBus.transition_completed
		
		# Wait for the CISO to be ready in the new scene
		# We use a lambda to check if the incoming ID matches our target
		var is_ciso_ready = false
		var check_ready = func(id): if id == GlobalConstants.NPC_ID.CISO: is_ciso_ready = true
		EventBus.npc_ready.connect(check_ready)
		
		# Give it up to 2 seconds to load, checking every frame
		var timeout = 2.0
		while not is_ciso_ready and timeout > 0:
			await get_tree().process_frame
			timeout -= get_process_delta_time()
		
		EventBus.npc_ready.disconnect(check_ready)
	
	# Trigger the dialogue via signal
	print("NarrativeDirector: Broadcasting interaction request for CISO: ", shift_res.briefing_dialogue_id)
	EventBus.npc_interaction_requested.emit(GlobalConstants.NPC_ID.CISO, shift_res.briefing_dialogue_id)

func _on_event_timer_timeout():
	if current_event_index < current_active_arc.size():
		var event = current_active_arc[current_event_index]
		_trigger_event(event)
		current_event_index += 1
		_schedule_next_event()

func _schedule_next_event():
	if not _is_shift_active:
		return
		
	if current_event_index < current_active_arc.size():
		var next_event = current_active_arc[current_event_index]
		
		# TUTORIAL SAFETY: If we are in the tutorial, do not proceed to 'shift_end' 
		# until the TutorialManager says we are finished.
		if TutorialManager and TutorialManager.is_tutorial_active:
			if next_event.get("type") == GlobalConstants.NARRATIVE_EVENT_TYPE.SHIFT_END:
				# Keep the shift open until the final debrief is COMPLETED (not just reached)
				if TutorialManager.current_step_index < TutorialManager.sequence.steps.size() - 1:
					return

		if next_event.has("time"):
			var current_elapsed = get_shift_timer()
			var delay = max(0.01, next_event.time - current_elapsed)
			event_timer.start(delay)
		else:
			# Event doesn't have a time (might be manual), skip for now
			current_event_index += 1
			_schedule_next_event()

func stop_shift():
	print("NarrativeDirector: Shift has ended.")
	_is_shift_active = false
	event_timer.stop()
	chaos_timer.stop()

# === SOLO DEV PHASE 5: HACKER CAMPAIGN ===

func start_hacker_campaign():
	"""Start the hacker campaign from Day 1."""
	current_hacker_day = 1
	_load_hacker_shift(1)

func _load_hacker_shift(day: int):
	"""Load a specific hacker shift day."""
	if not hacker_shift_library.has(day):
		push_error("NarrativeDirector: No hacker shift for day %d" % day)
		return

	var shift = hacker_shift_library[day]
	current_hacker_day = day

	print("🎬 HACKER: Loading Day %d" % day)

	# Load contracts for this shift
	if ContractManager:
		ContractManager.load_shift_contracts(shift)
		
	# Initialize scripted events
	active_hacker_events = shift.scripted_events.duplicate()
	active_hacker_events.sort_custom(func(a, b): return a.get("time", 0) < b.get("time", 0))

	# Emit shift started signal FIRST (before dialogue)
	if EventBus:
		EventBus.hacker_shift_started.emit(day)
		
	# Start polling loop
	hacker_event_timer.start()

	# Play broker dialogue AFTER shift loads (called externally after transition completes)
	if shift.broker_dialogue_id != "":
		_pending_broker_dialogue = shift.broker_dialogue_id

func _on_hacker_event_tick():
	if GameState.current_role != GameState.Role.HACKER:
		hacker_event_timer.stop()
		return
		
	var current_time = ShiftClock.elapsed_seconds
	
	# Check for scripted events
	while not active_hacker_events.is_empty() and active_hacker_events[0].get("time", 0) <= current_time:
		var event = active_hacker_events.pop_front()
		_trigger_hacker_event(event)

func _trigger_hacker_event(event: Dictionary):
	var type = event.get("type", "")
	print("🎬 HACKER EVENT: ", type)
	
	match type:
		"emergency_patch":
			var hostname = event.get("hostname", "")
			if hostname != "" and NetworkState:
				NetworkState.update_host_state(hostname, {"status": "CLEAN", "scanned": true})
				# Remove from footholds
				if hostname in GameState.hacker_footholds:
					GameState.hacker_footholds.erase(hostname)
					if GameState.current_foothold == hostname:
						GameState.current_foothold = ""
						
				TerminalSystem.inject_system_message("⚠ CRITICAL: Remote connection to %s lost. Host has been patched by system administrator." % hostname)
				
				if HackerHistory:
					HackerHistory.add_entry({
						"action_type": "event_emergency_patch",
						"target": hostname,
						"timestamp": ShiftClock.elapsed_seconds,
						"result": "FOOTHOLD_LOST",
						"note": "Host patched by AI Analyst"
					})
					
		"rival_ai_escalation":
			var state_name = event.get("state", "SEARCHING")
			if RivalAI:
				var state_enum = RivalAI.AIState.get(state_name, RivalAI.AIState.SEARCHING)
				RivalAI.force_state(state_enum)
				
		"broker_message":
			var dialogue_id = event.get("dialogue_id", "")
			if dialogue_id != "":
				start_broker_dialogue(dialogue_id)
				
		"honeypot_reveal":
			var hostname = event.get("hostname", "")
			# Visual only? Or affects mechanics
			TerminalSystem.inject_system_message("🎬 INTEL: Node %s has been identified as a honeypot trap by external reconnaissance." % hostname)

# Store pending dialogue to play after transition
var _pending_broker_dialogue: String = ""

func play_pending_broker_dialogue():
	"""Play the pending broker dialogue if one is queued."""
	if _pending_broker_dialogue != "":
		start_broker_dialogue(_pending_broker_dialogue)
		_pending_broker_dialogue = ""

func start_broker_dialogue(dialogue_id: String):
	"""Start broker dialogue using DialogueManager."""
	if not DialogueManager:
		return

	var path = "res://resources/dialogues/broker/broker_%s.tres" % dialogue_id
	if ResourceLoader.exists(path):
		var res = load(path)
		if res:
			DialogueManager.start_dialogue(null, res)
			print("🎬 HACKER: Broker dialogue started: %s" % dialogue_id)
	else:
		print("⚠ HACKER: Broker dialogue not found: %s" % path)

func advance_hacker_day():
	"""Progress to the next hacker day. Auto-saves before advancing."""
	var current_day = current_hacker_day
	var next_day = current_hacker_day + 1
	
	# Cache current mode to restore after report
	var previous_mode = GameState.current_mode if GameState else 0
	
	# Show Mirror Mode for the day just completed
	_show_mirror_mode(current_day)
	
	# Force mouse visibility for the report
	if GameState: GameState.set_mode(GameState.GameMode.MODE_UI_ONLY)
	
	await EventBus.mirror_mode_closed
	
	# Restore previous mode and hide OS cursor if we are returning to the desktop
	if GameState: 
		GameState.set_mode(previous_mode)
		if previous_mode == GameState.GameMode.MODE_2D:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if next_day > 7:
		print("🎬 HACKER: Campaign complete!")
		# Auto-save at campaign end
		if SaveSystem:
			SaveSystem.save_game()
		return

	# Save before advancing to next day
	if SaveSystem:
		SaveSystem.save_game()

	_load_hacker_shift(next_day)

func _show_mirror_mode(day: int):
	print("🎬 HACKER: Showing Mirror Mode for Day %d" % day)
	var mirror_scene = load("res://scenes/ui/MirrorMode.tscn")
	if mirror_scene:
		# Wrap in high-layer CanvasLayer to ensure it's on top and clickable
		var layer = CanvasLayer.new()
		layer.layer = 120 # Above dialogue (110)
		layer.name = "MirrorModeLayer"
		get_tree().root.add_child(layer)
		
		var mirror_instance = mirror_scene.instantiate()
		layer.add_child(mirror_instance)
		mirror_instance.show_report(day)
		
		# Ensure layer is cleaned up when dashboard is closed
		mirror_instance.tree_exited.connect(func(): layer.queue_free())
	else:
		push_error("NarrativeDirector: Failed to load MirrorMode.tscn")
		# Emit fallback signal so advancement doesn't hang
		EventBus.mirror_mode_closed.emit()
# ============================================

func reset_to_default():
	print("NarrativeDirector: Resetting to default state.")
	stop_shift()
	current_shift_name = ""
	current_shift_resource = null
	current_active_arc.clear()
	current_event_index = 0

func force_random_event():
	# DEBUG: Allow forced events if a resource is loaded, even if not 'active' yet.
	if not current_shift_resource:
		print("NarrativeDirector: Cannot force event - no shift resource loaded.")
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: No shift resource loaded to pull events from.", "error")
		return
		
	if current_shift_resource.random_event_pool.is_empty():
		print("NarrativeDirector: Current shift has no random events.")
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: This shift has an EMPTY random pool.", "warning")
		return
		
	var event = current_shift_resource.random_event_pool.pick_random()
	var event_name = event.get("event", event.get("type", "Unknown Event"))
	
	print("🎲 DEBUG: Manually triggering random event: ", event_name)
	if NotificationManager:
		NotificationManager.show_notification("DEBUG: Triggered [" + event_name + "]", "info")
		
	_trigger_event(event)

func get_shift_timer() -> float:
	if not _is_shift_active:
		return 0.0
	return ShiftClock.elapsed_seconds

func is_shift_active() -> bool:
	return _is_shift_active

func get_current_shift_duration() -> float:
	if not current_active_arc or current_active_arc.is_empty():
		return 0.0
	
	# The last event in the arc should be the shift_end
	var last_event = current_active_arc.back()
	if last_event.has("time"):
		return float(last_event.time)
	return 0.0

func _on_critical_consequence(consequence_id: String, _details: Dictionary):
	if consequence_id == GlobalConstants.CONSEQUENCE_ID.DATA_LOSS:
		print("NarrativeDirector: CRITICAL FAILURE detected. Terminating shift.")
		_trigger_event({"type": GlobalConstants.NARRATIVE_EVENT_TYPE.SHIFT_END, "failure_type": "bankrupt"})

func _on_consequence_triggered(consequence_id: String, _details: Dictionary):
	if consequence_id == GlobalConstants.CONSEQUENCE_ID.DATA_LOSS:
		print("NarrativeDirector: CRITICAL FAILURE detected. Terminating shift.")
		_trigger_event({"type": GlobalConstants.NARRATIVE_EVENT_TYPE.SHIFT_END, "failure_type": "bankrupt"})

func _on_campaign_ended(type: String):
	print("NarrativeDirector: Campaign ended with result: ", type)
	
	# Sprint 13 Fix: Force immediate shutdown of narrative logic
	stop_shift()
	reset_to_default()
	
	var scene_path = ENDING_SCENES.get(type, "res://scenes/3d/MainMenu3D.tscn")
	
	if TransitionManager:
		TransitionManager.change_scene_to(scene_path, "", "", true) # Force transition
	else:
		get_tree().change_scene_to_file(scene_path)

func _trigger_event(event_data: Dictionary):
	if event_data.is_empty():
		push_warning("NarrativeDirector: Received empty event dictionary.")
		return

	var type = event_data.get("type", "")
	var event_debug_name = event_data.get("event", type)
	
	if not _event_handlers.has(type):
		push_warning("NarrativeDirector: No handler defined for event type: " + str(type))
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: Unknown event type: " + str(type), "error")
		return

	# CRASH PROTECTION: Validate basic keys based on type before calling handler
	match type:
		GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_TICKET:
			if not event_data.has("ticket_id"):
				push_error("NarrativeDirector: 'spawn_ticket' event missing 'ticket_id'!")
				return
		GlobalConstants.NARRATIVE_EVENT_TYPE.NPC_INTERACTION:
			if not event_data.has("npc_id") or not event_data.has("dialogue_id"):
				push_error("NarrativeDirector: 'npc_interaction' event missing 'npc_id' or 'dialogue_id'!")
				return
		GlobalConstants.NARRATIVE_EVENT_TYPE.SYSTEM_EVENT:
			if not event_data.has("event_id"):
				push_error("NarrativeDirector: 'system_event' event missing 'event_id'!")
				return

	print("NarrativeDirector: Triggering event - ", event_debug_name)
	_event_handlers[type].call(event_data)

# --- Dedicated Event Handlers ---

func _handle_npc_interaction(event_data: Dictionary):
	if GameState.is_in_2d_mode():
		print("NarrativeDirector: NPC interaction triggered. Transitioning to 3D for dialogue.")
		TransitionManager.exit_desktop_mode()
		await EventBus.transition_completed
		# Wait a moment for the camera to settle
		await get_tree().create_timer(0.5).timeout
	
	# 1. Check if the NPC is physically present in the current scene
	var is_npc_present = false
	for node in get_tree().get_nodes_in_group("npcs"):
		if node.get("npc_id") == event_data.npc_id:
			is_npc_present = true
			break
	
	if is_npc_present:
		print("NarrativeDirector: Local NPC '%s' found. Broadcasting interaction." % event_data.npc_id)
		EventBus.npc_interaction_requested.emit.call_deferred(event_data.npc_id, event_data.dialogue_id)
	else:
		print("NarrativeDirector: NPC '%s' not in scene. Triggering REMOTE fallback." % event_data.npc_id)
		_trigger_remote_dialogue(event_data.npc_id, event_data.dialogue_id)

func _handle_spawn_ticket(event_data: Dictionary):
	EventBus.narrative_spawn_ticket.emit(event_data.ticket_id)

func _handle_spawn_consequence(event_data: Dictionary):
	EventBus.narrative_spawn_consequence.emit(event_data.consequence_id)

func _handle_system_event(event_data: Dictionary):
	if not event_data.has("event_id"):
		push_error("NarrativeDirector: 'system_event' missing 'event_id'!")
		return
		
	var event_id = event_data.event_id
	var duration = event_data.get("duration", 10.0)
	EventBus.world_event_triggered.emit(event_id, true, duration)
	
	# VISUAL SIDE EFFECTS: Physical feedback
	match event_id:
		"POWER_FLICKER":
			_apply_power_flicker(duration)
			if TransitionManager: TransitionManager.overlay_instance.shake_screen(15.0, 0.5)
		"ZERO_DAY":
			if TransitionManager: TransitionManager.overlay_instance.shake_screen(25.0, 1.0)
		"DDOS_ATTACK":
			if TransitionManager: TransitionManager.overlay_instance.shake_screen(5.0, duration)
	
	# Safety check for unit tests/orphaned nodes
	if not is_inside_tree():
		return

	# Auto-clear after duration
	get_tree().create_timer(duration).timeout.connect(
		func(): EventBus.world_event_triggered.emit(event_id, false, 0.0)
	)

func _handle_shift_end(event_data: Dictionary):
	print("NarrativeDirector: Executing shift_end sequence...")
	stop_shift()
	var failure_type = event_data.get("failure_type", "")
	
	if ArchetypeAnalyzer:
		print("NarrativeDirector: Fetching analyst results...")
		var results = ArchetypeAnalyzer.get_analysis_results()
		print("NarrativeDirector: Results calculated. Archetype: ", results.get("archetype", "Unknown"))

		# If in 2D mode, exit to 3D first.
		if GameState.is_in_2d_mode():
			print("NarrativeDirector: Exiting desktop mode before report.")
			TransitionManager.exit_desktop_mode()
			await EventBus.transition_completed

		# Handle Instant Failures (Bankrupt/Fired)
		if failure_type != "":
			print("NarrativeDirector: Campaign ended via failure: ", failure_type)
			EventBus.campaign_ended.emit(failure_type)
			return
		
		# Check for 'Fired' via archetype
		if results.get("archetype") == GlobalConstants.ARCHETYPE.NEGLIGENT:
			print("NarrativeDirector: Player fired for negligence.")
			EventBus.campaign_ended.emit("fired")
			return

		# Check for campaign completion (Victory)
		# Only trigger victory if there is NO next shift defined in the resource.
		if current_shift_resource and current_shift_resource.next_shift_id == "":
			print("NarrativeDirector: Final shift in sequence reached. Triggering Victory.")
			if ConfigManager:
				ConfigManager.set_setting("gameplay", "campaign_completed", true)
			EventBus.campaign_ended.emit("victory")
			return

		# Normal shift end - show report
		print("NarrativeDirector: Showing shift report overlay...")
		var report_layer = CanvasLayer.new()
		report_layer.layer = 125 # Top priority
		get_tree().root.add_child(report_layer)
		
		var report_instance = shift_report_scene.instantiate()
		report_layer.add_child(report_instance)
		report_instance.show_report(results)
		
		# Pass the next shift ID to the report for continuation
		if current_shift_resource and not current_shift_resource.next_shift_id.is_empty():
			print("NarrativeDirector: Next shift defined: ", current_shift_resource.next_shift_id)
			report_instance.set_next_shift(current_shift_resource.next_shift_id)
		
		EventBus.shift_ended.emit(results)
		print("NarrativeDirector: Shift report sequence complete.")
	else:
		print("ERROR: ArchetypeAnalyzer not found!")
		EventBus.shift_ended.emit({})


func _on_ticket_completed(ticket: TicketResource, completion_type: String, _time_taken: float):
	pass

# --- Dynamic Guidance Engine (Sprint 11) ---

func get_weekend_hint() -> Dictionary:
	if not current_shift_resource: return {}
	
	match current_shift_resource.minigame_type:
		"AUDIT":
			# Find first un-audited node
			var nodes = get_tree().get_nodes_in_group("audit_nodes")
			for n in nodes:
				if n.get("is_audited") == false:
					return {"next_node": n.audit_id}
			return {"next_node": "ALL VERIFIED"}
			
		"RECOVERY":
			# Query TabletHUD for first un-ready socket
			var huds = get_tree().get_nodes_in_group("tablet_hud")
			if not huds.is_empty():
				var tablet = huds[0]
				var data = tablet.get("dynamic_sunday_hardware_data")
				if data:
					for socket_id in data:
						if data[socket_id].ready == false:
							return {"socket_id": socket_id, "req_type": data[socket_id].req}
			return {"socket_id": "NONE", "req_type": "DONE"}
			
	return {}

func _apply_power_flicker(duration: float):
	print("NarrativeDirector: Applying POWER FLICKER effect...")
	if DesktopWindowManager:
		DesktopWindowManager.close_all_windows()
	
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.electrical_crackle)
		
	# Visual flicker handled by TransitionManager/Shader
	if TransitionManager and TransitionManager.overlay_instance:
		TransitionManager.overlay_instance.flash_black(duration)

func _trigger_remote_dialogue(npc_id: String, dialogue_id: String):
	if not DialogueManager: return
	
	# Convention-based path: res://resources/dialogue/[npc_id]_[dialogue_id].tres
	var path = "res://resources/dialogue/" + npc_id + "_" + dialogue_id + ".tres"
	
	if ResourceLoader.exists(path):
		var res = load(path)
		if res:
			print("NarrativeDirector: Starting remote dialogue from resource: ", path)
			# We pass null as the NPC node to signify it's a remote call
			DialogueManager.call_deferred("start_dialogue", null, res)
	else:
		push_error("NarrativeDirector: Remote fallback failed. Dialogue resource not found: " + path)
