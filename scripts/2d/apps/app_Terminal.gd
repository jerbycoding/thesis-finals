# app_Terminal.gd
extends Control

var command_history: Array[String] = []
var history_index: int = -1
var current_ticket_id: String = ""

@onready var output_text: RichTextLabel = %OutputText
@onready var command_input: LineEdit = %CommandInput
@onready var prompt_label: Label = %PromptLabel
@onready var ticket_info: Label = %TicketInfo
@onready var lockout_overlay: ColorRect = %LockoutOverlay
@onready var lock_timer_label: Label = %LockTimerLabel

var lock_remaining_time: float = 0.0

# --- Typewriter / Queue Logic ---
var _output_queue: Array[String] = []
var _is_typing: bool = false
var _typewriter_speed: float = 0.015 # Seconds per character
var _current_tween: Tween

func _process(delta):
	if lockout_overlay and lockout_overlay.visible:
		lock_remaining_time -= delta
		if lock_remaining_time <= 0:
			lock_remaining_time = 0
		
		if lock_timer_label:
			lock_timer_label.text = "Time Remaining: %ds" % int(lock_remaining_time)

func _ready():
	print("======= App_Terminal._ready() =======")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Initial UI state
	if output_text:
		output_text.visible_characters = -1 # Start with everything visible
	
	# Force visibility
	visible = true
	modulate = Color.WHITE
	
	# Wait a frame for the scene tree to be fully set up
	await get_tree().process_frame
	
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
	
	# Connect to EventBus
	EventBus.terminal_command_executed.connect(_on_command_executed)
	EventBus.terminal_locked.connect(_on_terminal_locked)
	EventBus.terminal_unlocked.connect(_on_terminal_unlocked)
	EventBus.ticket_added.connect(_on_ticket_added)
	EventBus.ticket_completed.connect(_on_ticket_completed)
	print("DEBUG: Connected to EventBus")
	
	# Set initial output
	_append_output(CorporateVoice.get_phrase("terminal_welcome"))
	
	# Focus input
	if command_input:
		command_input.grab_focus()
		print("DEBUG: Command input focused")
	
	print("======= App_Terminal Ready Complete =======")

func _on_command_submitted(command: String):
	if _is_typing:
		_skip_typing()
		return

	if command.strip_edges().is_empty():
		return
	
	if AudioManager:
		AudioManager.play_terminal_beep()
	
	# Add to history
	command_history.append(command)
	history_index = command_history.size()
	
	# Clear input
	command_input.text = ""
	
	# Show command in output
	_append_output(CorporateVoice.get_formatted_phrase("terminal_command_echo", {"command": command}))
	
	# Execute command
	if TerminalSystem:
		var result = await TerminalSystem.execute_command(command)
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

func _on_command_executed(_command: String, _success: bool, _output: String):
	pass

func _on_terminal_locked(seconds: float):
	_append_output("[color=red]🔒 TERMINAL LOCKED for " + str(int(seconds)) + " seconds[/color]\n")
	command_input.editable = false
	command_input.placeholder_text = "Terminal locked..."
	
	if lockout_overlay:
		lockout_overlay.visible = true
		lock_remaining_time = seconds

func _on_terminal_unlocked():
	_append_output("[color=green]🔓 Terminal unlocked[/color]\n")
	command_input.editable = true
	command_input.placeholder_text = "Enter command..."
	
	if lockout_overlay:
		lockout_overlay.visible = false

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
	_output_queue.append(text)
	if not _is_typing:
		_process_queue()

func _process_queue():
	if _output_queue.is_empty():
		_is_typing = false
		return
		
	_is_typing = true
	var text = _output_queue.pop_front()
	
	if output_text:
		# Get current character count before adding new text
		var start_chars = output_text.get_total_character_count()
		output_text.append_text(text)
		
		# Total characters after append
		var total_chars = output_text.get_total_character_count()
		var new_chars_count = total_chars - start_chars
		
		# Animate visible_characters
		if _current_tween: _current_tween.kill()
		_current_tween = create_tween()
		
		# We set visible_characters to the total count minus new ones, then tween up
		output_text.visible_characters = start_chars
		
		var duration = new_chars_count * _typewriter_speed
		_current_tween.tween_property(output_text, "visible_characters", total_chars, duration)
		
		# Audio Tick logic
		var audio_ticks = maxi(1, int(new_chars_count / 3)) # Tick every 3 chars to avoid audio spam
		for i in range(audio_ticks):
			_current_tween.parallel().tween_callback(func(): 
				if AudioManager: AudioManager.play_terminal_beep(-20.0) # Very quiet beep as tick
			).set_delay(i * _typewriter_speed * 3)
		
		# Sync scroll
		_current_tween.parallel().tween_callback(_scroll_to_bottom).set_delay(0.05)
		
		_current_tween.finished.connect(func(): _process_queue())
	else:
		print("ERROR: output_text is null, cannot append: ", text)
		_is_typing = false

func _skip_typing():
	if _current_tween:
		_current_tween.kill()
	if output_text:
		output_text.visible_characters = -1
	
	# Process remaining queue instantly
	while not _output_queue.is_empty():
		output_text.append_text(_output_queue.pop_front())
		
	_scroll_to_bottom()
	_is_typing = false

func _scroll_to_bottom():
	if not output_text: return
	var scroll_container = output_text.get_parent()
	if scroll_container is ScrollContainer:
		await get_tree().process_frame # Wait for layout update
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func set_active_ticket(ticket_id: String):
	current_ticket_id = ticket_id
	_update_ticket_info()
	_append_output("[color=yellow]Active ticket set to: " + ticket_id + "[/color]\n")
