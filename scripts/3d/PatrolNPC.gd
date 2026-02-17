# PatrolNPC.gd
# Simple dummy NPC that walks between random points in a room.
extends CharacterBody3D

@export var walk_speed: float = 1.5
@export var patrol_radius: float = 10.0
@export var wait_time_min: float = 2.0
@export var wait_time_max: float = 6.0

var target_position: Vector3
var is_waiting: bool = false
var wait_timer: float = 0.0

@onready var animator = _find_animator()
@onready var start_pos: Vector3 = global_position

func _ready():
	_pick_new_target()

func _find_animator():
	for child in get_children():
		if child.has_method("update_movement"):
			return child
	return null

func _physics_process(delta):
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			is_waiting = false
			_pick_new_target()
		
		if animator: animator.update_movement(Vector3.ZERO, false)
		return

	# Move towards target
	var dir = (target_position - global_position)
	dir.y = 0 # Keep movement horizontal
	
	if dir.length() < 0.5:
		_start_waiting()
		return
		
	velocity = dir.normalized() * walk_speed
	
	# Face the direction of travel
	if velocity.length() > 0.1:
		var look_target = global_position + velocity
		look_at(look_target, Vector3.UP)
	
	move_and_slide()
	
	# Tell the animator we are walking
	if animator:
		animator.update_movement(velocity, false)

func _start_waiting():
	velocity = Vector3.ZERO
	is_waiting = true
	wait_timer = randf_range(wait_time_min, wait_time_max)

func _pick_new_target():
	var random_offset = Vector3(
		randf_range(-patrol_radius, patrol_radius),
		0,
		randf_range(-patrol_radius, patrol_radius)
	)
	target_position = start_pos + random_offset
