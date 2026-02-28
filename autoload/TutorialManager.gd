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
	SELECT_EMAIL = 6,
	USE_LINK_CHECK = 7,
	OPEN_SIEM = 8,
	SELECT_LOG = 9,
	ATTACH_LOG = 10,
	RESOLVE_TICKET = 11,
	START_TRN_002 = 12,
	OPEN_TERMINAL = 13,
	SCAN_HOST = 14,
	ISOLATE_HOST = 15,
	OPEN_MAP = 16,
	VERIFY_ISOLATION = 17,
	OPEN_SIEM_2 = 18,
	SELECT_LOG_2 = 19,
	ATTACH_LOG_2 = 20,
	RESOLVE_TRN_002 = 21,
	START_TRN_003 = 22,
	OPEN_HANDBOOK = 23,
	READ_POLICY = 24,
	SCAN_SERVER = 25,
	RESOLVE_TRN_003 = 26,
	CERTIFICATION_DONE = 27,
	THE_SHORTCUT = 28,
	THE_CONSEQUENCE = 29,
	CONTAINMENT_2 = 30,
	NETSTAT_HUNT = 31,
	TRACE_HUNT = 32,
	SUBMIT_ROOT_CAUSE = 33,
	DECRYPTION_OPEN = 34,
	DECRYPTION_SOLVE = 35,
	FINAL_DEBRIEF = 36
}

var is_tutorial_active: bool = false
var current_step_index: int = -1
var summary_shown: bool = false
var current_step: int:
	get:
		return current_step_index + 1

var sequence: TutorialSequenceResource = null

var hud: Control = null

var hud_scene = preload("res://scenes/ui/TutorialHUD.tscn")
var summary_scene = preload("res://scenes/ui/CertificationSummary.tscn")

var training_profile: AppPermissionProfile = null

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
	EventBus.log_reviewed.connect(_on_log_reviewed)
	EventBus.log_read.connect(_on_log_read)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	EventBus.terminal_command_executed.connect(_on_terminal_executed)
	EventBus.host_selected.connect(_on_host_selected)
	EventBus.consequence_triggered.connect(_on_consequence_triggered)
	EventBus.ticket_state_updated.connect(_on_ticket_state_updated)
	EventBus.decryption_completed.connect(_on_decryption_completed)
	EventBus.transition_completed.connect(_refresh_hud_visibility)

func _refresh_hud_visibility():
	if not is_tutorial_active or not hud: return
	
	if hud.has_method("show_hud"):
		hud.show_hud()
	else:
		hud.show()

func _on_decryption_completed(t_id: String):
	_check_trigger(TutorialStepResource.TriggerType.DECRYPTION_COMPLETED, t_id)

func _on_ticket_state_updated(ticket: TicketResource):
	if not is_tutorial_active or not sequence: return
	var current = sequence.get_step(current_step_index)
	if not current: return
	
	if current.trigger_type == TutorialStepResource.TriggerType.ROOT_CAUSE_SUBMITTED:
		var target = ticket.required_root_cause
		if target.begins_with("{") and not ticket.truth_packet.is_empty():
			target = target.format(ticket.truth_packet)
		
		if ticket.input_root_cause.strip_edges().to_lower() == target.strip_edges().to_lower():
			_advance_step(current_step_index + 1)

func debug_skip_step(delta: int):
	if not is_tutorial_active: return
	
	var new_index = current_step_index + delta
	if new_index >= -1 and new_index < sequence.steps.size():
		print("TutorialManager: DEBUG SKIP to index ", new_index)
		# If skipping back to -1, we effectively reset to start
		if new_index == -1:
			_advance_step(0)
		else:
			_advance_step(new_index)

