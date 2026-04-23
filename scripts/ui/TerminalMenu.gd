# TerminalMenu.gd
extends Control

@onready var text_label: RichTextLabel = %TerminalLabel
@onready var button_container: VBoxContainer = %ButtonContainer
@onready var input_timer: Timer = $InputTimer

enum MenuState { BOOTING, MAIN, CONFIRMING, ARCHIVE, CONFIGING, CREDITS, DIFFICULTY, LEVEL_SELECT, ASK_TUTORIAL }
var current_state = MenuState.BOOTING
var pending_action: String = ""
var has_save: bool = false
var is_veteran: bool = false
var boot_sequence = []
var shift_list: Array[ShiftResource] = []

signal action_selected(action_id: String)

func _ready():
	current_state = MenuState.BOOTING
	text_label.text = ""
	has_save = SaveSystem.has_save_file() if SaveSystem else false
	is_veteran = ConfigManager.settings.gameplay.campaign_completed if ConfigManager else false
	_load_shift_data()
	_build_boot_sequence()
	_start_boot_sequence()

func _load_shift_data():
	var raw_list = []
	if NarrativeDirector and not NarrativeDirector.shift_library.is_empty():
		for id in NarrativeDirector.shift_library:
			raw_list.append(NarrativeDirector.shift_library[id])
	else:
		var loaded = FileUtil.load_and_validate_resources("res://resources/shifts/", "ShiftResource")
		for res in loaded:
			raw_list.append(res)
	
	raw_list.sort_custom(_compare_shifts_chronologically)
	shift_list.assign(raw_list)

func _compare_shifts_chronologically(a: ShiftResource, b: ShiftResource) -> bool:
	return _get_shift_weight(a.shift_id) < _get_shift_weight(b.shift_id)

func _get_shift_weight(id: String) -> int:
	if "tutorial" in id: return 0
	if "monday" in id and not "week2" in id: return 1
	if "tuesday" in id and not "week2" in id: return 2
	if "wednesday" in id and not "week2" in id: return 3
	if "thursday" in id and not "week2" in id: return 4
	if "friday" in id and not "week2" in id: return 5
	if "saturday" in id: return 6
	if "sunday" in id: return 7
	if "week2_monday" in id: return 8
	if "week2_tuesday" in id: return 9
	if "week2_wednesday" in id: return 10
	if "week2_thursday" in id: return 11
	if "week2_friday" in id: return 12
	return 99

func _build_boot_sequence():
	# HIGH-TECH IR WORKSTATION STYLE
	boot_sequence = [
		"VERIFY_OS [Version 10.0.19045.SOC]",
		"(c) 2024 Verify Corp. All rights reserved.",
		" ",
		"[ OK ] Mapped kernel memory (0x000000 - 0x00FFFF)",
		"[ OK ] Initialized EDR Endpoint Agent [PID: 104]",
		"[ OK ] Established connection to SIEM_CENTRAL",
		" ",
		"LAST_LOGIN: 2024-02-11 04:12:11 from 10.0.4.2",
		"STATION_ID: SOC-ALPHA-09",
		"ASSIGNED_SUBNET: 192.168.100.0/24",
		" ",
		"SYSTEM_STATUS: NOMINAL",
		"ACTIVE_THREAT_INTEL: SYNCHRONIZED",
		" ",
		"> ACCESS_CONTROL_ENTRY_POINT",
		"> AWAITING ANALYST_CREDENTIALS...",
		" ",
		"> SELECT_OPERATIONAL_MODE:"
	]

	if has_save:
		pass
	else:
		pass

	boot_sequence.append(" ")
	boot_sequence.append("> SYSTEM_READY. AWAITING_AUTHORIZATION...")

func _start_boot_sequence():
	current_state = MenuState.BOOTING
	_clear_buttons()
	
	for line in boot_sequence:
		text_label.text += line + "\n"
		if line.strip_edges() != "":
			if AudioManager:
				AudioManager.play_sfx(AudioManager.SFX.button_click)
		await get_tree().create_timer(0.02).timeout
	
	_show_main_menu_options()
	current_state = MenuState.MAIN

func _input(event):
	if current_state == MenuState.BOOTING: return
	
	if event is InputEventKey and event.pressed:
		if current_state == MenuState.MAIN:
			_handle_main_menu_input(event.keycode)
		elif current_state == MenuState.CONFIRMING:
			_handle_confirmation_input(event.keycode)
		elif current_state == MenuState.ASK_TUTORIAL:
			_handle_tutorial_ask_input(event.keycode)
		elif current_state == MenuState.ARCHIVE:
			_handle_archive_input(event.keycode)
		elif current_state == MenuState.CONFIGING:
			_handle_config_input(event.keycode)
		elif current_state == MenuState.CREDITS:
			_show_main_menu()
		elif current_state == MenuState.DIFFICULTY:
			_handle_difficulty_input(event.keycode)
		elif current_state == MenuState.LEVEL_SELECT:
			_handle_level_select_input(event.keycode)

