# App_Decryption.gd
extends Control

@onready var status_label: Label = %StatusLabel
@onready var timer_label: Label = %TimerLabel
@onready var timer_bar: ProgressBar = %TimerBar
@onready var timer_container: VBoxContainer = %TimerContainer
@onready var puzzle_container: Control = %PuzzleContainer
@onready var grid_container: GridContainer = %GridContainer
@onready var target_sequence_container: HBoxContainer = %TargetSequence
@onready var start_button: Button = %StartButton

# --- UI for Target Selection ---
@onready var selection_container = %SelectionContainer 
@onready var target_list = %TargetList 
# -------------------------------

var is_locked_down: bool = false
var puzzle_active: bool = false
var time_remaining: float = 60.0
var max_time: float = 60.0
var current_sequence: Array[String] = []
var player_progress: int = 0
var target_ticket_id: String = "" 

var hex_chars = ["A", "B", "C", "D", "E", "F", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

# Dynamic config
var grid_columns: int = 5
var grid_rows: int = 5
var sequence_length: int = 4
var time_penalty: float = 10.0

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
		if time_remaining <= 0:
			_fail_puzzle()

func _set_status(text: String, color: Color):
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)

func _update_ui_state():
	if is_locked_down:
		_set_status("CRITICAL ALERT: SERVER ENCRYPTION DETECTED", Color.RED)
		start_button.visible = (target_ticket_id == "" and not puzzle_active)
		selection_container.visible = false
		puzzle_container.visible = puzzle_active
		timer_container.visible = puzzle_active
	else:
		_set_status("ACCESS RESTRICTED: NO ENCRYPTION DETECTED", Color.GRAY)
		start_button.visible = false
		puzzle_container.visible = false
		timer_container.visible = false
		selection_container.visible = false
		puzzle_active = false
		target_ticket_id = ""

func _on_start_pressed():
	if AudioManager: AudioManager.play_ui_click()
	
	var ransomware_tickets = []
	if TicketManager:
		for ticket in TicketManager.get_active_tickets():
			if ticket.category == "Ransomware" or ticket.required_tool == "decrypt":
				ransomware_tickets.append(ticket)
	
	if ransomware_tickets.is_empty():
		_set_status("ERROR: NO ACTIVE TARGETS FOUND", Color.RED)
		return
		
	if ransomware_tickets.size() > 1:
		_show_target_selection(ransomware_tickets)
	else:
		_start_decryption(ransomware_tickets[0].ticket_id)

func _show_target_selection(tickets: Array):
	start_button.visible = false
	selection_container.visible = true
	for child in target_list.get_children(): child.queue_free()
	_set_status("SELECT DECRYPTION TARGET", Color.WHITE)
	
	for ticket in tickets:
		var btn = Button.new()
		btn.text = " TARGET: " + ticket.ticket_id + " [" + ticket.title + "]"
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size.y = 45
		btn.pressed.connect(func(): _start_decryption(ticket.ticket_id))
		target_list.add_child(btn)

func _start_decryption(ticket_id: String):
	target_ticket_id = ticket_id
	selection_container.visible = false
	puzzle_active = true
	
	if ArchetypeAnalyzer: ArchetypeAnalyzer.log_tool_used("decryption")
	
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
	_set_status("DECRYPTING: " + ticket_id, Color.WHITE)

func _generate_puzzle():
	for child in grid_container.get_children(): child.queue_free()
	for child in target_sequence_container.get_children(): child.queue_free()
	current_sequence.clear()
	player_progress = 0
	
	for i in range(sequence_length):
		var code = hex_chars.pick_random() + hex_chars.pick_random()
		current_sequence.append(code)
		var lbl = Label.new()
		lbl.text = code
		lbl.add_theme_font_size_override("font_size", 32)
		target_sequence_container.add_child(lbl)
	
	_update_target_display()
	var grid_items = []
	grid_items.append_array(current_sequence)
	for i in range((grid_columns * grid_rows) - current_sequence.size()):
		grid_items.append(hex_chars.pick_random() + hex_chars.pick_random())
	grid_items.shuffle()
	
	for code in grid_items:
		var btn = Button.new()
		btn.text = code
		btn.custom_minimum_size = Vector2(80, 80)
		btn.pressed.connect(_on_grid_button_pressed.bind(code, btn))
		grid_container.add_child(btn)

func _update_target_display():
	var targets = target_sequence_container.get_children()
	for i in range(targets.size()):
		if i < player_progress: targets[i].modulate = Color.GREEN
		elif i == player_progress: targets[i].modulate = Color.WHITE
		else: targets[i].modulate = Color(0.3, 0.3, 0.3)

func _on_grid_button_pressed(code: String, btn: Button):
	if not puzzle_active: return
	var target = current_sequence[player_progress]
	if code == target:
		if AudioManager: AudioManager.play_ui_click()
		btn.disabled = true
		btn.modulate = Color.GREEN
		player_progress += 1
		_update_target_display()
		if player_progress >= current_sequence.size(): _win_puzzle()
	else:
		if AudioManager: AudioManager.play_notification("error")
		time_remaining -= time_penalty

func _win_puzzle():
	puzzle_active = false
	_set_status("DECRYPTION SUCCESSFUL: " + target_ticket_id, Color.GREEN)
	timer_container.visible = false
	grid_container.visible = false
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	if TicketManager: TicketManager.complete_ticket(target_ticket_id, "compliant")
	target_ticket_id = ""

func _fail_puzzle():
	puzzle_active = false
	_set_status("DECRYPTION FAILED: " + target_ticket_id, Color.RED)
	grid_container.visible = false
	EventBus.consequence_triggered.emit("data_loss", {"ticket_id": target_ticket_id})
	target_ticket_id = ""
