# NPC_Victim.gd
# Office Worker NPC - Patrols a specific square path.
extends BaseNPC

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@export var waypoints: Array[Vector3] = []
var current_waypoint_idx: int = 0
var is_waiting: bool = false
var wait_timer: float = 0.0

# Stuck detection
var last_pos: Vector3 = Vector3.ZERO
var stuck_timer: float = 0.0
const STUCK_TIMEOUT = 3.0 # Give it more time to calculate

func _ready():
	super._ready()
	# Configure navigation - Be more lenient with distances
	nav_agent.path_desired_distance = 0.6
	nav_agent.target_desired_distance = 0.6
	
	# HEARTBEAT: Print status every 5 seconds to see if she's alive
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.autostart = true
	timer.timeout.connect(_print_heartbeat)
	add_child(timer)
	
	# Wait for world to settle
	get_tree().create_timer(2.0).timeout.connect(_init_patrol)

func _print_heartbeat():
	if not is_waiting:
		print("[NPC_Victim] Heartbeat - Pos: ", global_position, " | Target: ", nav_agent.target_position, " | Reachable: ", nav_agent.is_target_reachable())

func _init_patrol():
	# FORCE GROUNDING: Snap to NavMesh floor immediately
	var map = nav_agent.get_navigation_map()
	if map.is_valid():
		var closest_point = NavigationServer3D.map_get_closest_point(map, global_position)
		global_position = closest_point
		print("[NPC_Victim] Snapped to NavMesh at: ", global_position)

	if waypoints.is_empty():
		var start = global_position
		waypoints = [
			start + Vector3(2, 0, 2),
			start + Vector3(-2, 0, 2),
			start + Vector3(-2, 0, -2),
			start + Vector3(2, 0, -2)
		]
	
	current_waypoint_idx = 0
	_set_next_waypoint()

func _set_next_waypoint():
	if waypoints.size() == 0: return
	
	# Ensure the target waypoint is also snapped to the floor
	var target = waypoints[current_waypoint_idx]
	var map = nav_agent.get_navigation_map()
	if map.is_valid():
		target = NavigationServer3D.map_get_closest_point(map, target)
	
	nav_agent.target_position = target
	is_waiting = false
	stuck_timer = 0.0
	print("[NPC_Patrol] Heading to waypoint ", current_waypoint_idx, " at ", target)

func _physics_process(delta):
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			current_waypoint_idx = (current_waypoint_idx + 1) % waypoints.size()
			_set_next_waypoint()
		return

	# If navigation is finished but we aren't waiting, something is wrong
	if nav_agent.is_navigation_finished():
		print("[NPC_Patrol] Finished current path. Waiting...")
		is_waiting = true
		wait_timer = 2.0
		velocity = Vector3.ZERO
		if animator: animator.force_idle()
		return

	# Get the next point in the path
	var next_path_pos = nav_agent.get_next_path_position()
	var current_pos = global_position
	
	# Calculate direction (flattened)
	var direction = (next_path_pos - current_pos)
	direction.y = 0
	
	if direction.length() > 0.01:
		direction = direction.normalized()
		velocity.x = direction.x * 1.5
		velocity.z = direction.z * 1.5
	else:
		# We are at a path point, but not the final target
		velocity.x = 0
		velocity.z = 0
	
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = -0.1
	
	move_and_slide()
	
	# STUCK DETECTION
	var movement_this_frame = global_position.distance_to(last_pos)
	if movement_this_frame < 0.001: # Extra sensitive
		stuck_timer += delta
	else:
		stuck_timer = 0.0
	
	last_pos = global_position
	
	if stuck_timer > STUCK_TIMEOUT:
		print("[NPC_Patrol] STUCK! Teleporting slightly to clear...")
		global_position = global_position.lerp(next_path_pos, 0.2)
		stuck_timer = 0.0
		return
	
	# ROTATION
	if Vector2(velocity.x, velocity.z).length() > 0.1:
		var target_rotation = atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
	
	if animator:
		animator.update_movement(velocity, false)
