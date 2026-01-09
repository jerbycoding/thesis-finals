# NarrativeDirector.gd
# This autoload singleton manages the scripted story flow,
# coordinating NPC interactions, ticket spawns, and consequences.
extends Node

signal npc_interaction_requested(npc_id, dialogue_id)
signal spawn_ticket_requested(ticket_id)
signal spawn_consequence_requested(consequence_id)
signal shift_started
signal shift_ended(results: Dictionary)

# The scripted sequence of events for the first shift.
# Events are triggered by time or player actions.
var first_shift_arc = [
	{"time": 20, "event": "spawn_phishing_ticket", "type": "spawn_ticket", "ticket_id": "phishing_intro"},
	# {"time": 240, "event": "senior_analyst_checkin_mid", "type": "npc_interaction", "npc_id": "senior_analyst", "dialogue_id": "checkin_01"}, # Now triggered by event
	{"time": 120, "event": "spawn_malware_ticket", "type": "spawn_ticket", "ticket_id": "malware_response"},
	{"time": 180, "event": "ciso_followup", "type": "npc_interaction", "npc_id": "ciso", "dialogue_id": "default"},
	{"time": 210, "event": "it_support_checkin", "type": "npc_interaction", "npc_id": "it_support", "dialogue_id": "default"},
	{"time": 270, "event": "final_ciso_briefing", "type": "npc_interaction", "npc_id": "ciso", "dialogue_id": "shift_end"},
	{"time": 300, "event": "shift_end_report", "type": "shift_end"}
]

var shift_report_scene = preload("res://scenes/2d/apps/App_ShiftReport.tscn")

var shift_timer: float = 0.0
var current_event_index: int = 0
var _is_shift_active: bool = false
var is_first_ticket_completed: bool = false # State to prevent re-triggering

func _process(delta):
	if not _is_shift_active:
		return

	shift_timer += delta
	
	# Use a while loop to process multiple events that might occur in the same frame
	while current_event_index < first_shift_arc.size():
		var next_event = first_shift_arc[current_event_index]
		if next_event.has("time") and shift_timer >= next_event.time:
			_trigger_event(next_event)
			current_event_index += 1
		else:
			# No more time-based events to process for now
			break

func start_shift():
	print("NarrativeDirector: First shift has started.")
	_is_shift_active = true
	is_first_ticket_completed = false
	shift_timer = 0.0
	current_event_index = 0
	shift_started.emit()

func stop_shift():
	print("NarrativeDirector: Shift has ended.")
	_is_shift_active = false

func get_shift_timer() -> float:
	return shift_timer

func is_shift_active() -> bool:
	return _is_shift_active

func _trigger_event(event_data: Dictionary):
	print("NarrativeDirector: Triggering event - ", event_data.get("event", "N/A"))
	match event_data.type:
		"npc_interaction":
			emit_signal("npc_interaction_requested", event_data.npc_id, event_data.dialogue_id)
		"spawn_ticket":
			emit_signal("spawn_ticket_requested", event_data.ticket_id)
		"spawn_consequence":
			emit_signal("spawn_consequence_requested", event_data.consequence_id)
		"shift_end":
			stop_shift()
			if ArchetypeAnalyzer:
				var results = ArchetypeAnalyzer.get_analysis_results()

				# If in 2D mode, clean up the desktop first
				if GameState.is_in_2d_mode() and is_instance_valid(GameState.desktop_instance):
					GameState.desktop_instance.close_all_windows()

				# Show the report
				var report_instance = shift_report_scene.instantiate()
				get_tree().root.add_child(report_instance)
				report_instance.show_report(results)
				
				emit_signal("shift_ended", results)
			else:
				print("ERROR: ArchetypeAnalyzer not found!")
				emit_signal("shift_ended", {})

func _ready():
	# Connect to TicketManager to handle event-driven narrative beats
	if TicketManager:
		TicketManager.ticket_completed.connect(_on_ticket_completed)

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
