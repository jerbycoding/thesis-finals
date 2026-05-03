# RansomCalibration.gd
# Phase 4 Polish: Industrial "Industrial Chaos" UI/UX for ransomware deployment.
extends Control

signal minigame_success
signal minigame_failed

@onready var background = %Background
@onready var bar_background = %BarBackground
@onready var target_zone = %TargetZone
@onready var needle = %Needle
@onready var hits_label = %HitsLabel
@onready var start_button = %StartButton
@onready var hit_button = %HitButton
@onready var fail_button = %FailButton
@onready var hex_progress = %HexProgress
@onready var stability_bar = %StabilityBar

const REQUIRED_HITS = 3

var needle_pos: float = 0.0
var needle_speed: float = 1.2
var direction: int = 1
var hits: int = 0
var is_active: bool = false
var input_locked: bool = false
var _shake_strength: float = 0.0

func _ready():
	visible = false
	set_process(false)
	start_button.pressed.connect(_on_start_pressed)
	hit_button.pressed.connect(_on_hit_pressed)
	if fail_button:
		fail_button.pressed.connect(_on_fail_pressed)

	_hide_game()

func _hide_game():
	start_button.visible = true
	hit_button.visible = false
	hit_button.disabled = true
	bar_background.modulate.a = 0.1
	target_zone.visible = false
	needle.visible = false
	stability_bar.value = 0
	if fail_button:
		fail_button.visible = false

func _show_game():
	start_button.visible = false
	hit_button.visible = true
	hit_button.disabled = false
	bar_background.modulate.a = 1.0
	target_zone.visible = true
	needle.visible = true
	if fail_button:
		fail_button.visible = true
		
	# Reset hex colors
	for hex in hex_progress.get_children():
		hex.modulate = Color(0.3, 0.3, 0.3, 1)

func _on_start_pressed():
	# Reset state
	hits = 0
	needle_pos = 0.0
	direction = 1
	is_active = true
	input_locked = false
	needle_speed = 1.2
	
	if AudioManager: AudioManager.play_terminal_beep()

	_randomize_zone()
	_show_game()
	_update_feedback("SYNC_INITIALIZED... AWAITING_LOCK")

	set_process(true)

func _randomize_zone():
	# Randomize zone position (15-70% of bar width)
	var zone_left = randf_range(0.1, 0.6)
	var zone_width = randf_range(0.15, 0.25)
	
	target_zone.anchor_left = zone_left
	target_zone.anchor_right = zone_left + zone_width
	target_zone.offset_left = 0
	target_zone.offset_right = 0

func _process(delta):
	if not is_active:
		return

	# Move needle with slight jitter for mechanical feel
	var jitter = (randf() - 0.5) * 0.02
	needle_pos += (needle_speed + jitter) * direction * delta
	
	if needle_pos > 1.0:
		needle_pos = 1.0
		direction = -1
	elif needle_pos < 0.0:
		needle_pos = 0.0
		direction = 1

	# Update needle visual
	needle.anchor_left = needle_pos
	needle.anchor_right = needle_pos
	needle.offset_left = -2
	needle.offset_right = 2
	
	# Update stability bar (simulated sync)
	stability_bar.value = lerp(stability_bar.value, float(hits) / REQUIRED_HITS * 100.0, 0.1)
	
	# Screen Shake handling
	if _shake_strength > 0:
		position = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))
		_shake_strength = lerp(_shake_strength, 0.0, 0.15)
	else:
		position = Vector2.ZERO

func _on_hit_pressed():
	if input_locked or not is_active:
		return

	input_locked = true
	
	# Check if needle is in target zone
	var in_zone = needle_pos >= target_zone.anchor_left and needle_pos <= target_zone.anchor_right

	if in_zone:
		_handle_hit_success()
	else:
		_handle_hit_fail()
		
	await get_tree().create_timer(0.2).timeout
	input_locked = false

func _handle_hit_success():
	hits += 1
	_shake_strength = 5.0
	
	if AudioManager: AudioManager.play_ui_click() # Sharp click
	
	# Flash background
	var tween = create_tween()
	tween.tween_property(background, "color", Color(0, 0.2, 0, 1), 0.05)
	tween.tween_property(background, "color", Color(0.02, 0, 0, 1), 0.2)
	
	# Update Hex indicators
	if hits <= REQUIRED_HITS:
		var hex = hex_progress.get_child(hits - 1)
		var h_tween = create_tween()
		h_tween.tween_property(hex, "modulate", Color(1, 0, 0, 1), 0.1)
		h_tween.parallel().tween_property(hex, "scale", Vector2(1.2, 1.2), 0.1)
		h_tween.tween_property(hex, "scale", Vector2.ONE, 0.1)
	
	if hits >= REQUIRED_HITS:
		_on_win()
	else:
		_update_feedback("SYNC_LOCK_%d_CONFIRMED" % hits)
		needle_speed += 0.4 # Speed escalation
		_randomize_zone()

func _handle_hit_fail():
	_shake_strength = 12.0
	if AudioManager: AudioManager.play_notification("error")
	
	# Flash background RED
	var tween = create_tween()
	tween.tween_property(background, "color", Color(0.5, 0, 0, 1), 0.05)
	tween.tween_property(background, "color", Color(0.02, 0, 0, 1), 0.3)
	
	_update_feedback("SYNC_ERROR: TEMPORAL_DRIFT_DETECTED")
	
	# Small penalty: slow down slightly to recover
	needle_speed = max(1.2, needle_speed - 0.2)

func _on_fail_pressed():
	_on_lose()

func _update_feedback(text: String):
	hits_label.text = text
	hits_label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(hits_label, "modulate:a", 1.0, 0.1)

func _on_win():
	is_active = false
	set_process(false)
	_update_feedback("CRITICAL_SYNCHRONIZATION_COMPLETE")
	hits_label.add_theme_color_override("font_color", Color.GREEN)
	hit_button.disabled = true
	
	if AudioManager: AudioManager.play_notification("success")

	await get_tree().create_timer(0.8).timeout
	minigame_success.emit()

func _on_lose():
	is_active = false
	set_process(false)
	_update_feedback("CALIBRATION_ABORTED: PAYLOAD_PURGED")
	hits_label.add_theme_color_override("font_color", Color.RED)
	hit_button.disabled = true

	await get_tree().create_timer(0.8).timeout
	minigame_failed.emit()
