# PatrolNPC.gd
# NPC that can either wander randomly or follow a specific path of nodes.
extends CharacterBody3D

enum PatrolMode { RANDOM, PATH }

@export var mode: PatrolMode = PatrolMode.RANDOM
@export var walk_speed: float = 2.0
@export var wait_time: float = 2.0

# RANDOM MODE SETTINGS
@export var patrol_radius: float = 10.0

# PATH MODE SETTINGS (Drag Marker3D nodes here in the inspector)
@export var patrol_path: Array[Node3D] = []

var target_position: Vector3
var is_waiting: bool = false
var wait_timer: float = 0.0
var current_path_index: int = 0

@onready var animator = _find_animator()
@onready var start_pos: Vector3 = global_position

func _ready():
	if mode == PatrolMode.PATH and patrol_path.size() > 0:
		_set_target_from_path()
	else:
		_pick_random_target()

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
			_move_to_next()
		
		if animator: animator.update_movement(Vector3.ZERO, false)
		return

	# Move towards target
	var dir = (target_position - global_position)
	dir.y = 0 # Keep movement horizontal
	
	if dir.length() < 0.6: # Arrival threshold
		_start_waiting()
		return
		
	velocity = dir.normalized() * walk_speed
	
	# Smoothly look at target
	if velocity.length() > 0.1:
		var look_target = global_position + velocity
		look_at(look_target, Vector3.UP)
	
	move_and_slide()
	
	if animator: animator.update_movement(velocity, false)

func _start_waiting():
	velocity = Vector3.ZERO
	is_waiting = true
	wait_timer = wait_time

func _move_to_next():
	if mode == PatrolMode.PATH and patrol_path.size() > 0:
		current_path_index = (current_path_index + 1) % patrol_path.size()
		_set_target_from_path()
	else:
		_pick_random_target()

func _set_target_from_path():
	var node = patrol_path[current_path_index]
	if node:
		target_position = node.global_position

func _pick_random_target():
	var random_offset = Vector3(
		randf_range(-patrol_radius, patrol_radius),
		0,
		randf_range(-patrol_radius, patrol_radius)
	)
	target_position = start_pos + random_offset
