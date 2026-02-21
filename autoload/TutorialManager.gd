# TutorialManager.gd
# Manages the guided onboarding experience using data-driven TutorialStepResources.
extends Node

signal step_changed(new_step: int)

enum TutorialStep {
	NONE = 0,
	ROAM_TO_OFFICE = 1,
	INTERACT_DESK = 2,
	OPEN_TICKETS = 3,
	READ_TICKET = 4,
	OPEN_EMAIL = 5,
	READ_EMAIL = 6,
	OPEN_SIEM = 7,
	ATTACH_LOG = 8,
	RESOLVE_TICKET = 9,
	START_TRN_002 = 10,
	OPEN_TERMINAL = 11,
	SCAN_HOST = 12,
	ISOLATE_HOST = 13,
	OPEN_MAP = 14,
	VERIFY_ISOLATION = 15,
	RESOLVE_FINAL = 16,
	COMPLETE = 17
}

var is_tutorial_active: bool = false
var current_step_index: int = -1
var summary_shown: bool = false
var current_step: int:
	get:
		return current_step_index + 1

var sequence: TutorialSequenceResource = null

var overlay: Control = null
var hud: Control = null
var overlay_layer: CanvasLayer = null

var hud_scene = preload("res://scenes/ui/TutorialHUD.tscn")
var overlay_scene = preload("res://scenes/ui/TutorialOverlay.tscn")
var summary_scene = preload("res://scenes/ui/CertificationSummary.tscn")

func _ready():
	_load_sequence()
	
	EventBus.shift_started.connect(_on_shift_started)
	EventBus.shift_ended.connect(_on_shift_ended)
	EventBus.game_mode_changed.connect(_on_game_mode_changed)
	EventBus.app_opened.connect(_on_app_opened)
	EventBus.ticket_selected.connect(_on_ticket_selected)
	EventBus.email_read.connect(_on_email_read)
	EventBus.email_inspected.connect(_on_email_inspected)
	EventBus.log_attached_to_ticket.connect(_on_log_attached)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.terminal_command_executed.connect(_on_terminal_executed)
	EventBus.host_selected.connect(_on_host_selected)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)

func _input(event):
	# DEBUG: Jump to Phase 4 (Step 18)
	if OS.is_debug_build() and event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		print("TutorialManager: DEBUG JUMP to Step 18")
		if TicketManager: TicketManager.spawn_ticket_by_id("TRN-003")
		_advance_step(17) # Index 17 is Step 18

func _on_consequence_triggered(type: String, _details: Dictionary):
	if not is_tutorial_active: return
	
	if type == GlobalConstants.CONSEQUENCE_ID.PROCEDURAL_VIOLATION:
		# If we are on the 'Forced Failure' step, advance to explanation
		if current_step == 18:
			_advance_step(18) # Move to Step 19 (indices are 0-based, so 18 is Step 19)

func _load_sequence():
	var path = "res://resources/TutorialSequence.tres"
	if ResourceLoader.exists(path):
		sequence = load(path)
		print("TutorialManager: Loaded data-driven sequence: ", sequence.sequence_name)
	else:
		push_error("TutorialManager: Missing TutorialSequence.tres!")

func set_overlay(new_overlay: Control):
	overlay = new_overlay
	if is_tutorial_active:
		_update_visual_focus()

func _on_shift_started(shift_id: String):
	if shift_id == "shift_tutorial":
		is_tutorial_active = true
		if GameState: GameState.is_guided_mode = true
		
		# INJECT TRAINING FILTERS
		if LogSystem:
			LogSystem.active_filter = func(log: LogResource, t_id: String):
				return log.log_id.begins_with("LOG-TRN") or log.related_ticket == t_id
		if EmailSystem:
			EmailSystem.active_filter = func(email: EmailResource, t_id: String):
				return email.email_id.begins_with("EMAIL-TRN") or email.related_ticket == t_id
		
		# INJECT PERMISSIONS
		if DesktopWindowManager:
			DesktopWindowManager.active_permission_profile = load("res://resources/training_permissions.tres")
		
		_toggle_live_hud(false)
		_create_hud()
		_create_overlay()
		_advance_step(0) # Start at first step

