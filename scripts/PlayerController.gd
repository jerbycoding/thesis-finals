extends CharacterBody3D

@export var speed = 4.0
@export var sprint_multiplier = 1.5
@export var mouse_sensitivity = 0.002

var camera_rotation = Vector2.ZERO
var near_computer = null
var near_npc = null
var movement_enabled = true
var carried_object: Node3D = null
var current_target_height: float = 1.75 # Default to eye height
var modal_active: bool = false # NEW: Flag to block input
var is_seated: bool = false # NEW: Track if camera is detached from pivot
var stored_camera_transform: Transform3D

@onready var carry_marker: Marker3D = %CarryMarker3D
@onready var tablet_hud: Control = $TabletHUD
# Delegate animation logic to the child component
@onready var animator = $CameraPivot/BodyModel
@onready var camera = $CameraPivot/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	EventBus.game_mode_changed.connect(_on_game_mode_changed)
	# Initialize POV
	camera.fov = 80

func sit_down(target_node: Node3D):
	if not target_node or is_seated: return
	
	is_seated = true
	stored_camera_transform = camera.global_transform
	_tween_camera_to(target_node.global_transform)

func stand_up():
	if not is_seated:
		movement_enabled = true
		return
		
	_tween_camera_to(stored_camera_transform, true)
	is_seated = false

func _tween_camera_to(target: Transform3D, is_standing_up: bool = false):
	movement_enabled = false
	modal_active = true # Block inputs during transition
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "global_transform", target, 0.8)
	
	tween.finished.connect(func():
		modal_active = false
		if is_standing_up:
			movement_enabled = true
			# Snap back to local coords to ensure headbob works
			camera.position = Vector3(0, EYE_HEIGHT, -0.23)
			camera.rotation = Vector3.ZERO
			# Restore rotation vars from the pivot's current state
			camera_rotation.y = $CameraPivot.rotation.y
			camera_rotation.x = 0.0
	)

func _on_game_mode_changed(mode):
	if mode == GameState.GameMode.MODE_2D or mode == GameState.GameMode.MODE_DIALOGUE or mode == GameState.GameMode.MODE_MINIGAME:
		movement_enabled = false
		current_target_height = SEATED_HEIGHT
		EventBus.request_prompt.emit("", false)
		if animator and animator.has_method("force_idle"):
			animator.force_idle()
	else:
		# If returning to 3D mode, ensure movement is restored
		if mode == GameState.GameMode.MODE_3D and not movement_enabled:
			if is_seated:
				stand_up()
			else:
				movement_enabled = true
		
		# movement_enabled is re-enabled by stand_up() tween callback OR directly above
		current_target_height = EYE_HEIGHT

func _try_toggle_tablet():
	var is_minigame_mode = false
	if NarrativeDirector:
		is_minigame_mode = NarrativeDirector.is_weekend()
	
	if not is_minigame_mode: return

	tablet_active = !tablet_active
	if tablet_hud:
		if tablet_active:
			tablet_hud.open()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if animator and animator.has_method("force_idle"):
				animator.force_idle()
		else:
			tablet_hud.close()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Pure 3D Input Forwarding
	if GameState and GameState.active_bridge:
		if event is InputEventMouseButton:
			GameState.active_bridge.handle_mouse_button(event)
			get_viewport().set_input_as_handled()
			return
		elif event is InputEventKey:
			if event.is_action_pressed("ui_cancel"):
				# SMART ESCAPE: Only stand up if no apps are open
				var has_open_apps = false
				if DesktopWindowManager and not DesktopWindowManager.open_windows.is_empty():
					has_open_apps = true
				
				if not has_open_apps:
					TransitionManager.exit_desktop_mode()
					get_viewport().set_input_as_handled()
					return
			
			# Otherwise forward to bridge
			GameState.active_bridge.handle_key(event)
			get_viewport().set_input_as_handled()
			return

	if not movement_enabled or tablet_active or modal_active: return
	if event is InputEventMouseMotion:
		camera_rotation.y -= event.relative.x * mouse_sensitivity
		camera_rotation.x = clamp(camera_rotation.x - event.relative.y * mouse_sensitivity, -1.5, 1.5)
		$CameraPivot.rotation.y = camera_rotation.y
		$CameraPivot/Camera3D.rotation.x = camera_rotation.x