func debug_skip_to_step(step_number: int):
	if not is_tutorial_active: return
	var index = step_number - 1
	if index >= 0 and index < sequence.steps.size():
		print("TutorialManager: DEBUG JUMP to Step ", step_number)
		
		# CLEANUP: Remove any existing training tickets to prevent clutter
		if TicketManager:
			var to_remove = []
			for t in TicketManager.get_active_tickets():
				if t.ticket_id.begins_with("TRN-"):
					to_remove.append(t.ticket_id)
			
			for tid in to_remove:
				TicketManager.complete_ticket(tid, "compliant") # Silent removal
		
		_advance_step(index)

func _on_consequence_triggered(type: String, details: Dictionary):
	if not is_tutorial_active: return
	
	if type == "procedural_warning":
		_handle_remediation("PROTOCOL_VIOLATION: UNJUSTIFIED_ACTION_DETECTED")
		return

	if type == GlobalConstants.CONSEQUENCE_ID.PROCEDURAL_VIOLATION:
		# If we are on the 'Forced Failure' step, advance to explanation
		if current_step == 18:
			_advance_step(18) # Move to Step 19 (indices are 0-based, so 18 is Step 19)

func _handle_remediation(reason: String):
	print("TutorialManager: Remediation triggered: ", reason)
	
	if GameState and GameState.desktop_instance:
		var sidebar = GameState.desktop_instance.get_node_or_null("%RunbookSidebar")
		if sidebar:
			sidebar.set_warning_mode(true)
			sidebar.update_task(-99, "REMEDIATION: RESTORE_SYSTEM_STATE | REASON: " + reason)
			
	if NotificationManager:
		NotificationManager.show_notification("CRITICAL: SOP VIOLATION. RECOVERY REQUIRED.", "error", 8.0)
	
	# CISO Feedback
	if DialogueManager:
		# We can trigger a remote audio ping or a specific line here later
		pass

func _load_sequence():
	var path = "res://resources/TutorialSequence.tres"
	if ResourceLoader.exists(path):
		sequence = load(path)
		print("TutorialManager: Loaded data-driven sequence: ", sequence.sequence_name)
	else:
		push_error("TutorialManager: Missing TutorialSequence.tres!")

func _on_shift_started(shift_id: String):
	if shift_id == "shift_tutorial":
		is_tutorial_active = true
		if GameState: GameState.is_guided_mode = true
		
		# EXPLICIT SPAWNER KILL (Sprint 13 Fix)
		if TicketManager:
			TicketManager.stop_ambient_spawning()
		
		# INJECT TRAINING FILTERS
		if LogSystem:
			LogSystem.active_filter = func(log: LogResource, t_id: String):
				return log.log_id.begins_with("LOG-TRN") or log.related_ticket == t_id
			LogSystem.clear_active_data() # Purge noise
		if EmailSystem:
			EmailSystem.active_filter = func(email: EmailResource, t_id: String):
				return email.email_id.begins_with("EMAIL-TRN") or email.related_ticket == t_id
			EmailSystem.clear_active_data() # Purge noise
		
		# INITIAL DYNAMIC PERMISSIONS (Section 4: Provisioning)
		training_profile = AppPermissionProfile.new()
		training_profile.profile_name = "Dynamic Certification"
		training_profile.allowed_apps = ["tickets", "email", "handbook"]
		training_profile.restricted_message = "RESTRICTED: AUTHORIZATION PENDING SOP CLEARANCE."
		
		if DesktopWindowManager:
			DesktopWindowManager.active_permission_profile = training_profile
		
		_toggle_live_hud(false)
		_create_hud()
		_advance_step(0) # Start at first step

func _create_hud():
	if hud: return
	var layer = CanvasLayer.new()
	layer.name = "TutorialHUDLayer"
	layer.layer = 130 
	get_tree().root.add_child(layer)
	hud = hud_scene.instantiate()
	layer.add_child(hud)
	
	# Ensure it starts visible but handles its own internal layout
	if hud.has_method("show_hud"):
		hud.show_hud()
	else:
		hud.show()

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
	
	if hud:
		var h_layer = hud.get_parent()
		hud.queue_free()
		if h_layer: h_layer.queue_free()
		hud = null
	
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
	elif mode == GameState.GameMode.MODE_3D:
		pass