func _create_hud():
	if hud: return
	var layer = CanvasLayer.new()
	layer.name = "TutorialHUDLayer"
	layer.layer = 130 
	get_tree().root.add_child(layer)
	hud = hud_scene.instantiate()
	layer.add_child(hud)
	if GameState and not GameState.is_in_2d_mode():
		hud.hide()

func _create_overlay():
	if overlay_layer: return
	overlay_layer = CanvasLayer.new()
	overlay_layer.name = "TutorialOverlayLayer"
	overlay_layer.layer = 110 
	get_tree().root.add_child(overlay_layer)
	overlay = overlay_scene.instantiate()
	overlay_layer.add_child(overlay)

func _on_shift_ended(_results: Dictionary):
	if not is_tutorial_active: return
	
	is_tutorial_active = false
	current_step_index = -1
	summary_shown = false
	if GameState: GameState.is_guided_mode = false
	
	# CLEAR FILTERS
	if LogSystem: 
		LogSystem.active_filter = null
		LogSystem.reveal_logs_for_ticket("") # Restore default noise
	if EmailSystem: 
		EmailSystem.active_filter = null
		EmailSystem.reveal_emails_for_ticket("") # Restore default noise
	
	# CLEAR PERMISSIONS
	if DesktopWindowManager: 
		DesktopWindowManager.active_permission_profile = null
	
	_toggle_live_hud(true)
	if overlay: overlay.hide_overlay()
	
	if hud:
		var h_layer = hud.get_parent()
		hud.queue_free()
		if h_layer: h_layer.queue_free()
		hud = null
	if overlay_layer:
		overlay_layer.queue_free()
		overlay_layer = null
		overlay = null
	
	# DATA FLUSH: Purge training state using new API
	if LogSystem:
		LogSystem.clear_active_data()
		LogSystem.reveal_logs_for_ticket("")
	if EmailSystem:
		EmailSystem.clear_active_data()
		EmailSystem.reveal_emails_for_ticket("")
	
	if TicketManager:
		TicketManager.clear_active_data()
	
	# NETWORK RESET: Reset the tutorial host state
	if NetworkState:
		NetworkState.update_host_state("WORKSTATION-T", {"isolated": false, "status": "CLEAN", "scanned": false})
		NetworkState._register_hosts_from_folder()

func _toggle_live_hud(active: bool):
	var huds = get_tree().get_nodes_in_group("hud")
	if huds.is_empty():
		var main_hud = get_tree().root.find_child("UnifiedHUD", true, false)
		if main_hud: main_hud.visible = active
	else:
		for h in huds: h.visible = active

# --- Data-Driven Logic Bridge ---

func _check_trigger(type: TutorialStepResource.TriggerType, id: String = ""):
	if not is_tutorial_active or not sequence: return
	var current = sequence.get_step(current_step_index)
	if not current: return
	
	# DEBUG VALIDATION
	print("TutorialManager: Received trigger %d (%s). Waiting for %d (%s)." % [type, id, current.trigger_type, current.trigger_id])
	
	if current.trigger_type == type:
		if current.trigger_id == "" or current.trigger_id.to_lower() == id.to_lower():
			print("TutorialManager: MATCH! Advancing to step ", current_step_index + 2)
			_advance_step(current_step_index + 1)

func reach_3d_objective(objective_id: String):
	_check_trigger(TutorialStepResource.TriggerType.ZONE_REACHED, objective_id)

func _on_game_mode_changed(mode: int):
	if mode == GameState.GameMode.MODE_2D:
		_check_trigger(TutorialStepResource.TriggerType.APP_OPENED, "desktop")
		if hud: hud.show()
	else:
		if hud: hud.hide()