func _handle_main_menu_input(keycode: int):
	if has_save:
		match keycode:
			KEY_1: _on_action_selected("continue")
			KEY_2: _try_action("start_new")
			KEY_3: _try_action("hacker_campaign")  # NEW: Hacker Campaign
			KEY_4: _try_action("training")
			KEY_5: _show_archive()
			KEY_6: _show_config()
			KEY_7: _show_credits()
			KEY_8: _on_action_selected("quit")
			KEY_9: if is_veteran: _show_level_select()
	else:
		match keycode:
			KEY_1: _try_action("start_new")
			KEY_2: _try_action("hacker_campaign")  # NEW: Hacker Campaign
			KEY_3: _try_action("training")
			KEY_4: _show_archive()
			KEY_5: _show_config()
			KEY_6: _show_credits()
			KEY_7: _on_action_selected("quit")
			KEY_8: if is_veteran: _show_level_select()

func _try_action(action_id: String):
	if has_save:
		_show_overwrite_warning(action_id)
	else:
		if action_id == "start_new":
			_show_tutorial_ask()
		elif action_id == "training":
			# Bypassing difficulty for explicit training request
			if ConfigManager: ConfigManager.set_setting("gameplay", "difficulty_level", 0) # 0 = Junior
			_on_action_selected("training")
		else:
			_on_action_selected(action_id)

func _show_tutorial_ask():
	current_state = MenuState.ASK_TUTORIAL
	text_label.text = "\n\n  [!] SECURE_ONBOARDING_PROTOCOL\n  -----------------------------------------------------------\n  New analyst detected. Execute certification module?\n\n  [1] INITIALIZE_TRAINING (RECOMMENDED)\n  [2] BYPASS_TO_ACTIVE_DUTY (VETERAN_ONLY)\n\n  [ESC] ABORT_MISSION_START\n\n  > SELECT PROTOCOL_"
	if AudioManager: AudioManager.play_notification("info")

func _handle_tutorial_ask_input(keycode: int):
	if keycode == KEY_ESCAPE: _show_main_menu(); return
	match keycode:
		KEY_1: 
			# Choice: Tutorial. Set default difficulty and bypass selection screen.
			if ConfigManager: ConfigManager.set_setting("gameplay", "difficulty_level", 0) # 0 = Junior
			_on_action_selected("start_tutorial")
		KEY_2:
			# Choice: Campaign. Proceed to difficulty selection as usual.
			pending_action = "start_campaign"
			_show_difficulty_selection()

func _show_difficulty_selection():
	current_state = MenuState.DIFFICULTY
	text_label.text = "MISSION_PROTOCOL :: SELECT OPERATIONAL RIGOR\n===========================================================\n\n"
	for i in range(3):
		var data = GlobalConstants.DIFFICULTY_DATA[i]
		text_label.text += "  [%d] %s\n      > %s\n\n" % [i+1, data.label, data.description]
	text_label.text += "  [ESC] ABORT_MISSION_START\n\n> SELECT RIGOR_LEVEL:"

func _handle_difficulty_input(keycode: int):
	if keycode == KEY_ESCAPE: _show_main_menu(); return
	var tier = -1
	match keycode:
		KEY_1: tier = 0
		KEY_2: tier = 1
		KEY_3: tier = 2
	if tier != -1:
		if ConfigManager: ConfigManager.set_setting("gameplay", "difficulty_level", tier)
		_on_action_selected(pending_action)

func _show_overwrite_warning(action_id: String):
	current_state = MenuState.CONFIRMING
	pending_action = action_id
	text_label.text = "\n\n\n  [!] WARNING: EXISTING SESSION DATA DETECTED\n  -----------------------------------------------------------\n  Starting a new shift will eventually overwrite progress.\n\n  [1] CONFIRM_OVERWRITE (PROCEED)\n  [2] ABORT_AND_RETURN\n\n  > AWAITING AUTHENTICATION_"
	if AudioManager: AudioManager.play_notification("warning")

func _show_config():
	current_state = MenuState.CONFIGING
	_refresh_config_display()

func _refresh_config_display():
	if not ConfigManager: return
	var s = ConfigManager.settings
	text_label.text = "SYSTEM_CONFIGURATION :: OPERATIONAL_PARAMETERS\n===========================================================\n\n  [1] VIDEO_MODE: %s\n  [2] CRT_EMULATION: [%s]\n  [3] MOUSE_SENSITIVITY: %.4f\n  [4] MASTER_VOLUME: %d%%\n  [5] CAMPAIGN_PURGE\n\n  [ESC] RETURN_TO_ROOT\n\n> SELECT PARAM_ID:" % ["FULLSCREEN" if s.display.fullscreen else "WINDOWED", "ON" if s.display.crt_enabled else "OFF", s.input.mouse_sensitivity, int(s.audio.master_volume * 100)]