func _on_app_opened(app_name: String, _window_id: String):
	_check_trigger(TutorialStepResource.TriggerType.APP_OPENED, app_name)

func _on_ticket_selected(ticket: TicketResource):
	if is_tutorial_active:
		_clear_all_app_highlights()
	_check_trigger(TutorialStepResource.TriggerType.TICKET_SELECTED, ticket.ticket_id)

func _on_email_read(email: EmailResource):
	if is_tutorial_active:
		_clear_all_app_highlights()
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

func _on_log_reviewed(_log_id: String):
	if is_tutorial_active:
		_clear_all_app_highlights()

func _on_log_read(log: LogResource):
	_check_trigger(TutorialStepResource.TriggerType.LOG_READ, log.log_id)

func _on_terminal_executed(cmd: String, success: bool, _out: String):
	if success:
		var cmd_name = cmd.split(" ")[0].to_lower()
		
		# REMEDIATION RESOLUTION
		if cmd_name == "restore":
			_resolve_remediation()
			
		_check_trigger(TutorialStepResource.TriggerType.COMMAND_RUN, cmd_name)

func _resolve_remediation():
	if GameState and GameState.desktop_instance:
		var sidebar = GameState.desktop_instance.get_node_or_null("%RunbookSidebar")
		if sidebar:
			sidebar.set_warning_mode(false)
			# Restore the actual current step instruction
			var step_data = sequence.get_step(current_step_index)
			if step_data:
				sidebar.update_task(current_step, step_data.instruction_text, step_data.comms_sender, step_data.comms_text)
	
	if NotificationManager:
		NotificationManager.show_notification("SYSTEM RESTORED. RESUMING CERTIFICATION.", "success", 4.0)

func _prepare_step_data(step_index: int):
	var step_enum = step_index + 1 # TutorialStep enum starts at 1
	var trn_005 = TicketManager.get_ticket_by_id("TRN-005") if TicketManager else null
	
	match step_enum:
		TutorialStep.NETSTAT_HUNT:
			# Step 31: Run netstat. We need to inject the malicious IP.
			if TerminalSystem:
				var target_ip = "203.0.113.55" # Fallback
				if trn_005 and not trn_005.truth_packet.is_empty():
					target_ip = trn_005.truth_packet.get("attacker_ip", target_ip)
				
				TerminalSystem.active_connections["WORKSTATION-T"] = [target_ip]
				print("TutorialManager: Injected netstat data for WORKSTATION-T: ", target_ip)
		
		TutorialStep.TRACE_HUNT:
			# Step 32: Run trace. We need to resolve the malicious IP.
			if TerminalSystem:
				var target_ip = "203.0.113.55" # Fallback
				if trn_005 and not trn_005.truth_packet.is_empty():
					target_ip = trn_005.truth_packet.get("attacker_ip", target_ip)
					
				TerminalSystem.trace_overrides[target_ip] = "CRIMSON_VISTA_C2_SERVER"
				print("TutorialManager: Injected trace override for: ", target_ip)
		
		TutorialStep.DECRYPTION_OPEN:
			# Step 34: Manual opening is preferred for the tutorial.
			# Just ensure it's provisioned.
			_provision_app("decrypt")

func _on_host_selected(host: HostResource):
	_check_trigger(TutorialStepResource.TriggerType.HOST_SELECTED, host.hostname)