func _on_app_opened(app_name: String, _window_id: String):
	_check_trigger(TutorialStepResource.TriggerType.APP_OPENED, app_name)

func _on_ticket_selected(ticket: TicketResource):
	_check_trigger(TutorialStepResource.TriggerType.TICKET_SELECTED, ticket.ticket_id)

func _on_email_read(email: EmailResource):
	_check_trigger(TutorialStepResource.TriggerType.EMAIL_READ, email.email_id)

func _on_email_inspected(email: EmailResource, type: String):
	if not is_tutorial_active or not sequence: return
	var current = sequence.get_step(current_step_index)
	if not current: return
	
	if current.trigger_type == TutorialStepResource.TriggerType.EMAIL_INSPECTED:
		if current.trigger_id == email.email_id and current.target_ticket_id == type:
			_advance_step(current_step_index + 1)

func _on_log_attached(t_id, l_id):
	if not is_tutorial_active: return
	var current = sequence.get_step(current_step_index)
	if current and current.trigger_type == TutorialStepResource.TriggerType.LOG_ATTACHED:
		if current.trigger_id == l_id and current.target_ticket_id == t_id:
			_advance_step(current_step_index + 1)

func _on_terminal_executed(cmd: String, success: bool, _out: String):
	if success:
		_check_trigger(TutorialStepResource.TriggerType.COMMAND_RUN, cmd.split(" ")[0])

func _on_host_selected(host: HostResource):
	_check_trigger(TutorialStepResource.TriggerType.HOST_SELECTED, host.hostname)

func _on_ticket_completed(ticket: TicketResource, completion_type: String, _time):
	if completion_type == "compliant":
		_check_trigger(TutorialStepResource.TriggerType.TICKET_COMPLETED, ticket.ticket_id)

# --- Core Lifecycle ---

func _advance_step(new_index: int):
	current_step_index = new_index
	var step_data = sequence.get_step(current_step_index)
	
	if not step_data:
		# Final Step reached
		return

	# Update HUD
	step_changed.emit(current_step_index + 1)
	
	if DialogueManager and DialogueManager.dialogue_box_instance:
		var db = DialogueManager.dialogue_box_instance
		if db.visible and db.is_waiting_for_task: db.advance_line()
	
	_show_instruction(step_data.instruction_text)
	_update_visual_focus()
	
	# Transition Logic: Spawn follow-up training tickets based on trigger_id
	if step_data.trigger_id == "TRN-002" and step_data.trigger_type == TutorialStepResource.TriggerType.TICKET_SELECTED:
		if TicketManager: TicketManager.spawn_ticket_by_id("TRN-002")
	
	if step_data.trigger_id == "TRN-003" and step_data.trigger_type == TutorialStepResource.TriggerType.TICKET_SELECTED:
		if TicketManager: TicketManager.spawn_ticket_by_id("TRN-003")

	# Auto-Advance Step 19 (Explanation Step)
	if current_step == 19:
		await get_tree().create_timer(10.0).timeout
		if current_step == 19: # Verify we haven't moved manually
			# Safety: Only advance if the player hasn't failed yet
			if IntegrityManager and IntegrityManager.current_integrity > 0:
				_advance_step(19)

	# Complete Logic: Immediately trigger if this is the final step
	if current_step_index == sequence.steps.size() - 1:
		_show_final_summary()

