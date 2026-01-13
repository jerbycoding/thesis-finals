# NarrativeDirector.gd
# This autoload singleton manages the scripted story flow,
# coordinating NPC interactions, ticket spawns, and consequences.
extends Node

signal npc_interaction_requested(npc_id, dialogue_id)
signal spawn_ticket_requested(ticket_id)
signal spawn_consequence_requested(consequence_id)
signal world_event(event_id: String, active: bool, duration: float)
signal shift_started
signal shift_ended(results: Dictionary)

# The scripted sequence of events for the first shift.
# Events are triggered by time or player actions.
var first_shift_arc = [
	{"time": 4, "event": "spawn_phishing_ticket", "type": "spawn_ticket", "ticket_id": "phishing_intro"},
	{"time": 15, "event": "siem_instability", "type": "system_event", "event_id": "SIEM_LAG", "duration": 20.0},
	# {"time": 240, "event": "senior_analyst_checkin_mid", "type": "npc_interaction", "npc_id": "senior_analyst", "dialogue_id": "checkin_01"}, # Now triggered by event
	{"time": 24, "event": "spawn_malware_ticket", "type": "spawn_ticket", "ticket_id": "malware_response"},
	{"time": 36, "event": "ciso_followup", "type": "npc_interaction", "npc_id": "ciso", "dialogue_id": "default"},
	{"time": 120, "event": "it_support_checkin", "type": "npc_interaction", "npc_id": "it_support", "dialogue_id": "default"},
	{"time": 150, "event": "final_ciso_briefing", "type": "npc_interaction", "npc_id": "ciso", "dialogue_id": "shift_end"},
	{"time": 180, "event": "shift_end_report", "type": "shift_end"}
]

var second_shift_arc = [
	{"time": 20, "event": "spawn_ticket", "type": "spawn_ticket", "ticket_id": "ransom_001"},
	{"time": 60, "event": "npc_interaction", "type": "npc_interaction", "npc_id": "senior_analyst", "dialogue_id": "checkin_second_shift"},
	{"time": 80, "event": "spawn_ticket", "type": "spawn_ticket", "ticket_id": "insider_001"},
	{"time": 120, "event": "spawn_ticket", "type": "spawn_ticket", "ticket_id": "social_001"},
	{"time": 180, "event": "shift_end_report", "type": "shift_end"}
]

var third_shift_arc = [
	{"time": 15, "event": "spawn_ticket", "type": "spawn_ticket", "ticket_id": "data_exfil"},
	{"time": 60, "event": "spawn_ticket", "type": "spawn_ticket", "ticket_id": "phishing_campaign"},
	{"time": 180, "event": "shift_end_report", "type": "shift_end"}
]

var current_active_arc: Array = []
var current_shift_name: String = "first_shift"
var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

var shift_start_time: float = 0.0
var current_event_index: int = 0
var _is_shift_active: bool = false
var is_first_ticket_completed: bool = false # State to prevent re-triggering
var event_timer: Timer

func _ready():
	# Connect to TicketManager to handle event-driven narrative beats
	if TicketManager:
		TicketManager.ticket_completed.connect(_on_ticket_completed)
	
	# Initialize event timer
	event_timer = Timer.new()
	add_child(event_timer)
	event_timer.one_shot = true
	event_timer.timeout.connect(_on_event_timer_timeout)

func start_shift(shift_name: String = "first_shift"):
	print("NarrativeDirector: Starting shift: ", shift_name)
	current_shift_name = shift_name
	
	match shift_name:
		"first_shift":
			current_active_arc = first_shift_arc
		"second_shift":
			current_active_arc = second_shift_arc
		"third_shift":
			current_active_arc = third_shift_arc
		_:
			push_error("NarrativeDirector: Unknown shift name: ", shift_name)
			return

	_is_shift_active = true
	is_first_ticket_completed = false
	shift_start_time = Time.get_ticks_msec()
	current_event_index = 0
	shift_started.emit()
	
	_schedule_next_event()

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

