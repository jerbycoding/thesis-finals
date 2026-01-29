# CalibrationMinigame.gd
extends Control

signal minigame_success
signal minigame_failed
signal minigame_closed

@onready var needle = %Needle
@onready var zone = %TargetZone
@onready var bar = %BarBackground
@onready var label = %Label
@onready var typing_area = %TypingArea
@onready var code_display = %CodeDisplay
@onready var player_input_label = %PlayerInput
@onready var handshake_timer_bar = %HandshakeTimer
@onready var game_area = %GameArea
@onready var tech_table = %TechnicalTable

enum GamePhase { SIGNAL_LOCK, HANDSHAKE }
var current_phase = GamePhase.SIGNAL_LOCK

@export var config: CalibrationMinigameConfig

var difficulty_speed: float
var direction: int = 1
var is_active: bool = false
var input_locked: bool = false # Debounce flag

# Typing logic
var target_code: String = ""
var current_input: String = ""
var handshake_time_left: float
var max_handshake_time: float

func _ready():
	visible = false
	set_process(false)
	if not config:
		push_error("CalibrationMinigame: No config resource assigned!")
		return

var is_sunday: bool = false
var sunday_heat: float = 100.0 # Starts hot

func start_game(difficulty_modifier: float = 1.0):
	if not config:
		push_error("CalibrationMinigame: Cannot start game, config resource is missing.")
		minigame_failed.emit()
		_close_game()
		return

	# Detect shift type from resource
	if NarrativeDirector and NarrativeDirector.current_shift_resource:
		is_sunday = NarrativeDirector.current_shift_resource.minigame_type == "RECOVERY"
	else:
		is_sunday = false
	
	# Reset state
	is_active = true
	input_locked = false
	visible = true
	set_process(true)
	current_phase = GamePhase.SIGNAL_LOCK
	
	if game_area: game_area.visible = true
	if typing_area: typing_area.visible = false
	
	current_input = ""
	
	# Initialize from config
	max_handshake_time = config.max_handshake_time
	handshake_time_left = max_handshake_time
	
	if is_sunday:
		_setup_sunday_game()
	else:
		_setup_saturday_game(difficulty_modifier)
	
	# POPULATE ASSET TABLE
	if tech_table and VariableRegistry:
		var target_id = "ROUTER_ALPHA"
		if GameState and GameState.current_computer:
			target_id = GameState.current_computer.name.to_upper()
		var identity = VariableRegistry.generate_asset_identity(target_id)
		tech_table.set_identity(identity)
	
	if GameState: GameState.set_mode(GameState.GameMode.MODE_MINIGAME)

func _setup_saturday_game(difficulty_modifier):
	# Randomize zone size and position using config values
	var zone_width_ratio = randf_range(config.zone_min_size, config.zone_max_size)
	zone.size.x = bar.size.x * zone_width_ratio
	zone.position.x = randf_range(0, bar.size.x - zone.size.x)
	
	needle.position.x = randf_range(0, bar.size.x - needle.size.x)
	difficulty_speed = config.difficulty_speed * difficulty_modifier
	label.text = "PHASE 1: LOCK LOCAL SIGNAL [SPACE]"
	label.add_theme_color_override("font_color", Color.WHITE)

func _setup_sunday_game():
	sunday_heat = 100.0 # Start at max (far right)
	zone.position.x = 20.0 # Target is cool (far left)
	needle.position.x = bar.size.x - needle.size.x
	label.text = "PHASE 1: COOLING SYSTEM [TAP SPACE]"
	label.add_theme_color_override("font_color", Color.WHITE)

func _process(delta):
	if not is_active: return
	
	if current_phase == GamePhase.SIGNAL_LOCK:
		if is_sunday:
			_process_thermal_reset(delta)
		else:
			_process_signal_lock(delta)
	elif current_phase == GamePhase.HANDSHAKE:
		_process_handshake(delta)

func _process_signal_lock(delta):
	needle.position.x += difficulty_speed * direction * delta
	var max_pos = bar.size.x - needle.size.x
	if needle.position.x >= max_pos or needle.position.x <= 0:
		direction *= -1
		needle.position.x = clamp(needle.position.x, 0, max_pos)

func _process_handshake(delta):
	handshake_time_left -= delta
	handshake_timer_bar.value = (handshake_time_left / max_handshake_time) * 100.0
	
	if handshake_time_left <= 0:
		_fail("HANDSHAKE TIMEOUT")

func _process_thermal_reset(delta):
	# Heat naturally rises (moves right)
	sunday_heat = min(100.0, sunday_heat + (delta * 25.0))
	
	# Update needle pos based on heat %
	var max_x = bar.size.x - needle.size.x
	needle.position.x = (sunday_heat / 100.0) * max_x
	
	# Visual feedback: Red when hot, Yellow when cooling
	needle.color = Color.RED if sunday_heat > 50 else Color.YELLOW
	
	# Win condition: If in zone
	var z_left = zone.position.x
	var z_right = zone.position.x + zone.size.x
	if needle.position.x >= z_left and needle.position.x + needle.size.x <= z_right:
		_on_lock_success()