func _handle_config_input(keycode: int):
	if keycode == KEY_ESCAPE: _show_main_menu(); return
	match keycode:
		KEY_1: ConfigManager.set_setting("display", "fullscreen", !ConfigManager.settings.display.fullscreen); _refresh_config_display()
		KEY_2: ConfigManager.set_setting("display", "crt_enabled", !ConfigManager.settings.display.crt_enabled); _refresh_config_display()
		KEY_3: 
			var new_val = ConfigManager.settings.input.mouse_sensitivity + 0.0005
			if new_val > 0.005: new_val = 0.0005
			ConfigManager.set_setting("input", "mouse_sensitivity", new_val); _refresh_config_display()
		KEY_4:
			var new_val = ConfigManager.settings.audio.master_volume + 0.1
			if new_val > 1.0: new_val = 0.0
			ConfigManager.set_setting("audio", "master_volume", new_val); _refresh_config_display()
		KEY_5: _show_purge_confirmation()

func _show_purge_confirmation():
	text_label.text = "\n\n\n  [!] DANGER: IRREVERSIBLE DATA DESTRUCTION\n  -----------------------------------------------------------\n  [1] CONFIRM_PURGE (ERASE)\n  [2] ABORT_ACTION\n\n  > AWAITING DESTRUCTION_AUTHORIZATION_"
	if AudioManager: AudioManager.play_notification("error")

func _show_archive():
	current_state = MenuState.ARCHIVE
	text_label.text = "CAMPAIGN_ARCHIVE :: MISSION_LOGS\n===========================================================\n\n"
	for i in range(min(9, shift_list.size())):
		text_label.text += "  [%d] [ ] %s\n" % [i+1, shift_list[i].shift_name]
	text_label.text += "\n  [ESC] RETURN_TO_MENU\n\n> SELECT MISSION_ID:"

func _handle_archive_input(keycode: int):
	if keycode == KEY_ESCAPE: _show_main_menu(); return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx = keycode - KEY_1
		if idx < shift_list.size(): _show_shift_details(shift_list[idx])
	else: _show_archive()

func _show_shift_details(shift: ShiftResource):
	text_label.text = "TECHNICAL_BRIEFING :: %s\n===========================================================\n\n[ MISSION_SUMMARY ]\n%s\n\n[ CYBERSECURITY_CONTEXT ]\n%s\n\n-----------------------------------------------------------\n  [ANY_KEY] RETURN_TO_ARCHIVE" % [shift.shift_name.to_upper(), shift.shift_summary, shift.cyber_context]

func _show_level_select():
	current_state = MenuState.LEVEL_SELECT
	text_label.text = "OVERRIDE_PROTOCOL :: DIRECT_MISSION_INSERTION\n===========================================================\n\n"
	for i in range(min(9, shift_list.size())):
		text_label.text += "  [%d] INSERT_INTO: %s\n" % [i+1, shift_list[i].shift_name]
	text_label.text += "\n  [ESC] ABORT_OVERRIDE\n\n> SELECT TARGET MISSION_ID:"

func _handle_level_select_input(keycode: int):
	if keycode == KEY_ESCAPE: _show_main_menu(); return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx = keycode - KEY_1
		if idx < shift_list.size(): _execute_override_jump(shift_list[idx].shift_id)

func _execute_override_jump(shift_id: String):
	text_label.text = "\n\n  OVERRIDE_VERIFIED. BYPASSING STANDARD TIMELINE...\n  INITIALIZING DIRECT INSERTION INTO [%s]" % shift_id.to_upper()
	if AudioManager: AudioManager.play_terminal_beep()
	await get_tree().create_timer(1.0).timeout
	if SaveSystem: SaveSystem.new_game_setup()
	if NarrativeDirector: NarrativeDirector.trigger_briefing(shift_id)

