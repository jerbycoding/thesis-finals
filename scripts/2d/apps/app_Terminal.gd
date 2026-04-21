# app_Terminal.gd
extends Control

var command_history: Array[String] = []
var history_index: int = -1

@onready var output_text: RichTextLabel = %OutputText
@onready var command_input: LineEdit = %CommandInput
@onready var prompt_label: Label = %PromptLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer

var is_glitch_active: bool = false
var current_prompt_text: String = "C:\\SOC\\Analyst> "

func _ready():
	_setup_role_identity()
	
	command_input.text_submitted.connect(_on_command_submitted)
	command_input.gui_input.connect(_on_command_gui_input)
	command_input.grab_focus()
	
	if TerminalSystem:
		TerminalSystem.command_output_received.connect(_on_terminal_output_received)
	
	EventBus.world_event_triggered.connect(_on_world_event)
	
	# Scroll to bottom on size change
	output_text.resized.connect(_scroll_to_bottom)

func _setup_role_identity():
	if not GameState: return
	
	if GameState.current_role == GameState.Role.HACKER:
		current_prompt_text = "root@remote-terminal:~# "
		prompt_label.text = current_prompt_text
		prompt_label.add_theme_color_override("font_color", Color(0, 1, 0, 1)) # Green
		command_input.add_theme_color_override("font_color", Color(0, 1, 0, 1))
		command_input.add_theme_color_override("caret_color", Color(0, 1, 0, 1))
		
		output_text.text = "[color=#00FF00]HackerOS v2.1 (Kernel 5.15.0-hacker)[/color]\n[color=#00FF00]Authorized access only. All actions are logged.[/color]\n\n"
	else:
		current_prompt_text = "C:\\SOC\\Analyst> "
		prompt_label.text = current_prompt_text
		prompt_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1)) # Light Gray
		command_input.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
		
		output_text.text = "Microsoft Windows [Version 10.0.19045.3803]\n(c) Microsoft Corporation. All rights reserved.\n\n"

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == GlobalConstants.EVENTS.ZERO_DAY or event_id == GlobalConstants.EVENTS.DDOS_ATTACK:
		is_glitch_active = active

func _on_terminal_output_received(text: String, _is_partial: bool):
	var processed_text = text
	if is_glitch_active and randf() < 0.2:
		var glitch_chars = "01#!@$%%^&*()_+"
		var text_chars = text.split("")
		for i in range(min(5, text.length())):
			var pos = randi() % text.length()
			if text[pos] != " " and text[pos] != "\n":
				text_chars[pos] = glitch_chars[randi() % glitch_chars.length()]
		processed_text = "".join(text_chars)
				
	_append_output(processed_text)

func _on_command_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.unicode > 31: 
			if AudioManager: AudioManager.play_dynamic_typing()
		
		# Tab Completion
		if event.keycode == KEY_TAB:
			_handle_tab_completion()
			get_viewport().set_input_as_handled()

func _handle_tab_completion():
	var input = command_input.text.strip_edges()
	if input.is_empty(): return
	
	var parts = input.split(" ")
	var to_complete = parts[-1].to_upper()
	
	if parts.size() > 1:
		# Complete hostnames
		var hostnames = NetworkState.get_all_hostnames()
		for host in hostnames:
			if host.to_upper().begins_with(to_complete):
				parts[-1] = host
				command_input.text = " ".join(parts) + " "
				command_input.caret_column = command_input.text.length()
				return
	else:
		# Complete commands
		if TerminalSystem:
			var current_role = GameState.current_role if GameState else 0
			for cmd in TerminalSystem.commands.keys():
				var cmd_def = TerminalSystem.commands[cmd]
				
				# Role Guard for tab completion
				if cmd_def.has("role") and cmd_def.role != 2:
					if cmd_def.role != current_role:
						continue
						
				if cmd.begins_with(input.to_lower()):
					command_input.text = cmd + " "
					command_input.caret_column = command_input.text.length()
					return

func _on_command_submitted(command: String):
	var cmd_trimmed = command.strip_edges()
	if cmd_trimmed.is_empty(): 
		_append_output("\n" + current_prompt_text + "\n")
		return
	
	if AudioManager: AudioManager.play_terminal_beep()
	
	if command_history.is_empty() or command_history.back() != cmd_trimmed:
		command_history.append(cmd_trimmed)
		
	history_index = command_history.size()
	command_input.text = ""
	
	# Log the command to history
	_append_output(current_prompt_text + cmd_trimmed + "\n")
	
	if TerminalSystem:
		await TerminalSystem.execute_command(cmd_trimmed)
		# NOTE: Output is handled by _on_terminal_output_received signal
	else:
		_append_output("[color=red]SYSTEM_ERROR: Module backend unreachable.[/color]\n")
	
	_scroll_to_bottom()

func _append_output(text: String):
	output_text.append_text(text)
	# Trigger scroll on next frame to account for size updates
	_scroll_to_bottom.call_deferred()

func _scroll_to_bottom():
	if scroll_container:
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
