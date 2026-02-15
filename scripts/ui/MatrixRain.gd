extends Control

@onready var rect = $RainRect

func _ready():
	# Start invisible
	modulate.a = 0

func set_speed(val: float):
	if rect.material is ShaderMaterial:
		rect.material.set_shader_parameter("speed", val)

func set_brightness(val: float):
	if rect.material is ShaderMaterial:
		rect.material.set_shader_parameter("brightness", val)

func activate():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func evaporate():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()
