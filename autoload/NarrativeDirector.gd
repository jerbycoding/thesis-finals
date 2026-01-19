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

func is_weekend() -> bool:
	return current_shift_name == "shift_saturday" or current_shift_name == "shift_sunday"

func get_current_floor_requirement() -> int:
	if current_shift_name == "shift_saturday": return -2
	if current_shift_name == "shift_sunday": return -1
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

func _discover_shifts():
	print("🎬 NARRATIVE_DEBUG: Discovering shifts in %s..." % SHIFT_DIR)
	shift_library.clear()
	var paths = FileUtil.get_resource_paths(SHIFT_DIR)
	for path in paths:
		var res = load(path)
		if res and res is ShiftResource:
			if not res.validate():
				print("  - ❌ NARRATIVE_DEBUG: Skipping malformed resource: %s" % path)
				continue
			
			if shift_library.has(res.shift_id):
				print("  - ⚠ NARRATIVE_DEBUG: Duplicate Shift ID '%s' found in %s. Skipping." % [res.shift_id, path])
				continue
				
			shift_library[res.shift_id] = res
			print("  - Registered Shift: %s" % res.shift_id)
	print("🎬 NARRATIVE_DEBUG: Library ready: %d shifts." % shift_library.size())

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
	EventBus.npc_interaction_requested.emit("ciso", shift_res.briefing_dialogue_id)

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
	if consequence_id == "data_loss":
		print("NarrativeDirector: CRITICAL FAILURE detected. Terminating shift.")
		_trigger_event({"type": "shift_end", "failure_type": "bankrupt"})

func _on_consequence_triggered(consequence_id: String, _details: Dictionary):
	if consequence_id == "data_loss":
		print("NarrativeDirector: CRITICAL FAILURE detected. Terminating shift.")
		_trigger_event({"type": "shift_end", "failure_type": "bankrupt"})

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
		"npc_interaction":
			if GameState.is_in_2d_mode():
				print("NarrativeDirector: NPC interaction triggered. Transitioning to 3D for dialogue.")
				TransitionManager.exit_desktop_mode()
				await EventBus.transition_completed
				# Wait a moment for the camera to settle
				await get_tree().create_timer(0.5).timeout
			
			# Fallback for remote NPCs (like CISO who is no longer in the office)
			if event_data.npc_id == "ciso" and DialogueManager:
				var path = "res://resources/dialogue/ciso_" + event_data.dialogue_id + ".tres"
				if ResourceLoader.exists(path):
					var res = load(path)
					if res:
						print("NarrativeDirector: Starting remote CISO dialogue.")
						DialogueManager.start_dialogue(null, res)
						return # Skip the signal emission since we started it manually
			
			EventBus.npc_interaction_requested.emit(event_data.npc_id, event_data.dialogue_id)
		"spawn_ticket":
			EventBus.narrative_spawn_ticket.emit(event_data.ticket_id)
		"spawn_consequence":
			EventBus.narrative_spawn_consequence.emit(event_data.consequence_id)
		"system_event":
			EventBus.world_event_triggered.emit(event_data.event_id, true, event_data.get("duration", 10.0))
			# Auto-clear after duration
			get_tree().create_timer(event_data.get("duration", 10.0)).timeout.connect(
				func(): EventBus.world_event_triggered.emit(event_data.event_id, false, 0.0)
			)
		"shift_end":
			stop_shift()
			var failure_type = event_data.get("failure_type", "")
			
			if ArchetypeAnalyzer:
				var results = ArchetypeAnalyzer.get_analysis_results()

				# If in 2D mode, exit to 3D first.
				if GameState.is_in_2d_mode():
					TransitionManager.exit_desktop_mode()
					await EventBus.transition_completed

				# Handle Instant Failures (Bankrupt/Fired)
				if failure_type != "":
					EventBus.campaign_ended.emit(failure_type)
					return
				
				# Check for 'Fired' via archetype
				if results.get("archetype") == "Negligent":
					EventBus.campaign_ended.emit("fired")
					return

				# Best ending check (Friday)
				if current_shift_name == "shift_friday":
					if results.get("archetype") == "By-the-Book":
						EventBus.campaign_ended.emit("victory")
					else:
						# Standard completion ending? For now, we use victory as catch-all 
						# but could add a "Standard" victory later.
						EventBus.campaign_ended.emit("victory")
					return

				# Normal shift end - show report
				var report_instance = shift_report_scene.instantiate()
				get_tree().root.add_child(report_instance)
				report_instance.show_report(results)
				
				# Pass the next shift ID to the report for continuation
				if current_shift_resource and not current_shift_resource.next_shift_id.is_empty():
					report_instance.set_next_shift(current_shift_resource.next_shift_id)
				
				EventBus.shift_ended.emit(results)
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
