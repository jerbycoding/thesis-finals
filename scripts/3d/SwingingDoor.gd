# SwingingDoor.gd
# Handles a realistic door that swings on a hinge.
extends Node3D

@export var open_angle: float = 90.0 # Use -90 for inward swing
@export var open_speed: float = 4.0

var is_open: bool = false

func _process(delta):
	var target_y = deg_to_rad(open_angle) if is_open else 0.0
	rotation.y = lerp_angle(rotation.y, target_y, open_speed * delta)

func open():
	is_open = true

func close():
	is_open = false
