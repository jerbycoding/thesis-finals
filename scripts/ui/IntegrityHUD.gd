# IntegrityHUD.gd
extends Control

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label: Label = %Label
@onready var blink_timer: Timer = %BlinkTimer

var target_value: float = 100.0
var _heartbeat_time: float = 0.0

func _ready():
	if IntegrityManager:
		target_value = IntegrityManager.current_integrity
		update_display(target_value)
		IntegrityManager.integrity_changed.connect(_on_integrity_changed)
	
	EventBus.ticket_completed.connect(_on_ticket_completed)
	modulate.a = 0.8 # Slight transparency

func _process(delta):
	# Smoothly animate the bar
	if progress_bar:
		progress_bar.value = move_toward(progress_bar.value, target_value, delta * 30.0)
		
		# Color coding
		var style = progress_bar.get_theme_stylebox("fill")
		if style:
			if progress_bar.value < 20:
				style.bg_color = Color(0.8, 0.1, 0.1) # Red
				_process_heartbeat(delta)
			elif progress_bar.value < 50:
				style.bg_color = Color(0.8, 0.5, 0.1) # Orange
				modulate.a = 0.8
			else:
				style.bg_color = Color(0.2, 0.8, 0.2) # Green
				modulate.a = 0.8

func _process_heartbeat(delta):
	_heartbeat_time += delta * 5.0
	var pulse = (sin(_heartbeat_time) + 1.0) * 0.5
	modulate.a = lerp(0.4, 1.0, pulse)
	scale = Vector2.ONE * lerp(1.0, 1.05, pulse)
	pivot_offset = size / 2

func _on_ticket_completed(_ticket: TicketResource, completion_type: String, _time: float):
	match completion_type:
		"compliant": flash(Color.GREEN)
		"emergency": flash(Color.YELLOW)
		"timeout": flash(Color.RED)

func _on_integrity_changed(new_value: float, delta: float):
	target_value = new_value
	update_display(new_value)
	
	# Visual Feedback
	if delta < 0:
		flash(Color.RED)
	elif delta > 0:
		flash(Color.GREEN)

func update_display(value: float):
	if label:
		label.text = "SYS_INTEGRITY: %d%%" % int(value)

func flash(color: Color):
	var tween = create_tween()
	tween.tween_property(self, "modulate", color * 1.5, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
