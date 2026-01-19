# DebugManager.gd
# Hotkey jumps for internal testing. (Not active in release builds)
extends Node

func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
		
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
	
	# Determine destination floor
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
