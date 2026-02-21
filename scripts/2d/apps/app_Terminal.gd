# app_Terminal.gd
extends Control

var command_history: Array[String] = []
var history_index: int = -1
var current_ticket_id: String = ""

@onready var output_text: RichTextLabel = %OutputText
@onready var command_input: LineEdit = %CommandInput
@onready var metadata_box: PanelContainer = %MetadataBox
@onready var metadata_label: RichTextLabel = %MetadataLabel

# --- Typewriter Logic ---
var _output_queue: Array[String] = []
var _is_typing: bool = false
var _typewriter_speed: float = 0.01
var _current_tween: Tween

var is_glitch_active: bool = false

func _ready():
	print("======= App_Terminal (TUI Redesign) Ready =======")
	
	visible = true
	modulate = Color.WHITE
	
	command_input.text_submitted.connect(_on_command_submitted)
	command_input.gui_input.connect(_on_command_gui_input)
	command_input.grab_focus()
	
	if TerminalSystem:
		TerminalSystem.command_output_received.connect(_on_terminal_output_received)
	
	EventBus.world_event_triggered.connect(_on_world_event)
	
	_append_output("[color=gray]SOC_CORE v4.4 Operating System[/color]\n[color=gray]Unauthorized access is strictly prohibited.[/color]\n\n")
	_append_output("Type [color=cyan]help[/color] to list available forensic modules.\n\n")

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == GlobalConstants.EVENTS.ZERO_DAY or event_id == GlobalConstants.EVENTS.DDOS_ATTACK:
		is_glitch_active = active

func _on_terminal_output_received(text: String, _is_partial: bool):
	var processed_text = text
	if is_glitch_active and randf() < 0.2:
		# Simulate data corruption during Zero Day
		var glitch_chars = "01#!@$%%^&*()_+"
		var text_chars = text.split("")
		for i in range(min(5, text.length())):
			var pos = randi() % text.length()
			if text[pos] != " " and text[pos] != "\n":
				text_chars[pos] = glitch_chars[randi() % glitch_chars.length()]
		processed_text = "".join(text_chars)
				
	_append_output(processed_text)

func _on_command_gui_input(event):
	if event is InputEventKey and event.pressed:
		# Don't play for non-character keys like Enter or Shift
		if event.unicode > 31: 
			if AudioManager: AudioManager.play_dynamic_typing()

func _on_command_submitted(command: String):
	if command.strip_edges().is_empty(): return
	
	if AudioManager: AudioManager.play_terminal_beep()
	
	if command_history.is_empty() or command_history.back() != command:
		command_history.append(command)
		
	history_index = command_history.size()
	command_input.text = ""
	
	_append_output("[color=gray]> " + command + "[/color]\n")
	
	if TerminalSystem:
		var result = await TerminalSystem.execute_command(command)
		
		# Metadata box is for one-shot summary data (status, list, etc.)
		if "status" in command.to_lower() or "list" in command.to_lower():
			_show_metadata(result.output)
	else:
		_append_output("[color=red]SYSTEM_ERROR: Module backend unreachable.[/color]\n")

func _show_metadata(text: String):
	metadata_box.visible = true
	metadata_label.text = text
	
	# Small animation
	metadata_box.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(metadata_box, "modulate:a", 1.0, 0.2)

func _append_output(text: String):
	output_text.append_text(text)
	_scroll_to_bottom()

func _scroll_to_bottom():
	var scroll_container = output_text.get_parent()
	if scroll_container is ScrollContainer:
		await get_tree().process_frame
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _input(event):
	if not visible: return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP and not command_history.is_empty():
			history_index = max(0, history_index - 1)
			command_input.text = command_history[history_index]
			command_input.caret_column = command_input.text.length()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN and not command_history.is_empty():
			history_index = min(command_history.size(), history_index + 1)
			if history_index == command_history.size():
				command_input.text = ""
			else:
				command_input.text = command_history[history_index]
				command_input.caret_column = command_input.text.length()
			get_viewport().set_input_as_handled()
