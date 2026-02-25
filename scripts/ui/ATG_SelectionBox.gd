# ATG_SelectionBox.gd
extends Control

@onready var rect = %ReferenceRect

func _ready():
	modulate.a = 0
	# Set default color to corporate blue
	rect.border_color = Color(0.2, 0.6, 1.0, 0.8)

func activate(target_size: Vector2):
	size = target_size + Vector2(10, 10) # Slight padding
	position = -Vector2(5, 5) # Center with padding
	
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	
	# Start "Marching" dash effect animation if possible, 
	# but standard ReferenceRect is static. 
	# We'll simulate a pulse instead.
	_play_pulse()

func _play_pulse():
	var tween = create_tween().set_loops()
	tween.tween_property(rect, "border_color:a", 0.4, 0.8)
	tween.tween_property(rect, "border_color:a", 0.8, 0.8)

func deactivate():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	hide()