func _input(event):
	if not is_active or input_locked: return
	
	if event.is_action_pressed("ui_cancel"):
		_close_game()
		return
	
	if current_phase == GamePhase.SIGNAL_LOCK:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
			if is_sunday:
				# Tapping lowers heat
				sunday_heat = max(0.0, sunday_heat - 8.0)
			else:
				input_locked = true # Prevent double-firing
				_try_lock()
	elif current_phase == GamePhase.HANDSHAKE:
		if event is InputEventKey and event.pressed:
			_handle_typing(event)


func _try_lock():
	# Check if any part of needle is in zone
	var n_left = needle.position.x
	var n_right = needle.position.x + needle.size.x
	var z_left = zone.position.x
	var z_right = zone.position.x + zone.size.x
	
	if n_right >= z_left and n_left <= z_right:
		_on_lock_success()
	else:
		_fail("SIGNAL MISMATCH")

func _on_lock_success():
	is_active = false
	label.text = "SIGNAL_STABILIZED"
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.button_click)
	
	await get_tree().create_timer(0.5).timeout
	
	if is_instance_valid(self):
		input_locked = false # Release input for typing
		is_active = true
		_start_handshake_phase()

func _start_handshake_phase():
	current_phase = GamePhase.HANDSHAKE
	label.text = "PHASE 2: PROTOCOL_HANDSHAKE"
	
	randomize() # Force fresh randomness
	target_code = _generate_procedural_code()
	_update_input_display()
	
	typing_area.visible = true
	handshake_time_left = config.max_handshake_time # Use max_handshake_time from config
	if AudioManager: AudioManager.play_terminal_beep()

func _generate_procedural_code() -> String:
	# Technical prefixes (All Uppercase)
	var prefixes = ["AUTH", "SYNC", "GATE", "NODE", "LINK", "RECV", "HASH", "XFER"]
	var mid = ["ROUTER", "SRV", "INFRA", "CORE", "GW", "BACKPLANE"]
	
	var p = prefixes.pick_random()
	var m = mid.pick_random()
	# Random 4-digit Hex (Uppercase)
	var hex = "%04X" % (randi() % 0xFFFF)
	
	# Patterns using only uppercase
	var patterns = [
		"%s-%s-%s" % [p, m, hex],
		"%s_%s_%s" % [p, m, hex], # Removed 0x lowercase
		"%s-PROTOCOL-%s" % [p, hex],
		"%s-NODE-%s" % [hex, m]
	]
	
	return patterns.pick_random().to_upper()

func _handle_typing(event: InputEventKey):
	if event.keycode == KEY_BACKSPACE:
		current_input = current_input.left(current_input.length() - 1)
		_update_input_display()
		return

	var character = char(event.unicode).to_upper()
	if character.length() > 0 and character.unicode_at(0) > 31:
		# CHECK: Is this the NEXT correct character in the sequence?
		var next_char_needed = target_code[current_input.length()]
		
		if character == next_char_needed:
			current_input += character
			_update_input_display()
			if AudioManager: AudioManager.play_terminal_beep()
			
			if current_input == target_code:
				_success()
		else:
			# Block incorrect character - No penalty, just visual/audio feedback
			if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_error)
			# Optional: shake the screen or flash red

func _update_input_display():
	# Update the main code display with color-coded progress
	var typed = current_input
	var remaining = target_code.right(target_code.length() - typed.length())
	
	code_display.text = "[center][color=#2E7D32]%s[/color][color=#666666]%s[/color][/center]" % [typed, remaining]
	
	# Update the small player input label for additional clarity
	player_input_label.text = "> " + current_input + "_"

func _success():
	is_active = false
	label.text = "CALIBRATION COMPLETE"
	label.add_theme_color_override("font_color", Color.GREEN)
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	
	await get_tree().create_timer(0.8).timeout
	minigame_success.emit()
	_close_game()

func _fail(reason: String):
	is_active = false
	label.text = reason + " [ESC to ABORT]"
	label.add_theme_color_override("font_color", Color.RED)
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_error)
	
	# Give the player 2 seconds to decide to press ESC to quit, 
	# otherwise it will auto-restart the game.
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(self) and not is_queued_for_deletion():
		# If they haven't ESC'd yet, restart
		start_game(1.0) 

func _close_game():
	is_active = false
	visible = false
	if GameState: GameState.set_mode(GameState.GameMode.MODE_3D)
	minigame_closed.emit()
	queue_free()