func _on_ticket_completed(ticket: TicketResource, completion_type: String, _time):
	if not is_tutorial_active: return

	# REWARD: If they correctly finished the False Flag lesson
	if completion_type == "compliant" and ticket.ticket_id == "TRN-003" and IntegrityManager:
		IntegrityManager.restore_integrity(10.0)
		if NotificationManager:
			NotificationManager.show_notification("INTEGRITY REWARD: SOP ADHERENCE CONFIRMED", "success")
	
	# Transition Logic: Advance if this ticket completion was the current objective
	var step_enum = current_step_index + 1
	
	# VALIDATION: Ensure the correct type was chosen for the current lesson
	if ticket.ticket_id.begins_with("TRN-"):
		var expected_type = GlobalConstants.COMPLETION_TYPE.COMPLIANT
		if step_enum == TutorialStep.THE_SHORTCUT: # Step 28
			expected_type = GlobalConstants.COMPLETION_TYPE.EFFICIENT
			
		if completion_type != expected_type:
			_handle_remediation("UNAUTHORIZED_RESOLUTION_TYPE: " + completion_type.to_upper())
			# RE-SPAWN: Ensure the player can try again
			if TicketManager:
				TicketManager.spawn_ticket_by_id(ticket.ticket_id)
			return

	_check_trigger(TutorialStepResource.TriggerType.TICKET_COMPLETED, ticket.ticket_id)

# --- Core Lifecycle ---

func _sync_permissions(step_index: int):
	if not training_profile: return
	
	var step_id = step_index + 1
	
	# Tiered Unlock Logic (Cumulative)
	var apps_to_unlock = ["tickets", "email", "handbook"]
	
	if step_id >= 8:
		apps_to_unlock.append("siem")
	if step_id >= 13:
		apps_to_unlock.append("terminal")
		apps_to_unlock.append("network")
	if step_id >= 33: # Unlock one step early to ensure icon visibility
		apps_to_unlock.append("decrypt")
		
	for app in apps_to_unlock:
		if app not in training_profile.allowed_apps:
			training_profile.allowed_apps.append(app)
			
	# Update Desktop UI
	if DesktopWindowManager:
		DesktopWindowManager.active_permission_profile = training_profile

func _advance_step(new_index: int):
	# Mark previous task as complete in Sidebar if advancing
	if current_step_index >= 0:
		_complete_sidebar_task(current_step_index + 1)
		
	current_step_index = new_index
	var step_data = sequence.get_step(current_step_index)
	var step_enum = current_step_index + 1
	var desktop = GameState.desktop_instance if GameState else null
	
	if not step_data:
		# Final Step reached - Trigger the certification wrap-up
		_show_final_summary()
		return

	# State-Based Permission Catch-up
	_sync_permissions(new_index)

	if step_data.delay_before_start > 0:
		# Hide current visual focus while waiting
		if hud: hud.hide()
		
		await get_tree().create_timer(step_data.delay_before_start).timeout
		
		# Re-verify we haven't advanced again during the wait
		if current_step_index != new_index: return

	# 1. Transition Logic: Spawn follow-up training tickets based on trigger_id
	if step_data.trigger_id == "TRN-002" and step_data.trigger_type == TutorialStepResource.TriggerType.TICKET_SELECTED:
		if TicketManager: TicketManager.spawn_ticket_by_id("TRN-002")
	
	if step_data.trigger_id == "TRN-003" and step_data.trigger_type == TutorialStepResource.TriggerType.TICKET_SELECTED:
		if TicketManager: TicketManager.spawn_ticket_by_id("TRN-003")
	
	if step_enum == TutorialStep.THE_SHORTCUT:
		if TicketManager: TicketManager.spawn_ticket_by_id("TRN-004")
		
	if step_enum == TutorialStep.THE_CONSEQUENCE:
		if TicketManager: TicketManager.spawn_ticket_by_id("TRN-005")

	# JUMP SUPPORT: If this step is waiting for a ticket, ensure it exists
	if step_data.trigger_type == TutorialStepResource.TriggerType.TICKET_SELECTED:
		if TicketManager and not TicketManager.get_ticket_by_id(step_data.trigger_id):
			TicketManager.spawn_ticket_by_id(step_data.trigger_id)

	# 2. Prepare Technical Data (netstat/trace/provisioning)
	await _prepare_step_data(new_index)

	# 3. SYNC WAIT: Give the UI frames to instantiate cards/entries
	await get_tree().process_frame
	await get_tree().process_frame # Double-wait for safety

	# 4. Update HUD and Visual Guidance
	step_changed.emit(current_step_index + 1)
	
	if DialogueManager and DialogueManager.dialogue_box_instance:
		var db = DialogueManager.dialogue_box_instance
		if db.visible and db.is_waiting_for_task: db.advance_line()
	
	_show_instruction(step_data.instruction_text)
	_update_visual_focus()

	# Auto-Advance Step 24 (Read Policy Step)
	if current_step == 24:
		await get_tree().create_timer(7.0).timeout
		if current_step == 24: # Verify we haven't moved manually
			_advance_step(24)

	# Auto-Advance Step 27 (Certification Done Step)
	if current_step == 27:
		# Glow the Tickets icon early to prime the player
		if desktop and desktop.has_method("set_icon_glow"):
			desktop.set_icon_glow("tickets", true)
			
		await get_tree().create_timer(5.0).timeout
		if current_step == 27: # Verify we haven't moved manually
			_advance_step(27)

