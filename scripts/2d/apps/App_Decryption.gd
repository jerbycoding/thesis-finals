extends Control

@onready var status_label: Label = %StatusLabel
@onready var timer_label: Label = %TimerLabel
@onready var puzzle_container: Control = %PuzzleContainer
@onready var grid_container: GridContainer = %GridContainer
@onready var target_sequence_container: HBoxContainer = %TargetSequence
@onready var start_button: Button = %StartButton

var is_locked_down: bool = false
var puzzle_active: bool = false
var time_remaining: float = 60.0
var current_sequence: Array[String] = []
var player_progress: int = 0

var hex_chars = ["A", "B", "C", "D", "E", "F", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

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
		
		if time_remaining <= 0:
			_fail_puzzle()

func _update_ui_state():
	if is_locked_down:
		status_label.text = "CRITICAL ALERT: SERVER ENCRYPTION DETECTED"
		status_label.add_theme_color_override("font_color", Color.RED)
		start_button.visible = !puzzle_active
		puzzle_container.visible = puzzle_active
		timer_label.visible = puzzle_active
	else:
		status_label.text = "STATUS: SYSTEM SECURE"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		start_button.visible = false
		puzzle_container.visible = false
		timer_label.visible = false
		puzzle_active = false

func _on_start_pressed():
	if ArchetypeAnalyzer:
		ArchetypeAnalyzer.log_tool_used("decryption")
	puzzle_active = true
	time_remaining = 60.0
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
	
	# Generate Target Sequence (4 codes)
	for i in range(4):
		var code = hex_chars.pick_random() + hex_chars.pick_random()
		current_sequence.append(code)
		
		# Create Target Display
		var lbl = Label.new()
		lbl.text = code
		lbl.add_theme_font_size_override("font_size", 24)
		lbl.add_theme_color_override("font_color", Color.GRAY) # Start gray
		target_sequence_container.add_child(lbl)
	
	# Highlight first target
	_update_target_display()
	
	# Generate Grid (5x5 = 25 items)
	# Must include the 4 targets, plus 21 randoms
	var grid_items = []
	grid_items.append_array(current_sequence)
	for i in range(21):
		grid_items.append(hex_chars.pick_random() + hex_chars.pick_random())
	
	grid_items.shuffle()
	
	for code in grid_items:
		var btn = Button.new()
		btn.text = code
		btn.custom_minimum_size = Vector2(60, 60)
		btn.pressed.connect(_on_grid_button_pressed.bind(code, btn))
		grid_container.add_child(btn)

func _update_target_display():
	var targets = target_sequence_container.get_children()
	for i in range(targets.size()):
		if i < player_progress:
			targets[i].add_theme_color_override("font_color", Color.GREEN) # Completed
		elif i == player_progress:
			targets[i].add_theme_color_override("font_color", Color.WHITE) # Current
		else:
			targets[i].add_theme_color_override("font_color", Color.GRAY) # Future

func _on_grid_button_pressed(code: String, btn: Button):
	if not puzzle_active: return
	
	var target = current_sequence[player_progress]
	
	if code == target:
		# Correct!
		if AudioManager: AudioManager.play_sfx(AudioManager.SFX.button_click)
		btn.disabled = true
		btn.modulate = Color.GREEN
		player_progress += 1
		_update_target_display()
		
		if player_progress >= current_sequence.size():
			_win_puzzle()
	else:
		# Wrong!
		if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_error)
		btn.modulate = Color.RED
		time_remaining -= 5.0 # Penalty
		
		# Flash screen red?
		var flash = ColorRect.new()
		flash.color = Color(1, 0, 0, 0.3)
		flash.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(flash)
		var tween = create_tween()
		tween.tween_property(flash, "modulate:a", 0.0, 0.2)
		tween.tween_callback(flash.queue_free)

func _win_puzzle():
	puzzle_active = false
	status_label.text = "DECRYPTION SUCCESSFUL"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	timer_label.visible = false
	grid_container.visible = false
	
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	
	# Clear world event
	if NarrativeDirector:
		# We assume there's a signal or we call a method. 
		# Since NarrativeDirector logic isn't fully exposed to clear events manually, 
		# we'll emit a special signal or just trust the TicketManager handles it?
		# Actually, we should probably complete the ticket.
		pass
		
	if TicketManager:
		# Find RANSOM-001 and complete it
		TicketManager.complete_ticket("RANSOM-001", "compliant")

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
