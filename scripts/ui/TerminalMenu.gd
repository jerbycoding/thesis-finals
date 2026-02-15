extends Control

@onready var text_label: RichTextLabel = %TerminalLabel
@onready var input_timer: Timer = $InputTimer

var boot_sequence = []
var is_booting = true
var has_save: bool = false

signal action_selected(action_id: String)

func _ready():
	text_label.text = ""
	has_save = SaveSystem.has_save_file() if SaveSystem else false
	_build_boot_sequence()
	_start_boot_sequence()

func _build_boot_sequence():
	# CLASSIC LONE ANALYST STYLE (GREEN ON BLACK)
	boot_sequence = [
		"VERIFY WORKSTATION v4.7.2",
		"BIOS: Phoenix Technologies Ltd.",
		"Initializing security modules... [ OK ]",
		"Checking integrity... [ OK ]",
		" ",
		"SHIFT TRANSITION PROTOCOL ACTIVE",
		"===========================================================",
		"PREVIOUS OPERATOR: ANALYST_7734 [VERIFIED]",
		"SESSION END: 2024-02-10 22:47:11 UTC",
		"SYSTEM STATUS: NOMINAL",
		"-----------------------------------------------------------",
		"AWAITING REPLACEMENT OPERATOR...",
		" ",
		"> AUTHENTICATION REQUIRED",
		"> ANALYST CLEARANCE VERIFIED",
		" ",
		"> SELECT ACTION:"
	]
	
	if has_save:
		boot_sequence.append("  [1] START_NEW_SHIFT")
		boot_sequence.append("  [2] RESUME_PROTOCOL")
		boot_sequence.append("  [3] TRAINING_SIMULATION")
		boot_sequence.append("  [4] TERMINATE_SESSION")
	else:
		boot_sequence.append("  [1] START_NEW_SHIFT")
		boot_sequence.append("  [2] TRAINING_SIMULATION")
		boot_sequence.append("  [3] TERMINATE_SESSION")
	
	boot_sequence.append(" ")
	boot_sequence.append("> AWAITING INPUT_")

func _start_boot_sequence():
	for line in boot_sequence:
		text_label.text += line + "\n"
		if line.strip_edges() != "":
			if AudioManager:
				AudioManager.play_sfx(AudioManager.SFX.button_click)
		await get_tree().create_timer(0.05).timeout
	
	is_booting = false

func _input(event):
	if is_booting: return
	
	if event is InputEventKey and event.pressed:
		if has_save:
			match event.keycode:
				KEY_1: _on_action_selected("start")
				KEY_2: _on_action_selected("continue")
				KEY_3: _on_action_selected("training")
				KEY_4: _on_action_selected("quit")
		else:
			match event.keycode:
				KEY_1: _on_action_selected("start")
				KEY_2: _on_action_selected("training")
				KEY_3: _on_action_selected("quit")

func _on_action_selected(action_id: String):
	if is_booting: return
	
	if AudioManager:
		AudioManager.play_notification("info")
	
	action_selected.emit(action_id)
	
	# Classic feedback
	text_label.text += "\n> EXECUTING " + action_id.to_upper() + "..."