func _physics_process(_delta):
	if not movement_enabled or modal_active: return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = ($CameraPivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = speed * (sprint_multiplier if Input.is_action_pressed("sprint") else 1.0)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()
	
	# Update animation state
	if animator and animator.has_method("update_movement"):
		animator.update_movement(velocity, Input.is_action_pressed("sprint"), carried_object != null)

var tablet_active: bool = false
var bob_time = 0.0
var footstep_timer = 0.0
const BOB_FREQ = 2.0 # Slightly slower for more "weight"
const BOB_AMP = 0.04 # Slightly subtler
const FOOTSTEP_INTERVAL = 0.5
const EYE_HEIGHT = 1.75 # True eye level
const SEATED_HEIGHT = 1.35 # Seated eye level

func _process(delta):
	if not movement_enabled or modal_active: 
		# Do not interfere with camera height during transitions or while seated
		return
		
	_handle_headbob(delta)
	_handle_footsteps(delta)
	
	if Input.is_action_just_pressed("ui_focus_next"): _try_toggle_tablet()
	
	# Dedicated Drop Key (Q)
	if Input.is_action_just_pressed("drop") and carried_object:
		_drop_object()
	
	if Input.is_action_just_pressed("interact"):
		if carried_object: _drop_object()
		elif near_computer: TransitionManager.enter_desktop_mode(near_computer)
		elif near_npc:
			if near_npc.has_method("start_dialogue"): near_npc.start_dialogue("default")
			# EXPLICIT CHECK: Only pick up if it belongs to 'carriable' group
			elif near_npc.is_in_group("carriable"): _pickup_object()

func _handle_footsteps(delta):
	if velocity.length() > 0.1 and is_on_floor():
		var multiplier = sprint_multiplier if Input.is_action_pressed("sprint") else 1.0
		footstep_timer -= delta * multiplier
		if footstep_timer <= 0:
			if AudioManager: AudioManager.play_footstep()
			footstep_timer = FOOTSTEP_INTERVAL
	else:
		footstep_timer = 0.0
		if AudioManager: AudioManager.stop_footstep()

func _handle_headbob(delta):
	if velocity.length() > 0.1:
		bob_time += delta * velocity.length() * (sprint_multiplier if Input.is_action_pressed("sprint") else 1.0)
		var target_y = current_target_height + sin(bob_time * BOB_FREQ) * BOB_AMP
		$CameraPivot/Camera3D.position.y = lerp($CameraPivot/Camera3D.position.y, target_y, delta * 10.0)
	else:
		bob_time = 0.0
		$CameraPivot/Camera3D.position.y = lerp($CameraPivot/Camera3D.position.y, current_target_height, delta * 10.0)

func _pickup_object():
	if not near_npc or carried_object: return
	carried_object = near_npc
	carried_object.get_parent().remove_child(carried_object)
	carry_marker.add_child(carried_object)
	carried_object.position = Vector3.ZERO
	# Add a slight "held" tilt
	carried_object.rotation = Vector3(deg_to_rad(-15), deg_to_rad(10), 0)
	if carried_object.has_node("CollisionShape3D"): carried_object.get_node("CollisionShape3D").disabled = true
	speed *= 0.75
	EventBus.request_prompt.emit("Drop " + carried_object.name, true)

func _drop_object():
	if not carried_object: return
	var socket = _get_targeted_socket()
	
	# If looking at a socket, try to plug it in
	if socket:
		if socket.has_method("can_accept_object") and not socket.can_accept_object(carried_object):
			return # Cannot plug in here
			
		var world = get_tree().current_scene
		carried_object.get_parent().remove_child(carried_object)
		world.add_child(carried_object)
		carried_object.global_transform = carry_marker.global_transform
		if carried_object.has_node("CollisionShape3D"): 
			carried_object.get_node("CollisionShape3D").disabled = false
		
		_plug_into_socket(carried_object, socket)
		speed /= 0.75
		carried_object = null
		EventBus.request_prompt.emit("", false)
		return

	# Fallback: Drop on floor (anywhere)
	var world = get_tree().current_scene
	carried_object.get_parent().remove_child(carried_object)
	world.add_child(carried_object)
	
	# Raycast down from marker to find the floor
	var space_state = get_world_3d().direct_space_state
	var origin = carry_marker.global_position
	var end = origin + Vector3.DOWN * 2.0
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	
	if result:
		carried_object.global_position = result.position
	else:
		carried_object.global_transform = carry_marker.global_transform
		
	if carried_object.has_node("CollisionShape3D"): 
		carried_object.get_node("CollisionShape3D").disabled = false
		
	speed /= 0.75
	carried_object = null
	EventBus.request_prompt.emit("", false)

func _get_targeted_socket() -> Node3D:
	if not %InteractionRay: return null
	if %InteractionRay.is_colliding():
		var collider = %InteractionRay.get_collider()
		if collider.is_in_group("socket"): return collider
		if collider.get_parent() and collider.get_parent().is_in_group("socket"): return collider.get_parent()
	if near_npc and near_npc.is_in_group("socket"): return near_npc
	return null

func _plug_into_socket(obj: Node3D, socket: Node3D):
	if socket.has_method("on_object_inserted"): socket.on_object_inserted(obj)

func set_near_computer(computer_node, is_near):
	if not movement_enabled: return
	if is_near:
		near_computer = computer_node
		if GameState: GameState.current_computer = computer_node
		if near_computer.has_method("set_highlight"): near_computer.set_highlight(true)
		EventBus.request_prompt.emit("USE WORKSTATION", true)
	else:
		if near_computer == computer_node:
			if near_computer.has_method("set_highlight"): near_computer.set_highlight(false)
			near_computer = null
			if GameState: GameState.current_computer = null
		EventBus.request_prompt.emit("", false)

func set_near_npc(npc_node, is_near):
	if not movement_enabled: return
	if is_near:
		near_npc = npc_node
		if near_npc.has_method("set_highlight"): near_npc.set_highlight(true)
		var n = near_npc.npc_name if "npc_name" in near_npc else "ITEM"
		EventBus.request_prompt.emit(n.to_upper(), true)
	else:
		if near_npc == npc_node:
			if near_npc.has_method("set_highlight"): near_npc.set_highlight(false)
			near_npc = null
		EventBus.request_prompt.emit("", false)