func _provision_app(app_id: String):
	if training_profile and app_id not in training_profile.allowed_apps:
		training_profile.allowed_apps.append(app_id)
		# Re-assign to trigger the setter/signal in DesktopWindowManager
		if DesktopWindowManager:
			DesktopWindowManager.active_permission_profile = training_profile
		print("TutorialManager: Provisioned app access: ", app_id)

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
	
	# 1. Start the transition sequence first
	if GameState and GameState.is_campaign_session:
		print("TutorialManager: Promoting player to active duty (Shift 1).")
		
		# Define promotion logic to run once screen is obscured
		var on_obscured = func():
			# TRIGGER CLEANUP: Strip filters and tutorial state while hidden
			EventBus.shift_ended.emit({})
			
			# INITIAL CHECKPOINT: Save progress as beginning of Monday
			if SaveSystem:
				SaveSystem.save_game()
		
		EventBus.transition_obscured.connect(on_obscured, CONNECT_ONE_SHOT)
		
		if TransitionManager:
			TransitionManager.play_secure_login("res://scenes/3d/BriefingRoom.tscn", "shift_monday", "[ SHIFT 1: MONDAY ]")
	else:
		print("TutorialManager: Standalone simulation complete. Returning to HQ.")
		
		var on_obscured = func():
			# TOTAL REFRESH: Purge all training data/memory before returning to Title
			if SaveSystem:
				SaveSystem.new_game_setup()
			EventBus.shift_ended.emit({})
			
		EventBus.transition_obscured.connect(on_obscured, CONNECT_ONE_SHOT)
		
		# IMMEDIATE TRANSITION: Back to Title Screen for a clean break
		if TransitionManager:
			TransitionManager.change_scene_to("res://scenes/3d/MainMenu3D.tscn")

func _update_visual_focus():
	if not is_tutorial_active or not sequence: return
	var step_data = sequence.get_step(current_step_index)
	if not step_data: return
	
	var desktop = GameState.desktop_instance if GameState else null
	
	# 1. Reset ALL visual glows (Desktop, Taskbar, Start Menu)
	if desktop and desktop.has_method("set_icon_glow"):
		var apps = ["tickets", "siem", "email", "terminal", "network", "decrypt", "start"]
		for a in apps: desktop.set_icon_glow(a, false)
	
	# 2. Reset ALL list-item highlights (Tickets, Emails, Logs)
	_clear_all_app_highlights()

	if step_data.highlight_path.is_empty():
		return

	# Handle Glow
	if not step_data.icon_glow_name.is_empty() and desktop:
		if desktop.has_method("set_icon_glow"):
			desktop.set_icon_glow(step_data.icon_glow_name, true)

	if step_data.highlight_path.begins_with("[DYNAMIC]"):
		_highlight_dynamic(step_data.highlight_path, step_data.highlight_tier)

