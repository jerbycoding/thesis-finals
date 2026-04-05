# RansomCalibration.gd
# Phase 4: Simple self-contained calibration minigame for ransomware
# No external config resources needed — hit the green zone 3 times
extends Control

signal minigame_success
signal minigame_failed

@onready var bar_background = %BarBackground
@onready var target_zone = %TargetZone
@onready var needle = %Needle
@onready var hits_label = %HitsLabel
@onready var start_button = %StartButton
@onready var hit_button = %HitButton
@onready var fail_button = %FailButton

const REQUIRED_HITS = 3

var needle_pos: float = 0.0
var needle_speed: float = 1.0
var direction: int = 1
var hits: int = 0
var is_active: bool = false
var input_locked: bool = false

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
	bar_background.visible = false
	target_zone.visible = false
	needle.visible = false
	hits_label.visible = false
	if fail_button:
		fail_button.visible = false

func _show_game():
	start_button.visible = false
	hit_button.visible = true
	hit_button.disabled = false
	bar_background.visible = true
	target_zone.visible = true
	needle.visible = true
	hits_label.visible = true
	if fail_button:
		fail_button.visible = true

func _on_start_pressed():
	# Reset state
	hits = 0
	needle_pos = 0.0
	direction = 1
	is_active = true
	input_locked = false

	# Randomize zone position (15-85% of bar width)
	var zone_left = randf_range(0.15, 0.5)
	var zone_width = randf_range(0.15, 0.3)
	target_zone.position.x = zone_left * bar_background.size.x
	target_zone.size.x = zone_width * bar_background.size.x

	_show_game()
	_update_hits_label()

	set_process(true)

func _process(delta):
	if not is_active:
		return

	# Move needle
	needle_pos += needle_speed * direction * delta
	if needle_pos > 1.0:
		needle_pos = 1.0
		direction = -1
	elif needle_pos < 0.0:
		needle_pos = 0.0
		direction = 1

	# Update needle visual
	var bar_width = bar_background.size.x
	needle.position.x = needle_pos * bar_width

func _on_hit_pressed():
	if input_locked or not is_active:
		return

	input_locked = true
	await get_tree().create_timer(0.15).timeout
	input_locked = false

	# Check if needle is in target zone
	var bar_width = bar_background.size.x
	var needle_x = needle_pos * bar_width
	var zone_left = target_zone.position.x
	var zone_right = target_zone.position.x + target_zone.size.x

	if needle_x >= zone_left and needle_x <= zone_right:
		hits += 1
		_update_hits_label()

		# Flash green
		needle.material = null
		await get_tree().create_timer(0.2).timeout

		if hits >= REQUIRED_HITS:
			_on_win()
	else:
		# Flash red — no penalty, just no hit
		pass

func _on_fail_pressed():
	_on_lose()

func _update_hits_label():
	if hits_label:
		hits_label.text = "Hits: %d/%d" % [hits, REQUIRED_HITS]

func _on_win():
	is_active = false
	set_process(false)
	hits_label.text = "CALIBRATION COMPLETE ✅"
	hits_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))
	hit_button.disabled = true

	await get_tree().create_timer(0.5).timeout
	minigame_success.emit()

func _on_lose():
	is_active = false
	set_process(false)
	hits_label.text = "CALIBRATION FAILED ❌"
	hits_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	hit_button.disabled = true

	await get_tree().create_timer(0.5).timeout
	minigame_failed.emit()
