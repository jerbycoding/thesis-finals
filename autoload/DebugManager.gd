# DebugManager.gd
# Hotkey jumps for internal testing. (Not active in release builds)
extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("DebugManager initialized (F1-F10 enabled)")

func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
	
	# Check if keycode is one of our F-keys to avoid spamming output for every key
	if event.keycode >= KEY_F1 and event.keycode <= KEY_F12:
		print("DEBUG: Key pressed: ", OS.get_keycode_string(event.keycode))
		
	# Shift Jumps (F1-F5 Weekdays, F6 Saturday, F7 Sunday)
	match event.keycode:
		KEY_F1: _jump_to_shift("shift_monday")
		KEY_F2: _jump_to_shift("shift_tuesday")
		KEY_F3: _jump_to_shift("shift_wednesday")
		KEY_F4: _jump_to_shift("shift_thursday")
		KEY_F5: _jump_to_shift("shift_friday")
		KEY_F6: _jump_to_shift("shift_saturday")
		KEY_F7: _jump_to_shift("shift_sunday")
		
		KEY_F8: _toggle_integrity_freeze()
		KEY_F9: _force_spawn_ticket()
		KEY_F10: _reveal_all_evidence()

func _jump_to_shift(shift_id: String):
	print("DEBUG: Force jumping to shift: ", shift_id)
	
	# Check if the shift has a specific briefing dialogue
	var has_briefing = false
	if NarrativeDirector and NarrativeDirector.shift_library.has(shift_id):
		var shift_res = NarrativeDirector.shift_library[shift_id]
		# "default" usually implies generic chatter, not a scene-transitioning briefing
		if shift_res.briefing_dialogue_id != "" and shift_res.briefing_dialogue_id != "default":
			has_briefing = true
	
	if has_briefing:
		print("DEBUG: Shift has briefing. Routing through NarrativeDirector.")
		# Force stop any active shift so the briefing isn't blocked
		if NarrativeDirector.is_shift_active():
			NarrativeDirector.stop_shift()
		
		NarrativeDirector.trigger_briefing(shift_id)
		return

	# Fallback: Direct Jump (No Briefing or 'default' dialogue)
	var floor_path = "res://scenes/SOC_Office.tscn"
	var title = "[ DEBUG SHIFT OVERRIDE ]"
	
	if shift_id == "shift_saturday":
		floor_path = "res://scenes/3d/NetworkHub.tscn"
	elif shift_id == "shift_sunday":
		floor_path = "res://scenes/3d/ServerVault.tscn"
	
	if TransitionManager:
		TransitionManager.change_scene_to(floor_path, shift_id, title)

func _toggle_integrity_freeze():
	if IntegrityManager:
		IntegrityManager.is_decay_active = !IntegrityManager.is_decay_active
		var state = "FROZEN" if !IntegrityManager.is_decay_active else "ACTIVE"
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: Integrity Decay " + state, "info")

func _force_spawn_ticket():
	if TicketManager:
		TicketManager.spawn_random_ticket()

func _reveal_all_evidence():
	# Mark all logs in the system as revealed for current investigation
	if LogSystem:
		for log in LogSystem.active_logs:
			log.is_revealed = true
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: Evidence Revealed", "success")