func _highlight_dynamic(path: String, tier: int = 3):
	var step_data = sequence.get_step(current_step_index)
	if not step_data: return
	
	var desktop = GameState.desktop_instance if GameState else null
	
	match path:
		"[DYNAMIC]TICKET_LIST_0":
			var win = DesktopWindowManager._find_window_by_app("tickets")
			if win and "content_instance" in win and is_instance_valid(win.content_instance):
				var list = win.content_instance.get_node_or_null("%TicketList")
				if list:
					var target_card = null
					# Look for the card that matches the ID Rivera mentioned
					for child in list.get_children():
						if child.has_method("get_ticket_id") and child.get_ticket_id() == step_data.trigger_id:
							target_card = child
							break
					
					# Fallback to first child if no specific match
					if not target_card and list.get_child_count() > 0: 
						target_card = list.get_child(0)
					
					if target_card and is_instance_valid(target_card):
						# We MUST highlight the card, not the list!
						if target_card.has_method("set_tutorial_glow"):
							target_card.set_tutorial_glow(true)
					else:
						# If list is empty, pulse the icon on desktop instead
						if desktop and desktop.has_method("set_icon_glow"):
							desktop.set_icon_glow("tickets", true)
		"[DYNAMIC]TICKET_0_COMPLETE":
			var win = DesktopWindowManager._find_window_by_app("tickets")
			if win and "content_instance" in win and is_instance_valid(win.content_instance):
				var list = win.content_instance.get_node_or_null("%TicketList")
				if list:
					var target_card = null
					for child in list.get_children():
						if child.has_method("get_ticket_id") and child.get_ticket_id() == step_data.trigger_id:
							target_card = child
							break
					if not target_card and list.get_child_count() > 0: target_card = list.get_child(0)
					
					if target_card:
						# Pulse the WHOLE card
						if target_card.has_method("set_tutorial_glow"):
							target_card.set_tutorial_glow(true)
		"[DYNAMIC]COMPLETION_EFFICIENT":
			var win = DesktopWindowManager._find_window_by_app("tickets")
			if win and "content_instance" in win and is_instance_valid(win.content_instance):
				if win.content_instance.has_method("set_modal_glow"):
					win.content_instance.set_modal_glow(true)
		"[DYNAMIC]EMAIL_LIST_0":
			var win = DesktopWindowManager._find_window_by_app("email")
			if win and "content_instance" in win and is_instance_valid(win.content_instance):
				var list = win.content_instance.get_node_or_null("%EmailList")
				if list:
					var target_entry = null
					for child in list.get_children():
						if child.has_method("get_email_id") and child.get_email_id() == step_data.trigger_id:
							target_entry = child
							break
					if not target_entry and list.get_child_count() > 0: target_entry = list.get_child(0)
					
					if target_entry:
						if target_entry.has_method("set_tutorial_glow"):
							target_entry.set_tutorial_glow(true)
		"[DYNAMIC]EMAIL_TOOL_LINKS":
			var win = DesktopWindowManager._find_window_by_app("email")
			if win and "content_instance" in win and is_instance_valid(win.content_instance):
				if win.content_instance.has_method("set_tool_glow"):
					win.content_instance.set_tool_glow("links", true)
		"[DYNAMIC]EMAIL_LINK":
			pass
		"[DYNAMIC]LOG_LIST_0":
			var win = DesktopWindowManager._find_window_by_app("siem")
			if win and "content_instance" in win and is_instance_valid(win.content_instance):
				var list = win.content_instance.get_node_or_null("%LogList")
				if list:
					var target_entry = null
					for child in list.get_children():
						if child.has_method("get_log_data"):
							var data = child.get_log_data()
							if data and data.log_id == step_data.trigger_id:
								target_entry = child
								break
					if not target_entry and list.get_child_count() > 0: target_entry = list.get_child(0)
					
					if target_entry:
						if target_entry.has_method("set_tutorial_glow"):
							target_entry.set_tutorial_glow(true)
		"[DYNAMIC]MAP_NODE_T":
			var win = DesktopWindowManager._find_window_by_app("network")
			if win and "content_instance" in win and is_instance_valid(win.content_instance):
				var nodes = win.content_instance.get_node_or_null("%NodesContainer")
				if nodes and nodes.get_child_count() > 0:
					# Can add highlight logic to node here if needed
					pass

