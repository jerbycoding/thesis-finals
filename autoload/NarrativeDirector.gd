# NarrativeDirector.gd
# This autoload singleton manages the scripted story flow,
# coordinating NPC interactions, ticket spawns, and consequences.
extends Node

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
var current_event_index: int = 0
var _is_shift_active: bool = false
var event_timer: Timer
var chaos_timer: Timer

func is_weekend() -> bool:
	if current_shift_resource:
		return current_shift_resource.minigame_type != "NONE"
	return false

func get_current_floor_requirement() -> int:
	if current_shift_resource:
		return current_shift_resource.required_floor
	return 1 # Default to SOC

func _ready():
	# Discover all shifts in the folder
	_discover_shifts()
	
	# Connect to EventBus for critical failures
	EventBus.narrative_spawn_consequence.connect(func(id): _trigger_event({"type": "spawn_consequence", "consequence_id": id}))
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	EventBus.shift_end_requested.connect(func(): _trigger_event({"type": "shift_end"}))
	
	EventBus.campaign_ended.connect(_on_campaign_ended)
	
	# Initialize event timer
	event_timer = Timer.new()
	add_child(event_timer)
	event_timer.one_shot = true
	event_timer.timeout.connect(_on_event_timer_timeout)

	# Initialize chaos timer
	chaos_timer = Timer.new()
	add_child(chaos_timer)
	chaos_timer.timeout.connect(_on_chaos_tick)

func _on_chaos_tick():
	if not _is_shift_active or not current_shift_resource:
		return
		
	if current_shift_resource.random_event_pool.is_empty():
		return
		
	# 35% chance to trigger a random event every tick
	if randf() < 0.35:
		var event = current_shift_resource.random_event_pool.pick_random()
		print("🎲 CHAOS ENGINE: Triggering random event: ", event.get("event", "Unnamed"))
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

func prepare_shift(shift_id: String):
	if not shift_library.has(shift_id):
		push_error("NarrativeDirector: Cannot prepare unknown shift ID: " + shift_id)
		return
		
	var shift_res = shift_library[shift_id]
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
	current_active_arc = current_shift_resource.event_sequence

	_is_shift_active = true
	shift_start_time = Time.get_ticks_msec()
	current_event_index = 0
	
	EventBus.shift_started.emit(shift_id)
	
	_schedule_next_event()
	
	# Start chaos engine (check every 45 seconds)
	chaos_timer.start(45.0)

func trigger_briefing(shift_id: String):
	if _is_shift_active: 
		print("NarrativeDirector: Briefing blocked - shift already active.")
		return
		
	if not shift_library.has(shift_id):
		push_error("NarrativeDirector: Cannot trigger briefing - Shift ID '%s' unknown." % shift_id)
		return
		
	var shift_res = shift_library[shift_id]
	print("NarrativeDirector: Starting briefing for: ", shift_id)
	
	# Transition to Briefing Room if not already there
	if get_tree().current_scene.name != "BriefingRoom":
		TransitionManager.change_scene_to("res://scenes/3d/BriefingRoom.tscn")
		await EventBus.transition_completed
	
	# Trigger the dialogue via signal (CISO is usually the one speaking)
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
				if TutorialManager.current_step != TutorialManager.TutorialStep.COMPLETE:
					# Hold the shift open!
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

func reset_to_default():
	print("NarrativeDirector: Resetting to default state.")
	stop_shift()
	current_shift_name = ""
	current_shift_resource = null
	current_active_arc.clear()
	current_event_index = 0

func get_shift_timer() -> float:
	if not _is_shift_active:
		return 0.0
	return (Time.get_ticks_msec() - shift_start_time) / 1000.0

func is_shift_active() -> bool:
	return _is_shift_active

func get_current_shift_duration() -> float:
	if current_active_arc.is_empty():
		return 0.0
	
	# The last event in the arc should be the shift_end
	var last_event = current_active_arc.back()
	if last_event.has("time"):
		return last_event.time
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
	var scene_path = ENDING_SCENES.get(type, "res://scenes/ui/TitleScreen.tscn")
	
	if TransitionManager:
		TransitionManager.change_scene_to(scene_path)
	else:
		get_tree().change_scene_to_file(scene_path)

func _trigger_event(event_data: Dictionary):
	print("NarrativeDirector: Triggering event - ", event_data.get("event", "N/A"))
	match event_data.type:
		GlobalConstants.NARRATIVE_EVENT_TYPE.NPC_INTERACTION:
			if GameState.is_in_2d_mode():
				print("NarrativeDirector: NPC interaction triggered. Transitioning to 3D for dialogue.")
				TransitionManager.exit_desktop_mode()
				await EventBus.transition_completed
				# Wait a moment for the camera to settle
				await get_tree().create_timer(0.5).timeout
			
			# Fallback for remote NPCs (like CISO who is no longer in the office)
			if event_data.npc_id == GlobalConstants.NPC_ID.CISO and DialogueManager:
				var path = "res://resources/dialogue/ciso_" + event_data.dialogue_id + ".tres"
				if ResourceLoader.exists(path):
					var res = load(path)
					if res:
						print("NarrativeDirector: Starting remote CISO dialogue.")
						DialogueManager.start_dialogue(null, res)
						return # Skip the signal emission since we started it manually
			
			EventBus.npc_interaction_requested.emit(event_data.npc_id, event_data.dialogue_id)
		GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_TICKET:
			EventBus.narrative_spawn_ticket.emit(event_data.ticket_id)
		GlobalConstants.NARRATIVE_EVENT_TYPE.SPAWN_CONSEQUENCE:
			EventBus.narrative_spawn_consequence.emit(event_data.consequence_id)
		GlobalConstants.NARRATIVE_EVENT_TYPE.SYSTEM_EVENT:
			EventBus.world_event_triggered.emit(event_data.event_id, true, event_data.get("duration", 10.0))
			# Auto-clear after duration
			get_tree().create_timer(event_data.get("duration", 10.0)).timeout.connect(
				func(): EventBus.world_event_triggered.emit(event_data.event_id, false, 0.0)
			)
		GlobalConstants.NARRATIVE_EVENT_TYPE.SHIFT_END:
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

# --- Deprecated specific briefing methods - Use trigger_briefing(id) instead ---

func start_briefing():
	trigger_briefing("shift_monday")

func start_tuesday_briefing():
	trigger_briefing("shift_tuesday")

func start_wednesday_briefing():
	trigger_briefing("shift_wednesday")

func start_thursday_briefing():
	trigger_briefing("shift_thursday")

func start_friday_briefing():
	trigger_briefing("shift_friday")

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
