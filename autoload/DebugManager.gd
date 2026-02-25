# DebugManager.gd
# Hotkey jumps and real-time HUD for internal testing. (Not active in release builds)
extends Node

var debug_hud: CanvasLayer
var debug_label: RichTextLabel
var is_hud_visible: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Wait one frame to ensure SceneTree is ready
	await get_tree().process_frame
	_create_debug_hud()
	
	print("DebugManager: Hybrid Navigation & HUD Active")
	print("  - F1 / F2: Previous / Next Shift")
	print("  - F9: Trigger Random Pool Event (Chaos)")
	print("  - F10 / F11: Decrease / Increase Integrity (10%)")
	print("  - F12: Toggle Debug HUD")
	print("  - Shift + F1-F7: Week 1 Jumps")
	print("  - Ctrl + F1-F5: Week 2 Jumps")

func _create_debug_hud():
	# If it already exists (from a previous load), remove it
	if get_tree().root.has_node("DEBUG_HUD_LAYER"):
		get_tree().root.get_node("DEBUG_HUD_LAYER").queue_free()

	debug_hud = CanvasLayer.new()
	debug_hud.name = "DEBUG_HUD_LAYER"
	debug_hud.layer = 128 # Above standard game HUDs
	get_tree().root.add_child.call_deferred(debug_hud)
	
	var panel = Panel.new()
	panel.name = "DebugPanel"
	# Explicit sizing and positioning to avoid anchor issues in code
	panel.size = Vector2(380, 550)
	panel.position = Vector2(get_viewport().get_visible_rect().size.x - 390, 10)
	panel.modulate = Color(1, 1, 1, 0.9)
	debug_hud.add_child(panel)
	
	debug_label = RichTextLabel.new()
	debug_label.name = "DebugLabel"
	debug_label.size = panel.size - Vector2(20, 20)
	debug_label.position = Vector2(10, 10)
	debug_label.bbcode_enabled = true
	debug_label.scroll_active = true
	panel.add_child(debug_label)
	
	debug_hud.visible = false

func _process(_delta):
	if is_hud_visible:
		_update_debug_hud()
		# Update position in case window resized
		if debug_hud and debug_hud.has_node("DebugPanel"):
			var panel = debug_hud.get_node("DebugPanel")
			panel.position.x = get_viewport().get_visible_rect().size.x - panel.size.x - 10

func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
	
	# Global Debug Capture (confirming keys are reaching this autoload)
	if event.keycode >= KEY_F1 and event.keycode <= KEY_F12:
		print("DEBUG_INPUT: Captured %s (Shift: %s, Ctrl: %s)" % [OS.get_keycode_string(event.keycode), event.shift_pressed, event.ctrl_pressed])

	# Toggle HUD (F12)
	if event.keycode == KEY_F12:
		is_hud_visible = !is_hud_visible
		if debug_hud:
			debug_hud.visible = is_hud_visible
		return

	# sequential Navigation (F1 / F2) and Chaos Event (F9)
	if not event.shift_pressed and not event.ctrl_pressed:
		if event.keycode == KEY_F1:
			_jump_previous_shift()
		elif event.keycode == KEY_F2:
			_jump_next_shift()
		elif event.keycode == KEY_F9:
			print("DEBUG: F9 pressed - Attempting to trigger Chaos Event")
			_trigger_chaos_event()
		elif event.keycode == KEY_F10:
			if IntegrityManager:
				IntegrityManager.debug_modify_integrity(-10.0)
		elif event.keycode == KEY_F11:
			if IntegrityManager:
				IntegrityManager.debug_modify_integrity(10.0)
		return

	# Direct Week 1 Jumps (Shift + F1-F7)
	if event.shift_pressed:
		match event.keycode:
			KEY_F1: _jump_to_shift("shift_monday")
			KEY_F2: _jump_to_shift("shift_tuesday")
			KEY_F3: _jump_to_shift("shift_wednesday")
			KEY_F4: _jump_to_shift("shift_thursday")
			KEY_F5: _jump_to_shift("shift_friday")
			KEY_F6: _jump_to_shift("shift_saturday")
			KEY_F7: _jump_to_shift("shift_sunday")
		return

	# Direct Week 2 Jumps (Ctrl + F1-F5)
	if event.ctrl_pressed:
		match event.keycode:
			KEY_F1: _jump_to_shift("shift_week2_monday")
			KEY_F2: _jump_to_shift("shift_week2_tuesday")
			KEY_F3: _jump_to_shift("shift_week2_wednesday")
			KEY_F4: _jump_to_shift("shift_week2_thursday")
			KEY_F5: _jump_to_shift("shift_week2_friday")
		return

