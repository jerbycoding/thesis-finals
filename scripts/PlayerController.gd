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
@onready var tablet_hud: Control = $TabletHUD

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	EventBus.game_mode_changed.connect(_on_game_mode_changed)

func _on_game_mode_changed(mode):
	if mode == GameState.GameMode.MODE_2D or mode == GameState.GameMode.MODE_DIALOGUE or mode == GameState.GameMode.MODE_MINIGAME:
		movement_enabled = false
		EventBus.request_prompt.emit("", false)
	else:
		movement_enabled = true

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
		else:
			tablet_hud.close()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if not movement_enabled or tablet_active: return
	if event is InputEventMouseMotion:
		camera_rotation.y -= event.relative.x * mouse_sensitivity
		camera_rotation.x = clamp(camera_rotation.x - event.relative.y * mouse_sensitivity, -1.5, 1.5)
		$CameraPivot.rotation.y = camera_rotation.y
		$CameraPivot/Camera3D.rotation.x = camera_rotation.x

func _physics_process(_delta):
	if not movement_enabled: return
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

var tablet_active: bool = false

func _process(_delta):
	if not movement_enabled: return
	if Input.is_action_just_pressed("ui_focus_next"): _try_toggle_tablet()
	if Input.is_action_just_pressed("interact"):
		if carried_object: _drop_object()
		elif near_computer: TransitionManager.enter_desktop_mode(near_computer)
		elif near_npc:
			if near_npc.has_method("start_dialogue"): near_npc.start_dialogue("default")
			else: _pickup_object()

func _pickup_object():
	if not near_npc or carried_object: return
	carried_object = near_npc
	carried_object.get_parent().remove_child(carried_object)
	carry_marker.add_child(carried_object)
	carried_object.position = Vector3.ZERO
	carried_object.rotation = Vector3.ZERO
	if carried_object.has_node("CollisionShape3D"): carried_object.get_node("CollisionShape3D").disabled = true
	speed *= 0.75
	EventBus.request_prompt.emit("Drop " + carried_object.name, true)

func _drop_object():
	if not carried_object: return
	var socket = _get_targeted_socket()
	
	if NarrativeDirector and NarrativeDirector.is_weekend() and not socket:
		if NotificationManager: NotificationManager.show_notification("Place part in target rack.", "warning")
		return

	if socket and socket.has_method("can_accept_object") and not socket.can_accept_object(carried_object):
		return

	var world = get_tree().current_scene
	carried_object.get_parent().remove_child(carried_object)
	world.add_child(carried_object)
	carried_object.global_transform = carry_marker.global_transform
	if carried_object.has_node("CollisionShape3D"): carried_object.get_node("CollisionShape3D").disabled = false
	speed /= 0.75
	if socket: _plug_into_socket(carried_object, socket)
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
		if near_computer.has_method("set_highlight"): near_computer.set_highlight(true)
		EventBus.request_prompt.emit("USE WORKSTATION", true)
	else:
		if near_computer == computer_node:
			if near_computer.has_method("set_highlight"): near_computer.set_highlight(false)
			near_computer = null
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
