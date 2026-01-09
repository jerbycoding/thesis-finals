# app_Terminal.gd
extends Control

var command_history: Array[String] = []
var history_index: int = -1
var current_ticket_id: String = ""

@onready var output_text: RichTextLabel = $ColorRect/VBoxContainer/OutputContainer/OutputText
@onready var command_input: LineEdit = $ColorRect/VBoxContainer/InputContainer/CommandInput
@onready var prompt_label: Label = $ColorRect/VBoxContainer/InputContainer/PromptLabel
@onready var ticket_info: Label = $ColorRect/VBoxContainer/TicketInfo

func _ready():
	print("======= App_Terminal._ready() =======")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Force visibility
	visible = true
	modulate = Color.WHITE
	
	# Wait a frame for the scene tree to be fully set up
	await get_tree().process_frame
	
	# Get nodes manually (in case @onready didn't work)
	if not output_text:
		output_text = get_node_or_null("ColorRect/VBoxContainer/OutputContainer/OutputText")
	if not command_input:
		command_input = get_node_or_null("ColorRect/VBoxContainer/InputContainer/CommandInput")
	if not prompt_label:
		prompt_label = get_node_or_null("ColorRect/VBoxContainer/InputContainer/PromptLabel")
	if not ticket_info:
		ticket_info = get_node_or_null("ColorRect/VBoxContainer/TicketInfo")
	
	# Connect input
	if command_input:
		# Disconnect first if already connected to avoid duplicates
		if command_input.text_submitted.is_connected(_on_command_submitted):
			command_input.text_submitted.disconnect(_on_command_submitted)
		if command_input.gui_input.is_connected(_on_input_gui_input):
			command_input.gui_input.disconnect(_on_input_gui_input)
		
		command_input.text_submitted.connect(_on_command_submitted)
		command_input.gui_input.connect(_on_input_gui_input)
		print("DEBUG: Command input connected")
	else:
		print("ERROR: Command input not found!")
	
	# Connect to TerminalSystem
	if TerminalSystem:
		TerminalSystem.command_executed.connect(_on_command_executed)
		TerminalSystem.terminal_locked.connect(_on_terminal_locked)
		TerminalSystem.terminal_unlocked.connect(_on_terminal_unlocked)
		print("DEBUG: Connected to TerminalSystem")
	
	# Connect to TicketManager to track active ticket
	if TicketManager:
		TicketManager.ticket_added.connect(_on_ticket_added)
		TicketManager.ticket_completed.connect(_on_ticket_completed)
	
	# Set initial output
	_append_output("[color=green]SOC Terminal v2.1[/color]\n[color=green]Type 'help' for available commands[/color]\n\n")
	
	# Focus input
	if command_input:
		command_input.grab_focus()
		print("DEBUG: Command input focused")
	else:
		print("ERROR: Cannot focus command input - node not found!")
	
	print("======= App_Terminal Ready Complete =======")
	print("  - output_text: ", output_text != null)
	print("  - command_input: ", command_input != null)
	print("  - prompt_label: ", prompt_label != null)
	print("  - ticket_info: ", ticket_info != null)

func _on_command_submitted(command: String):
	if command.strip_edges().is_empty():
		return
	
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.terminal_beep)
	
	# Add to history
	command_history.append(command)
	history_index = command_history.size()
	
	# Clear input
	command_input.text = ""
	
	# Show command in output
	_append_output("[color=cyan]$ " + command + "[/color]\n")
	
	# Execute command
	if TerminalSystem:
		var result = TerminalSystem.execute_command(command)
		_append_output(result.output + "\n")
		
		# If command failed critically, lock terminal
		if not result.success and "lock" in result.output.to_lower():
			TerminalSystem.lock_terminal(60.0)
	else:
		_append_output("[color=red]Error: Terminal system unavailable[/color]\n")

func _on_input_gui_input(event: InputEvent):
	# Handle up/down arrows for command history
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			if command_history.size() > 0:
				history_index = max(0, history_index - 1)
				command_input.text = command_history[history_index]
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			if command_history.size() > 0:
				history_index = min(command_history.size() - 1, history_index + 1)
				if history_index >= command_history.size():
					command_input.text = ""
				else:
					command_input.text = command_history[history_index]
			get_viewport().set_input_as_handled()

func _on_command_executed(command: String, success: bool, output: String):
	if AudioManager:
		if success:
			AudioManager.play_sfx(AudioManager.SFX.notification_success) # Generic success for commands
		else:
			AudioManager.play_sfx(AudioManager.SFX.notification_error) # Generic error for commands
	pass

func _on_terminal_locked(seconds: float):
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_error)
	_append_output("[color=red]🔒 TERMINAL LOCKED for " + str(int(seconds)) + " seconds[/color]\n")
	command_input.editable = false
	command_input.placeholder_text = "Terminal locked..."

func _on_terminal_unlocked():
	if AudioManager:
		AudioManager.play_sfx(AudioManager.SFX.notification_info)
	_append_output("[color=green]🔓 Terminal unlocked[/color]\n")
	command_input.editable = true
	command_input.placeholder_text = "Enter command..."

func _on_ticket_added(ticket: TicketResource):
	# Auto-select first ticket if none selected
	if current_ticket_id.is_empty():
		current_ticket_id = ticket.ticket_id
		_update_ticket_info()

func _on_ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float):
	if current_ticket_id == ticket.ticket_id:
		current_ticket_id = ""
		_update_ticket_info()

func _update_ticket_info():
	if current_ticket_id.is_empty():
		ticket_info.visible = false
	else:
		ticket_info.visible = true
		var ticket = TicketManager.get_ticket_by_id(current_ticket_id) if TicketManager else null
		if ticket:
			ticket_info.text = "Active Ticket: " + ticket.ticket_id + " - " + ticket.title
		else:
			ticket_info.text = "Active Ticket: " + current_ticket_id

func _append_output(text: String):
	# Get output_text if not already set
	if not output_text:
		output_text = get_node_or_null("ColorRect/VBoxContainer/OutputContainer/OutputText")
	
	if output_text:
		output_text.append_text(text)
		# Auto-scroll to bottom
		await get_tree().process_frame
		var scroll_container = output_text.get_parent()
		if scroll_container is ScrollContainer:
			scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	else:
		print("ERROR: output_text is null, cannot append: ", text)

func set_active_ticket(ticket_id: String):
	current_ticket_id = ticket_id
	_update_ticket_info()
	_append_output("[color=yellow]Active ticket set to: " + ticket_id + "[/color]\n")
