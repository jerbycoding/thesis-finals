extends CharacterBody3D

@export var speed = 4.0
@export var sprint_multiplier = 1.5
@export var mouse_sensitivity = 0.002

var camera_rotation = Vector2.ZERO
var near_computer = null
var near_npc = null
var movement_enabled = true
var carried_object: Node3D = null

@onready var carry_marker: Marker3D = %CarryMarker3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if %InteractionPrompt:
		%InteractionPrompt.hide()
		%InteractionPrompt.modulate.a = 0

# Connect to EventBus signals
	EventBus.game_mode_changed.connect(_on_game_mode_changed)

func _on_game_mode_changed(mode):
	print("Game mode changed to: ", mode)
	if mode == GameState.GameMode.MODE_2D or mode == GameState.GameMode.MODE_DIALOGUE:
		movement_enabled = false
		print("Movement disabled")
		if %InteractionPrompt:
			%InteractionPrompt.hide_prompt()
	else:
		movement_enabled = true
		print("Movement enabled")

func _input(event):
	if not movement_enabled:
		return


	if event is InputEventMouseMotion:
		camera_rotation.y -= event.relative.x * mouse_sensitivity
		camera_rotation.x = clamp(camera_rotation.x - event.relative.y * mouse_sensitivity, -1.5, 1.5)
		
		$CameraPivot.rotation.y = camera_rotation.y
		$CameraPivot/Camera3D.rotation.x = camera_rotation.x
func _physics_process(delta):
	if not movement_enabled:
		return


	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = ($CameraPivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
func _process(delta):
	if not movement_enabled:
		return

	if Input.is_action_just_pressed("interact"):
		if carried_object:
			_drop_object()
		elif near_computer:
			print("E pressed at computer")
			if TransitionManager:
				TransitionManager.enter_desktop_mode(near_computer)
		elif near_npc:
			print("E pressed at NPC")
			if near_npc.has_method("start_dialogue"):
				near_npc.start_dialogue("default")
		elif _is_near_carryable():
			_pickup_object()

func _is_near_carryable() -> bool:
	# Simplified: We check if the player is near a node in the 'carryable' group
	# In a full game, we'd use a RayCast3D, but for this architecture, 
	# we'll reuse the area-based detection logic if possible or check current 'near' state.
	return near_npc != null and near_npc.is_in_group("carryable")

func _pickup_object():
	if not near_npc or carried_object: return
	
	carried_object = near_npc
	print("Picking up: ", carried_object.name)
	
	# Reparent to camera marker
	carried_object.get_parent().remove_child(carried_object)
	carry_marker.add_child(carried_object)
	
	# Reset local transform
	carried_object.position = Vector3.ZERO
	carried_object.rotation = Vector3.ZERO
	
	# Disable collision while held
	if carried_object.has_node("CollisionShape3D"):
		carried_object.get_node("CollisionShape3D").disabled = true
	
	# Reduce speed while carrying (FULLGAME.md requirement)
	speed *= 0.75
	
	if %InteractionPrompt:
		%InteractionPrompt.set_text("Drop " + carried_object.name)

func _drop_object():
	if not carried_object: return
	
	print("Dropping: ", carried_object.name)
	
	# Check if we are near a 'socket'
	var socket = _get_nearby_socket()
	
	# Reparent back to world (the current scene root)
	var world = get_tree().current_scene
	carried_object.get_parent().remove_child(carried_object)
	world.add_child(carried_object)
	
	# Set position to where the marker is in world space
	carried_object.global_transform = carry_marker.global_transform
	
	# Re-enable collision
	if carried_object.has_node("CollisionShape3D"):
		carried_object.get_node("CollisionShape3D").disabled = false
	
	# Restore speed
	speed /= 0.75
	
	# If dropped in a socket, trigger logic
	if socket:
		_plug_into_socket(carried_object, socket)
	
	carried_object = null
	
	if %InteractionPrompt:
		%InteractionPrompt.hide_prompt()

func _get_nearby_socket() -> Node3D:
	# Find a node in 'socket' group that player is currently 'near'
	# We'll treat sockets like NPCs/Computers for detection
	if near_npc and near_npc.is_in_group("socket"):
		return near_npc
	return null

func _plug_into_socket(obj: Node3D, socket: Node3D):
	print("Object ", obj.name, " plugged into ", socket.name)
	if socket.has_method("on_object_inserted"):
		socket.on_object_inserted(obj)

func set_near_computer(computer_node, is_near):
	if not movement_enabled:
		return
	
	if is_near:
		near_computer = computer_node
		if near_computer.has_method("set_highlight"):
			near_computer.set_highlight(true)
		if %InteractionPrompt:
			%InteractionPrompt.set_text("Use Workstation")
			%InteractionPrompt.show_prompt()
	else:
		if near_computer == computer_node:
			if near_computer.has_method("set_highlight"):
				near_computer.set_highlight(false)
			near_computer = null
		if %InteractionPrompt:
			%InteractionPrompt.hide_prompt()

func set_near_npc(npc_node, is_near):
	if not movement_enabled:
		return
	
	if is_near:
		near_npc = npc_node
		if near_npc.has_method("set_highlight"):
			near_npc.set_highlight(true)
		if %InteractionPrompt:
			var npc_name = near_npc.npc_name if "npc_name" in near_npc else "NPC"
			%InteractionPrompt.set_text("Talk to " + npc_name)
			%InteractionPrompt.show_prompt()
	else:
		if near_npc == npc_node:
			if near_npc.has_method("set_highlight"):
				near_npc.set_highlight(false)
			near_npc = null
		if %InteractionPrompt:
			%InteractionPrompt.hide_prompt()
