extends Control

@onready var rect = $RainRect

# Default colors
const ANALYST_COLOR = Color(0, 0.6, 1, 1)  # Blue
const HACKER_COLOR = Color(0, 1, 0, 1)     # Green

func _ready():
	# Start invisible
	modulate.a = 0
	# Default to analyst color
	set_color(ANALYST_COLOR)

func set_speed(val: float):
	if rect.material is ShaderMaterial:
		rect.material.set_shader_parameter("speed", val)

func set_brightness(val: float):
	if rect.material is ShaderMaterial:
		rect.material.set_shader_parameter("brightness", val)

func set_color(col: Color):
	"""Set the matrix rain color (for role theming)."""
	print("MatrixRain: Setting color to ", col)
	if rect.material is ShaderMaterial:
		print("MatrixRain: Material is ShaderMaterial, setting shader parameter")
		rect.material.set_shader_parameter("color", col)
		var current_color = rect.material.get_shader_parameter("color")
		print("MatrixRain: Shader color is now ", current_color)
	else:
		print("MatrixRain: ERROR - material is not ShaderMaterial!")

func activate():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func evaporate():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()