func _show_credits():
	current_state = MenuState.BOOTING
	text_label.text = ""
	var credits = [
		"VERIFY.EXE :: PROJECT_ATTRIBUTION",
		"===========================================================",
		" ",
		"CORE_DEVELOPMENT:",
		"-----------------------------------------------------------",
		"HANS JERBY DE LANA",
		"  > LEAD_PROGRAMMER",
		"  > SYSTEMS_ARCHITECT",
		"  > TECHNICAL_ENGINEER",
		" ",
		"NARRATIVE_&_DESIGN:",
		"-----------------------------------------------------------",
		"MARK LANDER DURIAS",
		"  > CREATIVE_DIRECTOR",
		"  > LEAD_DESIGNER",
		"  > SCENARIO_WRITER",
		" ",
		"ACADEMIC_ADVISOR / INSTRUCTOR:",
		"-----------------------------------------------------------",
		"BERNARD GONZALES",
		" ",
		"SPECIAL_THANKS:",
		"-----------------------------------------------------------",
		"GODOT_ENGINE_COMMUNITY",
		"IR_SECURITY_PROFESSIONALS",
		" ",
		"===========================================================",
		"LICENSE: ACADEMIC_THESIS_PROTOTYPE",
		" ",
		"  [ANY_KEY] RETURN_TO_TERMINAL"
	]
	for line in credits:
		text_label.text += line + "\n"
		if AudioManager: AudioManager.play_terminal_beep(-15.0)
		await get_tree().create_timer(0.08).timeout
	current_state = MenuState.CREDITS

func _show_main_menu_options():
	_clear_buttons()
	
	if has_save:
		_create_menu_button("RESUME_SESSION", "continue", "1")
		_create_menu_button("NEW_CAMPAIGN", "start_new", "2")
		_create_menu_button("HACKER_MODE", "hacker_campaign", "3")
		_create_menu_button("TRAINING", "training", "4")
		_create_menu_button("ARCHIVE", "archive", "5")
		_create_menu_button("SETTINGS", "config", "6")
		_create_menu_button("CREDITS", "credits", "7")
		_create_menu_button("TERMINATE", "quit", "8")
		if is_veteran:
			_create_menu_button("OVERRIDE", "level_select", "9")
	else:
		_create_menu_button("START_CAMPAIGN", "start_new", "1")
		_create_menu_button("HACKER_MODE", "hacker_campaign", "2")
		_create_menu_button("TRAINING", "training", "3")
		_create_menu_button("ARCHIVE", "archive", "4")
		_create_menu_button("SETTINGS", "config", "5")
		_create_menu_button("CREDITS", "credits", "6")
		_create_menu_button("TERMINATE", "quit", "7")
		if is_veteran:
			_create_menu_button("OVERRIDE", "level_select", "8")

func _create_menu_button(label_text: String, action_id: String, shortcut: String = ""):
	var btn = Button.new()
	btn.text = " [%s] %s " % [shortcut, label_text] if shortcut != "" else " %s " % label_text
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.flat = true
	
	# Styling via code for terminal feel
	btn.add_theme_color_override("font_color", Color(0, 0.8, 0.2))
	btn.add_theme_color_override("font_hover_color", Color(0, 1, 0.5))
	btn.add_theme_font_size_override("font_size", 18)
	
	btn.pressed.connect(func(): _on_button_pressed(action_id))
	btn.mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())
	
	if button_container:
		button_container.add_child(btn)

func _on_button_pressed(action_id: String):
	if current_state == MenuState.BOOTING: return
	
	match action_id:
		"archive": _show_archive()
		"config": _show_config()
		"credits": _show_credits()
		"level_select": _show_level_select()
		"start_new", "training", "hacker_campaign", "continue", "quit":
			_try_action(action_id)

func _clear_buttons():
	if button_container:
		for child in button_container.get_children():
			child.queue_free()

func _show_main_menu():
	text_label.text = "VERIFY_OS :: SYSTEM_READY\n---------------------------------\n"
	_show_main_menu_options()
	current_state = MenuState.MAIN

func _handle_confirmation_input(keycode: int):
	match keycode:
		KEY_1:
			if text_label.text.contains("DESTRUCTION"): _execute_purge()
			elif text_label.text.contains("WARNING"):
				if pending_action == "start_new":
					_show_tutorial_ask()
				elif pending_action == "training":
					# Handle overwrite confirm for training: bypass difficulty
					if ConfigManager: ConfigManager.set_setting("gameplay", "difficulty_level", 0)
					_on_action_selected("training")
				else:
					_on_action_selected(pending_action)
		KEY_2: _show_main_menu()

func _execute_purge():
	if SaveSystem:
		SaveSystem.new_game_setup()
		if FileAccess.file_exists(SaveSystem.SAVE_PATH): DirAccess.remove_absolute(SaveSystem.SAVE_PATH)
	text_label.text = "DATA_PURGE_COMPLETE. SYSTEM_REBOOTING..."
	if AudioManager: AudioManager.play_terminal_beep()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_action_selected(action_id: String):
	if current_state == MenuState.BOOTING: return
	if AudioManager: AudioManager.play_notification("info")
	action_selected.emit(action_id)
	text_label.text += "\n> EXECUTING " + action_id.to_upper() + "..."