func _update_debug_hud():
	if not debug_label: return
	
	var text = "[center][b][color=cyan]VERIFY.EXE DEBUG HUD[/color][/b][/center]\n"
	text += "[color=gray]------------------------------------[/color]\n"
	
	# SHIFT INFO
	if NarrativeDirector:
		var s_id = NarrativeDirector.current_shift_name if NarrativeDirector.current_shift_name != "" else "NONE"
		var active = "ACTIVE" if NarrativeDirector.is_shift_active() else "IDLE"
		text += "[b]Shift:[/b] %s (%s)\n" % [s_id, active]
		
		var current_res = NarrativeDirector.current_shift_resource
		if current_res:
			if NarrativeDirector.is_shift_active():
				var time = NarrativeDirector.get_shift_timer()
				var duration = NarrativeDirector.get_current_shift_duration()
				text += "[b]Time:[/b] %.1fs / %.1fs\n" % [time, duration]
				text += "[b]Progress:[/b] %d / %d Events\n" % [NarrativeDirector.current_event_index, NarrativeDirector.current_active_arc.size()]
			else:
				text += "[color=orange][i](In Briefing / Pre-Shift)[/i][/color]\n"
			
			# RANDOM POOL
			text += "\n[color=yellow][b]Chaos Pool (F9 to trigger):[/b][/color]\n"
			if not current_res.random_event_pool.is_empty():
				for event in current_res.random_event_pool:
					var ev_label = event.get("event", "Unknown")
					var tech_id = event.get("event_id", event.get("ticket_id", event.get("type", "N/A")))
					text += "- %s [color=gray](%s)[/color]\n" % [ev_label, tech_id]
			else:
				text += "[color=red]- EMPTY POOL[/color]\n"
		else:
			text += "[color=red]- NO SHIFT LOADED[/color]\n"
	
	text += "[color=gray]------------------------------------[/color]\n"
	
	# METRICS
	if IntegrityManager:
		var hp = IntegrityManager.current_integrity
		var hp_color = "green" if hp > 50 else ("yellow" if hp > 20 else "red")
		text += "[b]Integrity:[/b] [color=%s]%.1f%%[/color]\n" % [hp_color, hp]
		
	if HeatManager:
		text += "[b]Week:[/b] %d\n" % HeatManager.current_week
		text += "[b]Base Heat:[/b] %.2fx\n" % HeatManager.heat_multiplier
		
		var effective = HeatManager.get_effective_multiplier()
		var color = "green" if effective < 1.0 else ("orange" if effective < 1.5 else "red")
		text += "[b]Effective Pressure:[/b] [color=%s]%.2fx[/color]\n" % [color, effective]
		
		text += "[b]Vulnerability Buffer:[/b] %d / 10\n" % HeatManager.vulnerability_buffer.size()

	text += "[color=gray]------------------------------------[/color]\n"
	text += "[i][size=12]F1/F2: Prev/Next | F9: Chaos | F10/F11: Integrity | F12: HUD[/size][/i]"
	
	debug_label.text = text

func _trigger_chaos_event():
	if NarrativeDirector:
		print("DEBUG: Calling NarrativeDirector.force_random_event()...")
		NarrativeDirector.force_random_event()

func _jump_next_shift():
	if not NarrativeDirector or not NarrativeDirector.current_shift_resource:
		# If no shift is active, jump to Monday
		_jump_to_shift("shift_monday")
		return
	
	var next_id = NarrativeDirector.current_shift_resource.next_shift_id
	if next_id != "":
		_jump_to_shift(next_id)
	else:
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: End of Shift Library reached.", "warning")

func _jump_previous_shift():
	if not NarrativeDirector or not NarrativeDirector.current_shift_resource:
		return
	
	var current_id = NarrativeDirector.current_shift_name
	var prev_id = ""
	
	# Find the shift that has 'current_id' as its next_shift_id
	for shift_id in NarrativeDirector.shift_library:
		var res = NarrativeDirector.shift_library[shift_id]
		if res.next_shift_id == current_id:
			prev_id = shift_id
			break
	
	if prev_id != "":
		_jump_to_shift(prev_id)
	else:
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: No previous shift found.", "warning")

func _jump_to_shift(shift_id: String):
	print("DEBUG: Force jumping to shift: ", shift_id)
	
	# Check if the shift exists
	if not NarrativeDirector or not NarrativeDirector.shift_library.has(shift_id):
		print("DEBUG: Shift ID not found: ", shift_id)
		if NotificationManager:
			NotificationManager.show_notification("DEBUG: Shift NOT FOUND: " + shift_id, "error")
		return

	# Force stop current state
	if NarrativeDirector.is_shift_active():
		NarrativeDirector.stop_shift()

	# If the shift has a briefing, route through NarrativeDirector
	var shift_res = NarrativeDirector.shift_library[shift_id]
	if shift_res.briefing_dialogue_id != "" and shift_res.briefing_dialogue_id != "default":
		print("DEBUG: Shift has briefing. Routing through NarrativeDirector.")
		NarrativeDirector.trigger_briefing(shift_id)
		return

	# Fallback: Direct Scene Jump (Weekends usually)
	var floor_path = "res://scenes/SOC_Office.tscn"
	var title = "[ DEBUG SHIFT OVERRIDE ]"
	
	if shift_id == "shift_saturday":
		floor_path = "res://scenes/3d/NetworkHub.tscn"
	elif shift_id == "shift_sunday":
		floor_path = "res://scenes/3d/ServerVault.tscn"
	
	if TransitionManager:
		TransitionManager.change_scene_to(floor_path, shift_id, title)
