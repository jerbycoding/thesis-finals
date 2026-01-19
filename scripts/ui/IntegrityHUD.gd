# IntegrityHUD.gd
extends Control

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label: Label = %Label
@onready var blink_timer: Timer = %BlinkTimer

var target_value: float = 100.0

func _ready():
	if IntegrityManager:
		target_value = IntegrityManager.current_integrity
		update_display(target_value)
		IntegrityManager.integrity_changed.connect(_on_integrity_changed)
	
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
			elif progress_bar.value < 50:
				style.bg_color = Color(0.8, 0.5, 0.1) # Orange
			else:
				style.bg_color = Color(0.2, 0.8, 0.2) # Green

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
