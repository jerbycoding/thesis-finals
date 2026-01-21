extends Control

@onready var status_label: Label = %StatusLabel
@onready var timer_label: Label = %TimerLabel
@onready var timer_bar: ProgressBar = %TimerBar
@onready var timer_container: VBoxContainer = %TimerContainer
@onready var puzzle_container: Control = %PuzzleContainer
@onready var grid_container: GridContainer = %GridContainer
@onready var target_sequence_container: HBoxContainer = %TargetSequence
@onready var start_button: Button = %StartButton

var is_locked_down: bool = false
var puzzle_active: bool = false
var time_remaining: float = 60.0
var max_time: float = 60.0
var current_sequence: Array[String] = []
var player_progress: int = 0

var hex_chars = ["A", "B", "C", "D", "E", "F", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

# --- Dynamic Difficulty Configuration ---
var grid_columns: int = 5
var grid_rows: int = 5
var sequence_length: int = 4
var time_penalty: float = 10.0
# ----------------------------------------

func _ready():
	visible = true
	modulate = Color.WHITE
	
	start_button.pressed.connect(_on_start_pressed)
	EventBus.world_event_triggered.connect(_on_world_event)
	
	_update_ui_state()

func _on_world_event(event_id: String, active: bool, _duration: float):
	if event_id == "SERVER_LOCKDOWN":
		is_locked_down = active
		_update_ui_state()

func _process(delta):
	if puzzle_active and time_remaining > 0:
		time_remaining -= delta
		timer_label.text = "DATA WIPE IN: %.1fs" % time_remaining
		
		if timer_bar:
			timer_bar.value = (time_remaining / max_time) * 100.0
			# Pulse bar red when low
			if time_remaining < 15:
				timer_bar.modulate.a = 0.5 + (sin(Time.get_ticks_msec() * 0.01) * 0.5)
		
		if time_remaining <= 0:
			_fail_puzzle()

func _set_status(text: String, color: Color):
	status_label.text = ""
	status_label.add_theme_color_override("font_color", color)
	
	# Typewriter effect for status
	var tween = create_tween()
	tween.tween_method(func(v): status_label.text = text.substr(0, v), 0, text.length(), 0.5)

func _update_ui_state():
	if is_locked_down:
		_set_status("CRITICAL ALERT: SERVER ENCRYPTION DETECTED", Color.RED)
		start_button.visible = !puzzle_active
		puzzle_container.visible = puzzle_active
		timer_container.visible = puzzle_active
	else:
		_set_status("ACCESS RESTRICTED: NO ENCRYPTION DETECTED", Color.GRAY)
		start_button.visible = false
		puzzle_container.visible = false
		timer_container.visible = false
		puzzle_active = false

func _on_start_pressed():
	if AudioManager: AudioManager.play_ui_click()
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("decryption")
	
	puzzle_active = true
	
	# DIFFICULTY SCALING: Increase difficulty if Heat is high
	if HeatManager:
		var multiplier = HeatManager.heat_multiplier
		time_remaining = max(30.0, 60.0 / multiplier)
		sequence_length = 4 + int(multiplier - 1)
		time_penalty = 5.0 * multiplier
	else:
		time_remaining = 60.0
		sequence_length = 4
		time_penalty = 10.0
		
	max_time = time_remaining
	_generate_puzzle()
	_update_ui_state()

func _generate_puzzle():
	# Clear old
	for child in grid_container.get_children():
		child.queue_free()
	for child in target_sequence_container.get_children():
		child.queue_free()
	
	current_sequence.clear()
	player_progress = 0
	
	# Update grid settings
	grid_container.columns = grid_columns
	
	# Generate Target Sequence
	for i in range(sequence_length):
		var code = hex_chars.pick_random() + hex_chars.pick_random()
		current_sequence.append(code)
		
		var lbl = Label.new()
		lbl.text = code
		lbl.add_theme_font_size_override("font_size", 32)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		target_sequence_container.add_child(lbl)
	
	_update_target_display()
	
	# Generate Grid
	var total_items = grid_columns * grid_rows
	var grid_items = []
	grid_items.append_array(current_sequence)
	
	# Fill remaining with noise
	for i in range(total_items - current_sequence.size()):
		grid_items.append(hex_chars.pick_random() + hex_chars.pick_random())
	grid_items.shuffle()
	
	for code in grid_items:
		var btn = Button.new()
		btn.text = code
		btn.custom_minimum_size = Vector2(80, 80)
		btn.mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())
		btn.pressed.connect(_on_grid_button_pressed.bind(code, btn))
		grid_container.add_child(btn)

func _update_target_display():
	var targets = target_sequence_container.get_children()
	for i in range(targets.size()):
		var tween = create_tween()
		if i < player_progress:
			targets[i].modulate = Color.GREEN
			targets[i].scale = Vector2.ONE
		elif i == player_progress:
			targets[i].modulate = Color.WHITE
			# Pulse the current target
			tween.set_loops().tween_property(targets[i], "scale", Vector2(1.2, 1.2), 0.5)
			tween.tween_property(targets[i], "scale", Vector2.ONE, 0.5)
		else:
			targets[i].modulate = Color(0.3, 0.3, 0.3)
			targets[i].scale = Vector2.ONE

func _on_grid_button_pressed(code: String, btn: Button):
	if not puzzle_active: return
	
	var target = current_sequence[player_progress]
	
	if code == target:
		if AudioManager: AudioManager.play_ui_click()
		btn.disabled = true
		btn.modulate = Color.GREEN
		
		# Success particle effect (visual only)
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(btn, "scale", Vector2.ONE, 0.1)
		
		player_progress += 1
		_update_target_display()
		
		if player_progress >= current_sequence.size():
			_win_puzzle()
	else:
		_trigger_error_shake()
		if AudioManager: AudioManager.play_notification("error")
		btn.modulate = Color.RED
		time_remaining -= time_penalty # Use dynamic penalty

func _trigger_error_shake():
	var original_pos = position
	var tween = create_tween()
	for i in range(4):
		var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		tween.tween_property(self, "position", original_pos + offset, 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)
	
	# Red flash
	var flash = ColorRect.new()
	flash.color = Color(1, 0, 0, 0.2)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	create_tween().tween_property(flash, "modulate:a", 0.0, 0.3).finished.connect(flash.queue_free)

func _win_puzzle():
	puzzle_active = false
	status_label.text = "DECRYPTION SUCCESSFUL"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	timer_container.visible = false
	grid_container.visible = false
	
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	
	if TicketManager:
		# Dynamic Search: Find any active Ransomware ticket and complete it
		var resolved = false
		for ticket in TicketManager.get_active_tickets():
			if ticket.category == "Ransomware" or ticket.required_tool == "decrypt":
				TicketManager.complete_ticket(ticket.ticket_id, "compliant")
				resolved = true
				break
		
		# Fallback if no specific ticket found (e.g. manual override test)
		if not resolved:
			print("Decryption: No active ransomware ticket found to close.")

func _fail_puzzle():
	puzzle_active = false
	status_label.text = "DECRYPTION FAILED - DATA LOST"
	grid_container.visible = false
	
	# Trigger a major consequence for losing the data
	if ConsequenceEngine:
		ConsequenceEngine.update_npc_relationship("ciso", -0.5) # Massive trust hit
		
	EventBus.consequence_triggered.emit("data_loss", {"reason": "Decryption failure on critical server"})
	if NotificationManager:
		NotificationManager.show_notification("CRITICAL: Data Recovery Failed - Assets Lost", "error", 5.0)