func _trigger_event(event_data: Dictionary):
	print("NarrativeDirector: Triggering event - ", event_data.get("event", "N/A"))
	match event_data.type:
		"npc_interaction":
			emit_signal("npc_interaction_requested", event_data.npc_id, event_data.dialogue_id)
		"spawn_ticket":
			emit_signal("spawn_ticket_requested", event_data.ticket_id)
		"spawn_consequence":
			emit_signal("spawn_consequence_requested", event_data.consequence_id)
		"system_event":
			emit_signal("world_event", event_data.event_id, true, event_data.get("duration", 10.0))
			# Auto-clear after duration
			get_tree().create_timer(event_data.get("duration", 10.0)).timeout.connect(
				func(): emit_signal("world_event", event_data.event_id, false, 0.0)
			)
		"shift_end":
			stop_shift()
			if ArchetypeAnalyzer:
				var results = ArchetypeAnalyzer.get_analysis_results()

				# If in 2D mode, exit to 3D first.
				if GameState.is_in_2d_mode():
					TransitionManager.exit_desktop_mode()
					await TransitionManager.transition_completed
					# The await ensures we don't continue until the transition is done.

				# Now that we are guaranteed to be in 3D, show the report.
				var report_instance = shift_report_scene.instantiate()
				get_tree().root.add_child(report_instance)
				report_instance.show_report(results)
				
				emit_signal("shift_ended", results)
			else:
				print("ERROR: ArchetypeAnalyzer not found!")
				emit_signal("shift_ended", {})


func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	# Check if the first ticket was just completed
	if ticket.ticket_id == "SPEAR-PHISH-001" and not is_first_ticket_completed:
		is_first_ticket_completed = true
		print("NarrativeDirector: First ticket completed. Triggering Senior Analyst check-in.")
		
		# Define the event to be triggered
		var analyst_event = {
			"event": "senior_analyst_checkin_mid", 
			"type": "npc_interaction", 
			"npc_id": "senior_analyst", 
			"dialogue_id": "checkin_01"
		}
		
		# If player is in 2D mode, exit to 3D first, then trigger dialogue
		if GameState.is_in_2d_mode():
			print("NarrativeDirector: Player is in 2D mode. Exiting to 3D before starting dialogue.")
			TransitionManager.exit_desktop_mode()
			await TransitionManager.transition_completed
			print("NarrativeDirector: 3D transition complete. Triggering dialogue.")
			_trigger_event(analyst_event)
		else:
			# If already in 3D, trigger immediately
			_trigger_event(analyst_event)


func start_briefing():
	print("NarrativeDirector: Starting briefing sequence.")
	if _is_shift_active: return
	
	# Change the scene, but don't block
	TransitionManager.change_scene_to("res://scenes/3d/BriefingRoom.tscn")
	
	# Wait for the transition to fully complete, then trigger the dialogue
	await TransitionManager.transition_completed
	
	print("NarrativeDirector: Briefing room loaded. Triggering CISO dialogue.")
	emit_signal("npc_interaction_requested", "ciso", "briefing_01")
	# The CISO's dialogue will then trigger start_shift()

func start_second_shift_briefing():
	print("NarrativeDirector: Starting second shift briefing sequence.")
	if _is_shift_active: return # Or handle this case differently
	
	TransitionManager.change_scene_to("res://scenes/3d/BriefingRoom.tscn")
	await TransitionManager.transition_completed
	
	print("NarrativeDirector: Briefing room loaded for second shift. Triggering CISO dialogue.")
	emit_signal("npc_interaction_requested", "ciso", "briefing_second_shift")
	# The CISO's dialogue will then trigger start_shift("second_shift")

func start_third_shift_briefing():
	print("NarrativeDirector: Starting third shift briefing sequence.")
	if _is_shift_active: return
	
	TransitionManager.change_scene_to("res://scenes/3d/BriefingRoom.tscn")
	await TransitionManager.transition_completed
	
	print("NarrativeDirector: Briefing room loaded for third shift. Triggering CISO dialogue.")
	emit_signal("npc_interaction_requested", "ciso", "briefing_third_shift")
	# The CISO's dialogue will then trigger start_shift("third_shift")