func _show_final_summary():
	if summary_shown: return
	summary_shown = true
	
	# CLEANUP: If the player is at the desk, exit 2D mode before showing summary
	if GameState.is_in_2d_mode():
		if TransitionManager:
			TransitionManager.exit_desktop_mode()
			await EventBus.transition_completed

	# DISABLE PLAYER: Block mouse-look and movement using centralized mode
	if GameState:
		GameState.set_mode(GameState.GameMode.MODE_UI_ONLY)

	# FREEZE BACKGROUND
	if NarrativeDirector: NarrativeDirector.stop_shift()
	if IntegrityManager: IntegrityManager.stop_decay()
	
	var layer = CanvasLayer.new()
	layer.name = "SummaryLayer"
	layer.layer = 150 # Top of everything
	get_tree().root.add_child(layer)
	
	var summary = summary_scene.instantiate()
	layer.add_child(summary)
	
	await summary.closed
	layer.queue_free()
	
	# TOTAL REFRESH: Purge all training data/memory before returning to Title
	if SaveSystem:
		SaveSystem.new_game_setup()
	
	# TRIGGER CLEANUP: Manually emit shift_ended to clear filters, tickets, and UI
	EventBus.shift_ended.emit({})
	
	# IMMEDIATE TRANSITION: Back to Title Screen for a clean break
	if TransitionManager:
		TransitionManager.change_scene_to("res://scenes/3d/MainMenu3D.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/3d/MainMenu3D.tscn")

func _update_visual_focus():
	if not overlay or not is_tutorial_active or not sequence: return
	var step_data = sequence.get_step(current_step_index)
	if not step_data: return
	
	var desktop = GameState.desktop_instance
	
	# Reset icon glows
	if desktop and desktop.has_method("set_icon_glow"):
		var apps = ["tickets", "siem", "email", "terminal", "network"]
		for a in apps: desktop.set_icon_glow(a, false)

	if step_data.highlight_path.is_empty():
		overlay.hide_overlay()
		return

	# Handle Glow
	if not step_data.icon_glow_name.is_empty() and desktop:
		if desktop.has_method("set_icon_glow"):
			desktop.set_icon_glow(step_data.icon_glow_name, true)

	# Handle Highlight Path
	if step_data.highlight_path.begins_with("%%") and desktop:
		overlay.highlight_node(desktop.get_node_or_null(step_data.highlight_path.replace("%%", "%")))
	elif step_data.highlight_path.begins_with("[DYNAMIC]"):
		_highlight_dynamic(step_data.highlight_path)
	else:
		overlay.hide_overlay()

func _highlight_dynamic(path: String):
	match path:
		"[DYNAMIC]TICKET_LIST_0":
			var win = DesktopWindowManager._find_window_by_app("tickets")
			if win:
				var list = win.get_node_or_null("%TicketList")
				if list and list.get_child_count() > 0: overlay.highlight_node(list.get_child(0))
		"[DYNAMIC]TICKET_0_COMPLETE":
			var win = DesktopWindowManager._find_window_by_app("tickets")
			if win:
				var list = win.get_node_or_null("%TicketList")
				if list and list.get_child_count() > 0: 
					overlay.highlight_node(list.get_child(0).get_node_or_null("%CompleteButton"))
		"[DYNAMIC]EMAIL_LIST_0":
			var win = DesktopWindowManager._find_window_by_app("email")
			if win:
				var list = win.get_node_or_null("%EmailList")
				if list and list.get_child_count() > 0: overlay.highlight_node(list.get_child(0))
		"[DYNAMIC]LOG_LIST_0":
			var win = DesktopWindowManager._find_window_by_app("siem")
			if win:
				var list = win.get_node_or_null("%LogList")
				if list and list.get_child_count() > 0: overlay.highlight_node(list.get_child(0))
		"[DYNAMIC]MAP_NODE_T":
			var win = DesktopWindowManager._find_window_by_app("network")
			if win:
				var nodes = win.get_node_or_null("%NodesContainer")
				if nodes and nodes.get_child_count() > 0:
					overlay.highlight_node(nodes.get_child(nodes.get_child_count()-1))

func _get_instruction_for_step(step_idx: int) -> String:
	if sequence and step_idx >= 0 and step_idx < sequence.steps.size():
		return sequence.steps[step_idx].instruction_text
	return ""

func _show_instruction(text: String):
	if text == "": return
	if NotificationManager: NotificationManager.show_notification(text, "info", 12.0)