func _clear_all_app_highlights():
	# 1. Clear Ticket Card Glows
	var t_win = DesktopWindowManager._find_window_by_app("tickets")
	if t_win and "content_instance" in t_win and is_instance_valid(t_win.content_instance):
		var list = t_win.content_instance.get_node_or_null("%TicketList")
		if list:
			for child in list.get_children():
				if child.has_method("set_tutorial_glow"): child.set_tutorial_glow(false)
		
		# Also clear Modal Glows
		if t_win.content_instance.has_method("set_modal_glow"):
			t_win.content_instance.set_modal_glow(false)
	
	# 2. Clear Email List Highlights
	var e_win = DesktopWindowManager._find_window_by_app("email")
	if e_win and "content_instance" in e_win and is_instance_valid(e_win.content_instance):
		var list = e_win.content_instance.get_node_or_null("%EmailList")
		if list:
			for child in list.get_children():
				if child.has_method("set_tutorial_glow"): child.set_tutorial_glow(false)
		
		# Also clear Tool Glows
		if e_win.content_instance.has_method("set_tool_glow"):
			var tools = ["headers", "attachments", "links"]
			for t in tools: e_win.content_instance.set_tool_glow(t, false)
				
	# 3. Clear SIEM Log Highlights
	var s_win = DesktopWindowManager._find_window_by_app("siem")
	if s_win and "content_instance" in s_win and is_instance_valid(s_win.content_instance):
		var list = s_win.content_instance.get_node_or_null("%LogList")
		if list:
			for child in list.get_children():
				if child.has_method("set_highlight"): child.set_highlight(false)

	# 4. Clear Map Node Highlights
	var n_win = DesktopWindowManager._find_window_by_app("network")
	if n_win and "content_instance" in n_win and is_instance_valid(n_win.content_instance):
		var nodes = n_win.content_instance.get_node_or_null("%NodesContainer")
		if nodes:
			for child in nodes.get_children():
				if child.has_method("set_highlight"): child.set_highlight(false)

func _show_instruction(text: String):
	if text == "": return
	
	var step_data = sequence.get_step(current_step_index)
	
	# Diegetic Sidebar Integration
	if GameState and GameState.is_in_2d_mode() and GameState.desktop_instance:
		var sidebar = GameState.desktop_instance.get_node_or_null("%RunbookSidebar")
		if sidebar:
			sidebar.show()
			sidebar.update_task(current_step, text, step_data.comms_sender if step_data else "RIVERA", step_data.comms_text if step_data else "")
			return # Exit early, we don't need notification if sidebar is up
	
	# Meta-HUD Fallback (Notification Toast / HUD)
	if NotificationManager: NotificationManager.show_notification(text, "info", 12.0)
	if hud: hud.show()

func _complete_sidebar_task(step_id: int):
	if GameState and GameState.desktop_instance:
		var sidebar = GameState.desktop_instance.get_node_or_null("%RunbookSidebar")
		if sidebar:
			sidebar.complete_task(step_id)

func _get_instruction_for_step(step_idx: int) -> String:
	if sequence and step_idx >= 0 and step_idx < sequence.steps.size():
		return sequence.steps[step_idx].instruction_text
	return ""
