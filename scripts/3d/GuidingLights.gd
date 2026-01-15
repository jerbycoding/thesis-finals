# GuidingLights.gd
# Animates UV offset to create a "scrolling" light effect suggesting direction
extends MeshInstance3D

@export var scroll_speed: float = 0.5
var time: float = 0.0

func _process(delta):
	time += delta * scroll_speed
	var mat = get_active_material(0)
	if mat is StandardMaterial3D:
		# We use emission_operator and UV offset to create the crawl effect
		# For simplicity in this prototype, we'll just pulse the energy based on position
		# or scroll the UV if a texture was present.
		# Since we are using a plain material, let's just pulse it.
		var pulse = (sin(time * 5.0) + 1.0) / 2.0
		mat.emission_energy_multiplier = 1.0 + (pulse * 2.0)
